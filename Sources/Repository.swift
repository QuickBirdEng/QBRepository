//
//  Repository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation

public protocol Repository {
    associatedtype Model

    func getAll() -> AnyRandomAccessCollection<Model>
    func getElement<Id>(withId id: Id) -> Model?
    func getElements(filteredBy filter: RepositoryFilter?, sortedBy sortMode: RepositorySortMode<Model>?, distinctUsing distinctMode: RepositoryDistinctMode<Model>?) -> AnyRandomAccessCollection<Model>
    @discardableResult func create(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func create(_ models: [Model]) -> RepositoryEditResult<[Model]>
    @discardableResult func update(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func delete(_ model: Model) -> Error?
    @discardableResult func delete(_ models: [Model]) -> Error?
    @discardableResult func deleteAll() -> Error?
    @discardableResult func performTranscation(_ transaction: () -> Void) -> Error?
}

public extension Repository {

    public func getElements(filteredBy filter: RepositoryFilter? = nil, sortedBy sortMode: RepositorySortMode<Model>? = nil, distinctUsing distinctMode: RepositoryDistinctMode<Model>? = nil) -> AnyRandomAccessCollection<Model> {
        return getElements(filteredBy: filter, sortedBy: sortMode, distinctUsing: distinctMode)
    }

    public func getElements(filteredByPredicate predicateFormat: String? = nil, _ args: Any..., sortedBy keyPath: PartialKeyPath<Model>? = nil, distinctUsing: PartialKeyPath<Model>? = nil) -> AnyRandomAccessCollection<Model> {
        let filter = predicateFormat.map { RepositoryFilter.predicateString($0, args) }
        let sortMode = keyPath.map { RepositorySortMode.keyPath($0) }
        let distinctMode = keyPath.map { RepositoryDistinctMode.keyPath($0) }
        return getElements(filteredBy: filter, sortedBy: sortMode, distinctUsing: distinctMode)
    }

}
