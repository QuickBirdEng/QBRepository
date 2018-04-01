//
//  CoreDataRepository.swift
//  QBRepository
//
//  Created by Stefan Kofler on 01.04.18.
//

import Foundation
import CoreData

public enum CoreDataError: Error {
    case deleteAllNotSupported
}

public class CoreDataRepository<Object: NSManagedObject & NSFetchRequestResult>: Repository {
    public typealias Model = Object

    private let context: NSManagedObjectContext

    public init(context: NSManagedObjectContext) {
        self.context = context
    }

    public func makeEntity() -> Object {
        var entity: Object!

        context.performAndWait() {
            entity = NSEntityDescription.insertNewObject(forEntityName: String(describing: Object.self), into: context) as? Object
        }

        return entity
    }

    public func getAll() -> AnyRandomAccessCollection<Object> {
        return getElements(filteredBy: nil, sortedBy: nil, distinctUsing: nil)
    }

    public func getElement<Id>(withId id: Id) -> Object? {
        var ret: Object?

        context.performAndWait {
            let request = NSFetchRequest<Object>()

            request.entity = NSEntityDescription.entity(forEntityName: String(describing: Object.self), in: context)
            request.predicate = NSPredicate(format: "id = %@", id as! CVarArg)
            request.fetchLimit = 1

            do {
                let results = try context.fetch(request)
                ret = results.first
            } catch {
                ret = nil
            }
        }

        return ret
    }

    public func getElements(filteredBy filter: Query<Model>?, sortedBy sortKeyPath: ComparableKeyPath<Model>?, distinctUsing distinctKeyPath: HashableKeyPath<Model>?) -> AnyRandomAccessCollection<Model> {
        var ret: [Object]!

        context.performAndWait {
            let request = NSFetchRequest<Object>()

            request.entity = NSEntityDescription.entity(forEntityName: String(describing: Object.self), in: context)
            request.predicate = filter?.createPredicate()

            if let sortKeyPath = sortKeyPath {
                request.sortDescriptors = [NSSortDescriptor(key: sortKeyPath.string(), ascending: true)]
            }

            do {
                var results = try context.fetch(request)

                if let distinctKeyPath = distinctKeyPath {
                    let grouped = Dictionary(grouping: results, by: distinctKeyPath.hashValue)
                    results = grouped.values.flatMap { $0.first }
                }

                ret = results
            } catch {
                ret = [Object]()
            }
        }

        return AnyRandomAccessCollection(ret)
    }

    @discardableResult public func create(_ model: Object) -> RepositoryEditResult<Object> {
        var res: RepositoryEditResult<Object>!

        context.performAndWait {
            do {
                try context.save()
                res = .success(model)
            } catch {
                res = .error(error)
            }
        }

        return res
    }

    @discardableResult public func create(_ models: [Object]) -> RepositoryEditResult<[Object]> {
        var res: RepositoryEditResult<[Object]>!

        context.performAndWait {
            do {
                try context.save()
                res = .success(models)
            } catch {
                res = .error(error)
            }
        }

        return res
    }

    @discardableResult public func update(_ model: Object) -> RepositoryEditResult<Object> {
        var res: RepositoryEditResult<Object>!

        context.performAndWait {
            do {
                try context.save()
                res = .success(model)
            } catch {
                res = .error(error)
            }
        }

        return res
    }

    @discardableResult public func delete(_ model: Object) -> Error? {
        context.performAndWait {
            context.delete(model)
        }
        return nil
    }

    @discardableResult public func delete(_ models: [Object]) -> Error? {
        models.forEach(context.delete)
        return nil
    }

    @discardableResult public func deleteAll() -> Error? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Object.self))
        request.includesPropertyValues = false

        var error: Error?

        context.performAndWait {
            do {
                let results = try context.fetch(request) as? [Object] ?? []
                error = delete(results)
            } catch let cdError {
                error = cdError
            }
        }

        return error
    }

    @discardableResult public func performTranscation(_ transaction: () -> Void) -> Error? {
        var res: Error?

        context.performAndWait {
            transaction()
            do {
                try context.save()
                res = nil
            } catch {
                context.rollback()
                res = error
            }
        }

        return res
    }

}
