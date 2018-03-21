//
//  AnyRepository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation

public final class AnyRepository<Model>: Repository {

    private let _getAll: ((AnyCollection<Model>) -> Void) -> Void
    private let _getElement: (Any, (Model?) -> Void) -> Void
    private let _getElements: (String, Any..., (AnyCollection<Model>) -> Void) -> Void
    private let _getElementsPredicate: (NSPredicate, (AnyCollection<Model>) -> Void) -> Void
    private let _create: (Model, (RepositoryEditResult<Model>) -> Void) -> Void
    private let _createMultiple: ([Model], (RepositoryEditResult<[Model]>) -> Void) -> Void
    private let _update: (Model, (RepositoryEditResult<Model>) -> Void) -> Void
    private let _delete: (Model, (Error?) -> Void) -> Void
    private let _deleteAll: ((Error?) -> Void) -> Void

    public init<A: Repository>(_ repository: A) where A.Model == Model {
        _getAll = repository.getAll
        _getElement = repository.getElement
        _getElements = repository.getElements
        _getElementsPredicate = repository.getElements(filteredBy:completion:)
        _create = repository.create
        _createMultiple = repository.create
        _update = repository.update
        _delete = repository.delete
        _deleteAll = repository.deleteAll
    }

    public func getAll(_ completion: (AnyCollection<Model>) -> Void) {
        _getAll(completion)
    }

    public func getElements(filteredBy predicateFormat: String, _ args: Any..., completion: (AnyCollection<Model>) -> Void) {
        _getElements(predicateFormat, args) { results in
            completion(results)
        }
    }

    public func getElements(filteredBy predicate: NSPredicate, completion: (AnyCollection<Model>) -> Void) {
        _getElementsPredicate(predicate, completion)
    }

    public func getElement<Id>(withId id: Id, _ completion: (Model?) -> Void) {
        _getElement(id, completion)
    }

    public func create(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void) {
        _create(model, completion)
    }

    public func create(_ models: [Model], _ completion: (RepositoryEditResult<[Model]>) -> Void) {
        _createMultiple(models, completion)
    }

    public func update(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void) {
        _update(model, completion)
    }

    public func delete(_ model: Model, _ completion: (Error?) -> Void) {
        _delete(model, completion)
    }

    public func deleteAll(_ completion: (Error?) -> Void) {
        _deleteAll(completion)
    }

}
