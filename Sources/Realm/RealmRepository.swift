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

    public func getElement<Id>(withId id: Id, completion: (Model?) -> Void) {
        let object = realm.object(ofType: Model.self, forPrimaryKey: id)
        completion(object)
    }

    public func create(_ model: Model, cascading: Bool, completion: (RepositoryEditResult<Model>) -> Void) {
        do {
            try realm.write {
                realm.add(model, cascading: cascading)
            }
            completion(.success(model))
        } catch {
            completion(.error(error))
        }
    }

    public func create(_ models: [Model], cascading: Bool, completion: (RepositoryEditResult<[Model]>) -> Void) {
        do {
            try realm.write {
                realm.add(models, cascading: cascading)
            }
            completion(.success(models))
        } catch {
            completion(.error(error))
        }
    }

    public func update(_ model: Model, cascading: Bool, completion: (RepositoryEditResult<Model>) -> Void) {
        guard let primaryKey = Model.self.primaryKey(),
            let id = model.value(forKey: primaryKey),
            realm.object(ofType: Model.self, forPrimaryKey: id) == nil else {
                completion(.error(RealmError.noOriginalObject))
                return
        }

        do {
            try realm.write {
                realm.add(model, cascading: cascading)
            }
            completion(.success(model))
        } catch {
            completion(.error(error))
        }
    }

    public func delete(_ model: Model, cascading: Bool = false, completion: (Error?) -> Void) {
        do {
            try realm.write {
                realm.delete(model, cascading: cascading)
            }
            completion(nil)
        } catch {
            completion(error)
        }
    }

    public func deleteAll(cascading: Bool = false, _ completion: (Error?) -> Void) {
        let allObjects = realm.objects(Model.self)
        do {
            try realm.write {
                realm.delete(allObjects, cascading: cascading)
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

}
