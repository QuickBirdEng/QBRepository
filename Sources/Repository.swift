//
//  Repository.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public protocol Repository {
    associatedtype Model

    func getAll() -> AnyRandomAccessCollection<Model>
    func getElement<Id>(withId id: Id) -> Model?
    func getElements(filteredBy filter: Query<Model>?, sortedBy sortKeyPath: ComparableKeyPath<Model>?, distinctUsing distinctMode: HashableKeyPath<Model>?) -> AnyRandomAccessCollection<Model>
    @discardableResult func create(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func create(_ models: [Model]) -> RepositoryEditResult<[Model]>
    @discardableResult func update(_ model: Model) -> RepositoryEditResult<Model>
    @discardableResult func delete(_ model: Model) -> Error?
    @discardableResult func delete(_ models: [Model]) -> Error?
    @discardableResult func deleteAll() -> Error?
    @discardableResult func performTranscation(_ transaction: () -> Void) -> Error?
}

public extension Repository {

    public func getElements<T: Comparable, U: Hashable>(filteredBy filter: Query<Model>? = nil, sortedBy sortKeyPath: KeyPath<Model, T>? = nil, distinctUsing distinctKeyPath: KeyPath<Model, U>? = nil) -> AnyRandomAccessCollection<Model> {
        return getElements(filteredBy: filter, sortedBy: sortKeyPath.map(ComparableKeyPath.init), distinctUsing: distinctKeyPath.map(HashableKeyPath.init))
    }

    public func getElements<P: Predicate>(filteredByPredicate predicate: @autoclosure () -> P) -> AnyRandomAccessCollection<Model> where P.ResultType == Model {
        let filter = Query(predicate)
        return getElements(filteredBy: filter, sortedBy: nil, distinctUsing: nil)
    }

    public func getElements<P: Predicate, T: Comparable>(filteredByPredicate predicate: @autoclosure () -> P, sortedBy sortKeyPath: KeyPath<Model, T>) -> AnyRandomAccessCollection<Model> where P.ResultType == Model {
        let filter = Query(predicate)
        let sortMode = ComparableKeyPath(sortKeyPath)
        return getElements(filteredBy: filter, sortedBy: sortMode, distinctUsing: nil)
    }

    public func getElements<T: Comparable>(sortedBy sortKeyPath: KeyPath<Model, T>) -> AnyRandomAccessCollection<Model> {
        let sortMode = ComparableKeyPath(sortKeyPath)
        return getElements(filteredBy: nil, sortedBy: sortMode, distinctUsing: nil)
    }

    public func getElements<U: Hashable>(distinctUsing distinctKeyPath: KeyPath<Model, U>) -> AnyRandomAccessCollection<Model> {
        let distinctMode = HashableKeyPath(distinctKeyPath)
        return getElements(filteredBy: nil, sortedBy: nil, distinctUsing: distinctMode)
    }

    public func getElements<P: Predicate, T: Comparable, U: Hashable>(filteredByPredicate predicate: @autoclosure () -> P, sortedBy sortKeyPath: KeyPath<Model, T>, distinctUsing distinctKeyPath: KeyPath<Model, U>) -> AnyRandomAccessCollection<Model> where P.ResultType == Model {
        let filter = Query(predicate)
        let sortMode = ComparableKeyPath(sortKeyPath)
        let distinctMode = HashableKeyPath(distinctKeyPath)
        return getElements(filteredBy: filter, sortedBy: sortMode, distinctUsing: distinctMode)
    }

}
