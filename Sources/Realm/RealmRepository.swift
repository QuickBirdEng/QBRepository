//
//  RealmRepository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation
import RealmSwift

public enum RealmError: Error {
    case noOriginalObject
}

public class RealmRepository<Object: RealmSwift.Object>: Repository {
    public typealias Model = Object

    private let realm: Realm

    // swiftlint:disable:next force_try
    public init(realm: Realm = try! Realm()) {
        self.realm = realm
    }

    public func getAll(_ completion: (AnyCollection<Model>) -> Void) {
        let allObjects = realm.objects(Model.self)
        completion(AnyCollection(allObjects))
    }

    public func getElements(fileredBy predicateFormat: String, _ args: Any..., completion: (AnyCollection<Model>) -> Void) {
        let unrwappedArgs = unwrapArgs(args)
        let predicate = NSPredicate(format: predicateFormat, argumentArray: unrwappedArgs)
        let objects = realm.objects(Model.self).filter(predicate)
        completion(AnyCollection(objects))
    }

    public func getElement<Id>(withId id: Id, _ completion: (Model?) -> Void) {
        let object = realm.object(ofType: Model.self, forPrimaryKey: id)
        completion(object)
    }

    public func create(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void) {
        do {
            try realm.write {
                realm.add(model, cascade: true, update: isIdentifiable())
            }
            completion(.success(model))
        } catch {
            completion(.error(error))
        }
    }

    public func create(_ models: [Model], _ completion: (RepositoryEditResult<[Model]>) -> Void) {
        do {
            try realm.write {
                realm.add(models, cascade: true, update: isIdentifiable())
            }
            completion(.success(models))
        } catch {
            completion(.error(error))
        }
    }

    public func update(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void) {
        guard let primaryKey = Model.self.primaryKey(),
            let id = model.value(forKey: primaryKey),
            realm.object(ofType: Model.self, forPrimaryKey: id) == nil else {
                completion(.error(RealmError.noOriginalObject))
                return
        }

        do {
            try realm.write {
                realm.add(model, cascade: true, update: isIdentifiable())
            }
            completion(.success(model))
        } catch {
            completion(.error(error))
        }
    }

    public func delete(_ model: Model, _ completion: (Error?) -> Void) {
        do {
            try realm.write {
                realm.delete(model, cascade: true)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func deleteAll(_ completion: (Error?) -> Void) {
        let allObjects = realm.objects(Model.self)
        do {
            try realm.write {
                realm.delete(allObjects, cascade: true)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }

    // MARK: Helper

    private func unwrapArgs(_ args: [Any]) -> [Any] {
        let unrwappedArgs = args.flatMap { arg -> [Any] in
            if let arg = arg as? [Any] {
                return arg
            } else {
                return [arg]
            }
        }

        if unrwappedArgs.contains(where: { $0 is [Any] }) {
            return self.unwrapArgs(unrwappedArgs)
        } else {
            return unrwappedArgs
        }
    }

    private func isIdentifiable() -> Bool {
        return Model.primaryKey() != nil
    }

}
