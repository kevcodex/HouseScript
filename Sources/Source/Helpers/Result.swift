//
//  Result.swift
//  FOXNOW
//
//  Created by Kevin Chen on 5/7/18.
//

import Foundation

/// Generic result type
public enum Result<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
    
    init(value: T) {
        self = .success(value)
    }
    
    init(error: Error) {
        self = .failure(error)
    }
}
