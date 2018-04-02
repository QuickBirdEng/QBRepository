//
//  Operators.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

// MARK: Logical Operators

public func && <Model>(lhs: AnyPredicate<Model>, rhs: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return AnyPredicate(AndPredicate(left: lhs, right: rhs))
}

public func || <Model>(lhs: AnyPredicate<Model>, rhs: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return AnyPredicate(OrPredicate(left: lhs, right: rhs))
}

public prefix func ! <Model>(predicate: AnyPredicate<Model>) -> AnyPredicate<Model> {
    return AnyPredicate(NotPredicate(original: predicate))
}

// MARK: EquatableProperty
public func == <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
}

public func != <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    let equalPredicate = AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(NotPredicate(original: equalPredicate))
}

public func ~= <Model, Property: RegexMatchableProperty>(lhs: KeyPath<Model, Property>, rhs: String) -> AnyPredicate<Model> {
    return AnyPredicate(RegexPredicate(keyPath: lhs, pattern: rhs))
}

public func << <Model, Property: RegexMatchableProperty>(lhs: KeyPath<Model, Property>, rhs: String) -> AnyPredicate<Model> {
    return AnyPredicate(StringContainsPredicate(keyPath: lhs, otherString: rhs))
}

public func << <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property>, rhs: [Property]) -> AnyPredicate<Model> {
    return AnyPredicate(InPredicate(keyPath: lhs, properties: rhs))
}

// MARK: Optional<EquatableProperty>
public func == <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return AnyPredicate(EqualOptionalPredicate(keyPath: lhs, property: rhs))
}

public func != <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    let equalPredicate = AnyPredicate(EqualOptionalPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(NotPredicate(original: equalPredicate))
}

public func ~= <Model, Property: RegexMatchableProperty>(lhs: KeyPath<Model, Property?>, rhs: String) -> AnyPredicate<Model> {
    return AnyPredicate(RegexPredicate(keyPath: lhs, pattern: rhs))
}

public func << <Model, Property: EquatableProperty>(lhs: KeyPath<Model, Property?>, rhs: [Property]) -> AnyPredicate<Model> {
    return AnyPredicate(InPredicate(keyPath: lhs, properties: rhs))
}

// MARK: ComparableProperty
public func < <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    return AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
}

public func > <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    let equalPredicate = AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
    let orPredicate = AnyPredicate(OrPredicate(left: smallerPredicate, right: equalPredicate))
    return AnyPredicate(NotPredicate(original: orPredicate))
}

public func <= <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    let equalPredicate = AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(OrPredicate(left: smallerPredicate, right: equalPredicate))
}

public func >= <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: Property) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(NotPredicate(original: smallerPredicate))
}

public func << <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: ClosedRange<Property>) -> AnyPredicate<Model> {
    return AnyPredicate(ClosedRangePredicate(keyPath: lhs, range: rhs))
}

public func << <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property>, rhs: CountableClosedRange<Property>) -> AnyPredicate<Model> {
    return AnyPredicate(ClosedRangePredicate(keyPath: lhs, range: ClosedRange(rhs)))
}

// MARK: Optional<ComparableProperty>
public func < <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    return AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
}

public func > <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    let equalPredicate = AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
    let orPredicate = AnyPredicate(OrPredicate(left: smallerPredicate, right: equalPredicate))
    return AnyPredicate(NotPredicate(original: orPredicate))
}
public func <= <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    let equalPredicate = AnyPredicate(EqualPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(OrPredicate(left: smallerPredicate, right: equalPredicate))
}

public func >= <Model, Property: ComparableProperty>(lhs: KeyPath<Model, Property?>, rhs: Property?) -> AnyPredicate<Model> {
    let smallerPredicate = AnyPredicate(SmallerPredicate(keyPath: lhs, property: rhs))
    return AnyPredicate(NotPredicate(original: smallerPredicate))
}
