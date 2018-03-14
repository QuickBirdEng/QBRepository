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
    private let _create: (Model, Bool, (RepositoryEditResult<Model>) -> Void) -> Void
    private let _createMultiple: ([Model], Bool, (RepositoryEditResult<[Model]>) -> Void) -> Void
    private let _update: (Model, Bool, (RepositoryEditResult<Model>) -> Void) -> Void
    private let _delete: (Model, Bool, (Error?) -> Void) -> Void
    private let _deleteAll: (Bool, (Error?) -> Void) -> Void

    public init<A: Repository>(_ repository: A) where A.Model == Model {
        _getAll = repository.getAll
        _getElement = repository.getElement
        _getElements = repository.getElements
        _create = repository.create
        _createMultiple = repository.create
        _update = repository.update
        _delete = repository.delete
        _deleteAll = repository.deleteAll
    }

    public func getAll(_ completion: (AnyCollection<Model>) -> Void) {
        _getAll(completion)
    }

    public func getElements(fileredBy predicateFormat: String, _ args: Any..., completion: (AnyCollection<Model>) -> Void) {
        _getElements(predicateFormat, args) { results in
            completion(results)
        }
    }

    public func getElement<Id>(withId id: Id, completion: (Model?) -> Void) {
        _getElement(id, completion)
    }

    public func create(_ model: Model, cascading: Bool, completion: (RepositoryEditResult<Model>) -> Void) {
        _create(model, cascading, completion)
    }

    public func create(_ models: [Model], cascading: Bool, completion: (RepositoryEditResult<[Model]>) -> Void) {
        _createMultiple(models, cascading, completion)
    }

    public func update(_ model: Model, cascading: Bool, completion: (RepositoryEditResult<Model>) -> Void) {
        _update(model, cascading, completion)
    }

    public func delete(_ model: Model, cascading: Bool, completion: (Error?) -> Void) {
        _delete(model, cascading, completion)
    }

    public func deleteAll(cascading: Bool, _ completion: (Error?) -> Void) {
        _deleteAll(cascading, completion)
    }

}
