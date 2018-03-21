//
//  Repository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation

public enum RepositoryEditResult<Model> {
    case success(Model)
    case error(Error)
}

public protocol Repository {
    associatedtype Model

    func getAll(_ completion: (AnyCollection<Model>) -> Void)
    func getElements(filteredBy predicateFormat: String, _ args: Any..., completion: (AnyCollection<Model>) -> Void)
    func getElements(filteredBy predicate: NSPredicate, completion: (AnyCollection<Model>) -> Void)
    func getElement<Id>(withId id: Id, _ completion: (Model?) -> Void)
    func create(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void)
    func create(_ models: [Model], _ completion: (RepositoryEditResult<[Model]>) -> Void)
    func update(_ model: Model, _ completion: (RepositoryEditResult<Model>) -> Void)
    func delete(_ model: Model, _ completion: (Error?) -> Void)
    func deleteAll(_ completion: (Error?) -> Void)
    func performTranscation(_ transaction: () -> Void)
}
