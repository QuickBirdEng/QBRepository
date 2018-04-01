//
//  RepositoryEditResult.swift
//  QBRepository
//
//  Created by Stefan Kofler on 01.04.18.
//

import Foundation

public enum RepositoryEditResult<Model> {
    case success(Model)
    case error(Error)
}
