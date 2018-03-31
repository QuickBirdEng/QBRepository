//
//  AnyRepository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation

public final class AnyRepository<Model>: Repository {

    private let _getAll: () -> AnyRandomAccessCollection<Model>
    private let _getElement: (Any) -> Model?
    private let _getElements: (RepositoryFilter?, RepositorySortMode<Model>?, RepositoryDistinctMode<Model>?) -> AnyRandomAccessCollection<Model>
    private let _create: (Model) -> RepositoryEditResult<Model>
    private let _createMultiple: ([Model]) -> RepositoryEditResult<[Model]>
    private let _update: (Model) -> RepositoryEditResult<Model>
    private let _delete: (Model) -> Error?
    private let _deleteMultiple: ([Model]) -> Error?
    private let _deleteAll: () -> Error?
    private let _performTranscation: (() -> Void) -> Error?

    public init<A: Repository>(_ repository: A) where A.Model == Model {
        _getAll = repository.getAll
        _getElement = repository.getElement
        _getElements = repository.getElements
        _create = repository.create
        _createMultiple = repository.create
        _update = repository.update
        _delete = repository.delete
        _deleteMultiple = repository.delete
        _deleteAll = repository.deleteAll
        _performTranscation = repository.performTranscation
    }

    public func getAll() -> AnyRandomAccessCollection<Model> {
        return _getAll()
    }

    public func getElement<Id>(withId id: Id) -> Model? {
        return _getElement(id)
    }

    public func getElements(filteredBy filter: RepositoryFilter?, sortedBy sortMode: RepositorySortMode<Model>?, distinctUsing distinctMode: RepositoryDistinctMode<Model>?) -> AnyRandomAccessCollection<Model> {
        return _getElements(filter, sortMode, distinctMode)
    }

    @discardableResult public func create(_ model: Model) -> RepositoryEditResult<Model> {
        return _create(model)
    }

    @discardableResult public func create(_ models: [Model]) -> RepositoryEditResult<[Model]> {
        return _createMultiple(models)
    }

    @discardableResult public func update(_ model: Model) -> RepositoryEditResult<Model> {
        return _update(model)
    }

    @discardableResult public  func delete(_ model: Model) -> Error? {
        return _delete(model)
    }

    @discardableResult public func delete(_ models: [Model]) -> Error? {
        return _deleteMultiple(models)
    }

    @discardableResult public func deleteAll() -> Error? {
        return _deleteAll()
    }

    public func performTranscation(_ transaction: () -> Void) -> Error? {
        return _performTranscation(transaction)
    }

}
