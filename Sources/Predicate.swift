//
//  Predicate.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public protocol Predicate {
    associatedtype ResultType
    var predicate: NSPredicate { get }
    func evaluate(_ model: ResultType) -> Bool
}

public struct AnyPredicate<Model>: Predicate {
    public typealias ResultType = Model

    private let _predicate: () -> NSPredicate
    private let _evaluate: (ResultType) -> Bool

    init<T: Predicate>(_ predicate: T) where T.ResultType == Model {
        _predicate = { predicate.predicate }
        _evaluate = predicate.evaluate
    }

    public var predicate: NSPredicate {
        return _predicate()
    }

    public func evaluate(_ model: Model) -> Bool {
        return _evaluate(model)
    }
}

public struct EqualPredicate<ManagedObject, Property: EquatableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let property: Property

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, property._object])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return model[keyPath: keyPath] == property
    }
}

public struct EqualOptionalPredicate<ManagedObject, Property: EquatableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property?>
    let property: Property?

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K == %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, property?._object ?? NSNull()])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return model[keyPath: keyPath] == property
    }
}

public struct SmallerPredicate<ManagedObject, Property: ComparableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let property: Property

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K < %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, property._object])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return model[keyPath: keyPath] < property
    }
}

public struct InPredicate<ManagedObject, Property: EquatableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let properties: [Property]

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K IN %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, properties.map { $0._object } as NSArray])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return properties.contains(model[keyPath: keyPath])
    }
}

public struct RegexPredicate<ManagedObject, Property: RegexMatchableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let pattern: String

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K LIKE %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, pattern])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        let regex = try? NSRegularExpression(pattern: pattern, options: [])
        let string = String(describing: model[keyPath: keyPath])
        let firstMatch = regex?.firstMatch(in: string, options: [], range: NSRange(location: 0, length: string.utf16.count))
        return firstMatch != nil
    }
}

public struct ClosedRangePredicate<ManagedObject, Property: ComparableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let range: ClosedRange<Property>

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K BETWEEN %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, [range.lowerBound, range.upperBound] as NSArray])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return range.contains(model[keyPath: keyPath])
    }
}

public struct StringContainsPredicate<ManagedObject, Property: RegexMatchableProperty>: Predicate {
    public typealias ResultType = ManagedObject

    let keyPath: KeyPath<ManagedObject, Property>
    let otherString: String

    public var predicate: NSPredicate {
        return NSPredicate(format: "%K CONTAINTS[cd] %@", argumentArray: [keyPath._kvcKeyPathString! as NSString, otherString])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        guard let string = model[keyPath: keyPath] as? String else { return false }
        return string.lowercased().contains(otherString.lowercased())
    }
}

public struct EmptyPredicate<ManagedObject>: Predicate {
    public typealias ResultType = ManagedObject

    public init() {}

    public var predicate: NSPredicate {
        return NSPredicate(value: true)
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return true
    }
}

public struct AndPredicate<ManagedObject>: Predicate {
    public typealias ResultType = ManagedObject

    let left: AnyPredicate<ResultType>
    let right: AnyPredicate<ResultType>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .and, subpredicates: [left.predicate, right.predicate])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return left.evaluate(model) && right.evaluate(model)
    }

    public static func compoundPredicate<T>(of predicates: [AnyPredicate<T>]) -> AnyPredicate<T> {
        guard let firstPredicate = predicates.first else { return AnyPredicate(EmptyPredicate<T>()) }
        return firstPredicate && compoundPredicate(of: Array(predicates.dropFirst()))
    }
}

public struct OrPredicate<ManagedObject>: Predicate {
    public typealias ResultType = ManagedObject

    let left: AnyPredicate<ResultType>
    let right: AnyPredicate<ResultType>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(type: .or, subpredicates: [left.predicate, right.predicate])
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return left.evaluate(model) || right.evaluate(model)
    }

    public static func compoundPredicate<T>(of predicates: [AnyPredicate<T>]) -> AnyPredicate<T> {
        guard let firstPredicate = predicates.first else { return AnyPredicate(EmptyPredicate<T>()) }
        return firstPredicate || compoundPredicate(of: Array(predicates.dropFirst()))
    }
}

public struct NotPredicate<ManagedObject>: Predicate {
    public typealias ResultType = ManagedObject

    let original: AnyPredicate<ResultType>

    public var predicate: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: original.predicate)
    }

    public func evaluate(_ model: ManagedObject) -> Bool {
        return !original.evaluate(model)
    }
}
