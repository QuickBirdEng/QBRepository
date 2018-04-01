//
//  ManagedObjectProperty.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public protocol ManagedObjectProperty {
    var _object: AnyObject { get }
}

public protocol EquatableProperty: ManagedObjectProperty, Equatable {}
public protocol ComparableProperty: EquatableProperty, Comparable {}
public protocol RegexMatchableProperty: ManagedObjectProperty {}

extension Optional: ManagedObjectProperty where Wrapped: ManagedObjectProperty {
    public var _object: AnyObject {
        switch self {
        case .none:
            return NSNull()
        case .some(let wrapped):
            return wrapped._object
        }
    }
}

extension Optional: EquatableProperty where Wrapped: EquatableProperty {}
extension Optional: RegexMatchableProperty where Wrapped: RegexMatchableProperty {}

extension Optional: Comparable, ComparableProperty where Wrapped: ComparableProperty {
    public static func < (lhs: Optional<Wrapped>, rhs: Optional<Wrapped>) -> Bool {
        switch (lhs, rhs) {
        case let (l?, r?):
            return l < r
        case (nil, _?):
            return true
        default:
            return false
        }
    }
}

extension Bool: EquatableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Int16: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Int32: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Int64: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Int: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Float: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension Double: ComparableProperty {
    public var _object: AnyObject { return NSNumber(value: self) }
}
extension NSDecimalNumber: ComparableProperty {
    public static func < (lhs: NSDecimalNumber, rhs: NSDecimalNumber) -> Bool {
        return lhs.decimalValue < rhs.decimalValue
    }

    public var _object: AnyObject { return self }
}
extension Date: ComparableProperty {
    public var _object: AnyObject { return self as NSDate }
}
extension NSDate: ComparableProperty {
    public static func < (lhs: NSDate, rhs: NSDate) -> Bool {
        return lhs.compare(rhs as Date) == .orderedAscending
    }

    public var _object: AnyObject { return self }
}

extension String: EquatableProperty, RegexMatchableProperty {
    public var _object: AnyObject { return self as NSString }
}
extension NSString: EquatableProperty, RegexMatchableProperty {
    public var _object: AnyObject { return self }
}
extension Data: EquatableProperty {
    public var _object: AnyObject { return self as NSData }
}
extension NSData: EquatableProperty {
    public var _object: AnyObject { return self }
}
extension URL: EquatableProperty {
    public var _object: AnyObject { return self as NSURL }
}
extension NSURL: EquatableProperty {
    public var _object: AnyObject { return self }
}
extension UUID: EquatableProperty {
    public var _object: AnyObject { return self as NSUUID }
}
extension NSUUID: EquatableProperty {
    public var _object: AnyObject { return self }
}
