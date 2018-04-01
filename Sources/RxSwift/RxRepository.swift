//
//  RxRepository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation
import RxSwift

public extension AnyRepository {

    var rx: RxRepository<Model> {
        return RxRepository(self)
    }

}

public class RxRepository<Model> {

    let base: AnyRepository<Model>

    public init(_ base: AnyRepository<Model>) {
        self.base = base
    }

    public func getAll() -> Single<AnyRandomAccessCollection<Model>> {
        return Single.create { single -> Disposable in
            let models = self.base.getAll()
            single(.success(models))
            return Disposables.create()
        }
    }

    public func getElement<Id>(withId id: Id) -> Single<Model?> {
        return Single.create { single -> Disposable in
            let model = self.base.getElement(withId: id)
            single(.success(model))
            return Disposables.create()
        }
    }

    public func getElements(filteredBy filter: Query<Model>? = nil, sortedBy sortMode: ComparableKeyPath<Model>? = nil) -> Single<AnyRandomAccessCollection<Model>> {
        return Single.create { single -> Disposable in
            let models = self.base.getElements(filteredBy: filter, sortedBy: sortMode, distinctUsing: nil)
            single(.success(models))
            return Disposables.create()
        }
    }

    public func create(_ model: Model, cascading: Bool) -> Single<Model> {
        return Single.create { single -> Disposable in
            let result = self.base.create(model)

            switch result {
            case .success(let model):
                single(.success(model))
            case .error(let error):
                single(.error(error))
            }

            return Disposables.create()
        }
    }

    public func createMutiple(_ models: [Model], cascading: Bool) -> Single<[Model]> {
        return Single.create { single -> Disposable in
            let result = self.base.create(models)

            switch result {
            case .success(let models):
                single(.success(models))
            case .error(let error):
                single(.error(error))
            }

            return Disposables.create()
        }
    }

    public func update(_ model: Model, cascading: Bool) -> Single<Model> {
        return Single.create { single -> Disposable in
            let result = self.base.update(model)

            switch result {
            case .success(let model):
                single(.success(model))
            case .error(let error):
                single(.error(error))
            }

            return Disposables.create()
        }
    }

    public func delete(_ model: Model, cascading: Bool) -> Single<Void> {
        return Single.create { single -> Disposable in
            if let error = self.base.delete(model) {
                single(.error(error))
            } else {
                single(.success(()))
            }

            return Disposables.create()
        }
    }

    public func deleteMultiple(_ models: [Model], cascading: Bool) -> Single<Void> {
        return Single.create { single -> Disposable in
            if let error = self.base.delete(models) {
                single(.error(error))
            } else {
                single(.success(()))
            }

            return Disposables.create()
        }
    }

    public func deleteAll(cascading: Bool) -> Single<Void> {
        return Single.create { single -> Disposable in
            if let error = self.base.deleteAll() {
                single(.error(error))
            } else {
                single(.success(()))
            }

            return Disposables.create()
        }
    }

}
