//
//  ComparableKeyPath.swift
//  QBRepository
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

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
