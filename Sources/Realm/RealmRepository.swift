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

    public func getAll() -> AnyRandomAccessCollection<Model> {
        let allObjects = realm.objects(Model.self)
        return AnyRandomAccessCollection(allObjects)
    }

    public func getElement<Id>(withId id: Id) -> Model? {
        let object = realm.object(ofType: Model.self, forPrimaryKey: id)
        return object
    }

    public func getElements(filteredBy filter: RepositoryFilter?, sortedBy sortMode: RepositorySortMode<Model>?) -> AnyRandomAccessCollection<Model> {
        var objects = realm.objects(Model.self)

        switch filter {
        case .none:
            break
        case .some(.predicate(let predicate)):
            objects = objects.filter(predicate)
        case .some(let .string(predicateFormat, args)):
            objects = objects.filter(NSPredicate(format: predicateFormat, argumentArray: args))
        }

        switch sortMode {
        case .none:
            break
        case .some(.stringKeyPath(let keyPath)):
            objects = objects.sorted(byKeyPath: keyPath, ascending: true)
        case .some(.keyPath(let keyPath)):
            objects = objects.sorted(byKeyPath: keyPath._kvcKeyPathString! as String, ascending: true)
        }

        return AnyRandomAccessCollection(objects)
    }

    @discardableResult public func create(_ model: Model) -> RepositoryEditResult<Model> {
        do {
            try realm.write {
                realm.add(model, cascade: true, update: isIdentifiable())
            }
            return .success(model)
        } catch {
            return .error(error)
        }
    }

    @discardableResult public func create(_ models: [Model]) -> RepositoryEditResult<[Model]> {
        do {
            try realm.write {
                realm.add(models, cascade: true, update: isIdentifiable())
            }
            return .success(models)
        } catch {
            return .error(error)
        }
    }

    @discardableResult public func update(_ model: Model) -> RepositoryEditResult<Model> {
        guard let primaryKey = Model.self.primaryKey(),
            let id = model.value(forKey: primaryKey),
            realm.object(ofType: Model.self, forPrimaryKey: id) == nil else {
                return .error(RealmError.noOriginalObject)
        }

        do {
            try realm.write {
                realm.add(model, cascade: true, update: isIdentifiable())
            }
            return .success(model)
        } catch {
            return .error(error)
        }
    }

    @discardableResult public func delete(_ model: Model) -> Error? {
        do {
            try realm.write {
                realm.delete(model, cascade: true)
            }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult public func delete(_ models: [Model]) -> Error? {
        do {
            try realm.write {
                realm.delete(models, cascade: true)
            }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult public func deleteAll() -> Error? {
        let allObjects = realm.objects(Model.self)
        do {
            try realm.write {
                realm.delete(allObjects, cascade: true)
            }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult public func performTranscation(_ transaction: () -> Void) -> Error? {
        do {
            try realm.write {
                transaction()
            }
            return nil
        } catch {
            return error
        }
    }

    // MARK: Helper

    private func isIdentifiable() -> Bool {
        return Model.primaryKey() != nil
    }

}
