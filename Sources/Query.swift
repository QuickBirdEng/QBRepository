//
//  Query.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public class Query<Model> {
    var predicates: [AnyPredicate<Model>] = []

    public init<P: Predicate>(_ predicate: @autoclosure () -> P) where P.ResultType == Model {
        predicates.append(AnyPredicate(predicate()))
    }

    public func add<P: Predicate>(_ predicate: @autoclosure () -> P) -> Query where P.ResultType == Model {
        predicates.append(AnyPredicate(predicate()))
        return self
    }

    func createPredicate() -> NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: predicates.map { $0.predicate })
    }

    func evaluate(_ model: Model) -> Bool {
        return predicates
            .map { $0.evaluate(model) }
            .reduce(true) { $0 && $1 }
    }
}
