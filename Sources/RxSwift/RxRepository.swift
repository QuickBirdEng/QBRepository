//
//  RxRepository.swift
//  Fahrerclub
//
//  Created by Stefan Kofler on 10.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation
import RxSwift

extension AnyRepository {

    var rx: RxRepository<Model> {
        return RxRepository(self)
    }

}

class RxRepository<Model> {

    let base: AnyRepository<Model>

    public init(_ base: AnyRepository<Model>) {
        self.base = base
    }

    public func getAll() -> Single<AnyCollection<Model>> {
        return Single.create { single -> Disposable in
            self.base.getAll { models in
                single(.success(models))
            }

            return Disposables.create()
        }
    }

    public func getElements(fileredBy predicateFormat: String, _ args: Any...) -> Single<AnyCollection<Model>> {
        return Single.create { single -> Disposable in
            self.base.getElements(fileredBy: predicateFormat, args) { models in
                single(.success(models))
            }

            return Disposables.create()
        }
    }

    public func getElement<Id>(withId id: Id) -> Single<Model?> {
        return Single.create { single -> Disposable in
            self.base.getElement(withId: id) { models in
                single(.success(models))
            }

            return Disposables.create()
        }
    }

    public func create(_ model: Model, cascading: Bool) -> Single<Model> {
        return Single.create { single -> Disposable in
            self.base.create(model, cascading: cascading) { result in
                switch result {
                case .success(let model):
                    single(.success(model))
                case .error(let error):
                    single(.error(error))
                }
            }

            return Disposables.create()
        }
    }

    public func createMutiple(_ models: [Model], cascading: Bool) -> Single<[Model]> {
        return Single.create { single -> Disposable in
            self.base.create(models, cascading: cascading) { result in
                switch result {
                case .success(let models):
                    single(.success(models))
                case .error(let error):
                    single(.error(error))
                }
            }

            return Disposables.create()
        }
    }

    public func update(_ model: Model, cascading: Bool) -> Single<Model> {
        return Single.create { single -> Disposable in
            self.base.update(model, cascading: cascading) { result in
                switch result {
                case .success(let model):
                    single(.success(model))
                case .error(let error):
                    single(.error(error))
                }
            }

            return Disposables.create()
        }
    }

    public func delete(_ model: Model, cascading: Bool) -> Single<Void> {
        return Single.create { single -> Disposable in
            self.base.delete(model, cascading: cascading) { error in
                if let error = error {
                    single(.error(error))
                } else {
                    single(.success(()))
                }
            }

            return Disposables.create()
        }
    }

    public func deleteAll(cascading: Bool) -> Single<Void> {
        return Single.create { single -> Disposable in
            self.base.deleteAll(cascading: cascading) { error in
                if let error = error {
                    single(.error(error))
                } else {
                    single(.success(()))
                }
            }

            return Disposables.create()
        }
    }

}
