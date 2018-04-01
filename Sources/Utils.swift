//
//  Utils.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public enum RepositoryEditResult<Model> {
    case success(Model)
    case error(Error)
}

public enum RepositoryDistinctMode<Model> {
    case stringKeyPath(String)
    case swiftKeyPath(HashableKeyPath<Model>)

    public static func keyPath(_ keyPath: String) -> RepositoryDistinctMode<Model> {
        return .stringKeyPath(keyPath)
    }

    public static func keyPath<T: Hashable>(_ keyPath: KeyPath<Model, T>) -> RepositoryDistinctMode<Model> {
        return .swiftKeyPath(HashableKeyPath(keyPath))
    }
}

public class ComparableKeyPath<Model> {

    private let _isSmaller: (Model, Model) -> Bool
    private let _string: () -> String

    init<T: Comparable>(_ keyPath: KeyPath<Model, T>) {
        _isSmaller = { obj1, obj2 in
            obj1[keyPath: keyPath] < obj2[keyPath: keyPath]
        }

        _string = {
            return keyPath._kvcKeyPathString! as String
        }
    }

    func isSmaller(obj1: Model, obj2: Model) -> Bool {
        return _isSmaller(obj1, obj2)
    }

    func string() -> String {
        return _string()
    }

}

public class HashableKeyPath<Model> {

    private let _hashValue: (Model) -> Int
    private let _string: () -> String

    init<T: Hashable>(_ keyPath: KeyPath<Model, T>) {
        _hashValue = { obj in
            return obj[keyPath: keyPath].hashValue
        }

        _string = {
            return keyPath._kvcKeyPathString! as String
        }
    }

    func hashValue(obj: Model) -> Int {
        return _hashValue(obj)
    }

    func string() -> String {
        return _string()
    }

}

public func unwrapArgs(_ args: [Any]) -> [Any] {
    let unrwappedArgs = args.flatMap { arg -> [Any] in
        if let arg = arg as? [Any] {
            return arg
        } else {
            return [arg]
        }
    }

    return unrwappedArgs
}
