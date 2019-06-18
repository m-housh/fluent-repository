//
//  PaginationError.swift
//  FluentRepository
//
//  Created by Michael Housh on 6/17/19.
//

import Vapor


/**
 # PaginationError
 ------
 
 Errors related to pagination configuration or query errors.
 
*/
public enum PaginationError: FluentRepositoryError {
    
    case invalidPageLimit
    case invalidPage

}

extension PaginationError: Debuggable {
    public var reason: String {
        switch self {
        case .invalidPageLimit:
            return "Page limit must be above 0."
        case .invalidPage:
            return "Page must be above 0."
        }
    }
    
    
    public var identifier: String {
        switch self {
        case .invalidPageLimit:
            return "Invalid Page Limit"
        case .invalidPage:
            return "Invalid Page"
        }
    }
}
