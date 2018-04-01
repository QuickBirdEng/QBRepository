//
//  FileSystemRepository.swift
//  Pods-QBRepository_Tests
//
//  Created by Stefan Kofler on 31.03.18.
//

import Foundation

public protocol IdentifiableCodable: Codable {
    associatedtype Id: Hashable

    var id: Id { get }
}

public class FileSystemRepository<Object: IdentifiableCodable>: Repository {
    public typealias Model = Object

    public enum Directory {
        case documents
        case caches
        case custom(URL)
    }

    private let directory: Directory
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder

    // swiftlint:disable:next force_try
    public init(directory: Directory = .documents, decoder: JSONDecoder = JSONDecoder(), encoder: JSONEncoder = JSONEncoder()) {
        self.directory = directory
        self.decoder = decoder
        self.encoder = encoder
    }

    public func getAll() -> AnyRandomAccessCollection<Model> {
        let url = getDirectoryURL()

        do {
            let files = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: [])
            let models = try files.flatMap { fileURL -> Model? in
                guard let data = FileManager.default.contents(atPath: fileURL.path) else { return nil }
                return try decoder.decode(Model.self, from: data)
            }

            return AnyRandomAccessCollection(models)
        } catch {
            return AnyRandomAccessCollection([])
        }
    }

    public func getElement<Id>(withId id: Id) -> Model? {
        guard let correctId = id as? Model.Id else { return nil }

        let fileURL = getURL(forId: String(correctId.hashValue))
        guard let data = FileManager.default.contents(atPath: fileURL.path) else { return nil }

        return try? decoder.decode(Model.self, from: data)
    }

    public func getElements(filteredBy filter: Query<Model>?, sortedBy sortKeyPath: ComparableKeyPath<Model>?, distinctUsing distinctKeyPath: HashableKeyPath<Model>?) -> AnyRandomAccessCollection<Model> {
        var objects = getAll()

        if let query = filter {
            let result = objects.filter { query.evaluate($0) }
            objects = AnyRandomAccessCollection(result)
        }

        if let sortKeyPath = sortKeyPath {
            let result = objects.sorted(by: sortKeyPath.isSmaller)
            objects = AnyRandomAccessCollection(result)
        }

        if let distinctKeyPath = distinctKeyPath {
            let grouped = Dictionary(grouping: objects, by: distinctKeyPath.hashValue)
            let result = grouped.values.flatMap { $0.first }
            objects = AnyRandomAccessCollection(result)
        }

        return AnyRandomAccessCollection(objects)
    }

    @discardableResult public func create(_ model: Model) -> RepositoryEditResult<Model> {
        let fileURL = getURL(forId: String(model.id.hashValue))
        let directoryURL = getDirectoryURL()

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
            let data = try encoder.encode(model)

            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            FileManager.default.createFile(atPath: fileURL.path, contents: data, attributes: nil)
            return .success(model)
        } catch {
            return .error(error)
        }
    }

    @discardableResult public func create(_ models: [Model]) -> RepositoryEditResult<[Model]> {
        let results = models.map(self.create)

        let firstError = results.first(where: { result in
            switch result {
            case .error(_):
                return false
            case .success(_):
                return true
            }
        })

        switch firstError {
        case let .some(.error(error)):
            return .error(error)
        default:
            return .success(models)
        }
    }

    @discardableResult public func update(_ model: Model) -> RepositoryEditResult<Model> {
        return create(model)
    }

    @discardableResult public func delete(_ model: Model) -> Error? {
        let fileURL = getURL(forId: String(model.id.hashValue))

        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult public func delete(_ models: [Model]) -> Error? {
        let results = models.map(self.delete)
        return results.flatMap({ $0 }).first
    }

    @discardableResult public func deleteAll() -> Error? {
        let directoryURL = getDirectoryURL()

        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: directoryURL, includingPropertiesForKeys: nil, options: [])

            for fileURL in fileURLs {
                try FileManager.default.removeItem(at: fileURL)
            }
            return nil
        } catch {
            return error
        }
    }

    @discardableResult public func performTranscation(_ transaction: () -> Void) -> Error? {
        transaction()
        return nil
    }

    // MARK: Helper

    fileprivate func getURL(forId id: String) -> URL {
        return getDirectoryURL().appendingPathComponent(id, isDirectory: false)
    }

    fileprivate func getDirectoryURL() -> URL {
        let folder = String(describing: Model.self)
        return FileSystemRepository.getURL(for: directory).appendingPathComponent(folder, isDirectory: true)
    }

    static fileprivate func getURL(for directory: Directory) -> URL {
        var searchPathDirectory: FileManager.SearchPathDirectory

        switch directory {
        case .documents:
            searchPathDirectory = .documentDirectory
        case .caches:
            searchPathDirectory = .cachesDirectory
        case .custom(let url):
            return url
        }

        if let url = FileManager.default.urls(for: searchPathDirectory, in: .userDomainMask).first {
            return url
        } else {
            fatalError("Could not create URL for specified directory!")
        }
    }

}
