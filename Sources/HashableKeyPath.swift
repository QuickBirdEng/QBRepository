//
//  HashableKeyPath.swift
//  QBRepository
//
//  Created by Stefan Kofler on 01.04.18.
//

import Foundation

public class HashableKeyPath<Model> {

    private let _hashValue: (Model) -> Int
    private let _string: () -> String

    public init<T: Hashable>(_ keyPath: KeyPath<Model, T>) {
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
