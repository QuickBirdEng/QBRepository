//
//  Utils.swift
//  Pods-QBRepository_Tests
//
//  Created by Stefan Kofler on 24.03.18.
//

import Foundation

public enum RepositoryEditResult<Model> {
    case success(Model)
    case error(Error)
}

public enum RepositoryFilter {
    case predicate(NSPredicate)
    case string(String, [Any])

    public static func predicateString(_ predicateFormat: String, _ args: Any...) -> RepositoryFilter {
        return .string(predicateFormat, unwrapArgs(args))
    }
}

public enum RepositorySortMode<Model> {
    case stringKeyPath(String, Bool)
    case swiftKeyPath(PartialKeyPath<Model>, Bool)

    public static func keyPath(_ keyPath: String, ascending: Bool = true) -> RepositorySortMode<Model> {
        return .stringKeyPath(keyPath, ascending)
    }

    public static func keyPath(_ keyPath: PartialKeyPath<Model>, ascending: Bool = true) -> RepositorySortMode<Model> {
        return .swiftKeyPath(keyPath, ascending)
    }
}

public enum RepositoryDistinctMode<Model> {
    case stringKeyPath(String)
    case swiftKeyPath(PartialKeyPath<Model>)

    public static func keyPath(_ keyPath: String) -> RepositoryDistinctMode<Model> {
        return .stringKeyPath(keyPath)
    }

    public static func keyPath(_ keyPath: PartialKeyPath<Model>) -> RepositoryDistinctMode<Model> {
        return .swiftKeyPath(keyPath)
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
