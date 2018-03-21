//
//  Realm+Cascade.swift
//  Fahrerclub
//
//  Created by Julian Bissekkou (Quickbird Studios) on 12.03.18.
//  Copyright © 2018 Zeppelin GmbH. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

protocol CascadeDeleting: class {
    func delete<S: Sequence>(_ objects: S, cascade: Bool) where S.Iterator.Element: Object
    func delete<Entity: Object>(_ entity: Entity, cascade: Bool)

    func add<S: Sequence>(_ objects: S, cascade: Bool, update: Bool) where S.Iterator.Element: Object
    func add<Entity: Object>(_ entity: Entity, cascade: Bool, update: Bool)
}

extension Realm: CascadeDeleting {

    func delete<S: Sequence>(_ objects: S, cascade: Bool) where S.Iterator.Element: Object {
        for object in objects {
            delete(object, cascade: cascade)
        }
    }

    func delete<Entity: Object>(_ entity: Entity, cascade: Bool) {
        if cascade {
            cascadeDelete(entity)
        } else {
            delete(entity)
        }
    }

    func add<S: Sequence>(_ objects: S, cascade: Bool, update: Bool) where S.Iterator.Element: Object {
        for object in objects {
            add(object, cascade: cascade, update: update)
        }
    }

    func add<Entity: Object>(_ entity: Entity, cascade: Bool, update: Bool) {
        if cascade {
            cascadeDeleteSubtypes(entity)
        }

        add(entity, update: update)
    }

}

private extension Realm {

    private func cascadeDelete(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }

        var toBeDeleted = Set<RLMObjectBase>()
        toBeDeleted.insert(entity)

        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object, !element.isInvalidated else { continue }
            resolve(element: element, deleteMainItem: true, toBeDeleted: &toBeDeleted)
        }
    }

    private func cascadeDeleteSubtypes(_ entity: RLMObjectBase) {
        guard let entity = entity as? Object else { return }

        var toBeDeleted = Set<RLMObjectBase>()
        resolve(element: entity, deleteMainItem: false, toBeDeleted: &toBeDeleted)

        while !toBeDeleted.isEmpty {
            guard let element = toBeDeleted.removeFirst() as? Object, !element.isInvalidated else { continue }
            resolve(element: element, deleteMainItem: true, toBeDeleted: &toBeDeleted)
        }
    }

    private func resolve(element: Object, deleteMainItem: Bool, toBeDeleted: inout Set<RLMObjectBase>) {
        for property in element.objectSchema.properties {
            guard let value = element.value(forKey: property.name) else { continue }

            if let entity = value as? RLMObjectBase {
                toBeDeleted.insert(entity)
            } else if let list = value as? RealmSwift.ListBase {
                for index in 0..<list._rlmArray.count {
                    if let object = list._rlmArray.object(at: index) as? RLMObjectBase {
                        toBeDeleted.insert(object)
                    }
                }
            }
        }

        if deleteMainItem {
            element.realm?.delete(element)
        }
    }

}
