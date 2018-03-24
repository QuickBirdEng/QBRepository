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
    func getElements(filteredBy filter: RepositoryFilter?, sortedBy sortMode: RepositorySortMode<Model>?) -> AnyRandomAccessCollection<Model>
    @discardableResult func create(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func create(_ models: [Model]) -> RepositoryEditResult<[Model]>
    @discardableResult func update(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func delete(_ model: Model) -> Error?
    @discardableResult func delete(_ models: [Model]) -> Error?
    @discardableResult func deleteAll() -> Error?
    @discardableResult func performTranscation(_ transaction: () -> Void) -> Error?
}

public extension Repository {

    func getElements(filteredBy filter: RepositoryFilter? = nil, sortedBy sortMode: RepositorySortMode<Model>? = nil) -> AnyRandomAccessCollection<Model> {
        return getElements(filteredBy: filter, sortedBy: sortMode)
    }

}
