//
//  RepositoryPaginationConfig.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/23/19.
//

import Vapor

/**
 # RepositoryPaginationConfig
 -----
 
 Configuration of pagination for repository queries.
 
*/
public protocol RepositoryPaginationConfig {
    
    /// The number of items per page.
    var pageLimit: Int { get }
    
    /// Generates the range for a specific page.
    func range(for page: Int) throws -> Range<Int>
}

// MARK: Default Implementations
extension RepositoryPaginationConfig {
        
    public func range(for page: Int) throws -> Range<Int> {
        
        guard page > 0 else {
            throw PaginationError.invalidPage
        }
        
        let start: Int
        let end: Int
        
        switch page {
        case 1:
            start = 0
            end = pageLimit - 1
        default:
            start = (page - 1) * pageLimit
            end = start + (pageLimit - 1)
        }
        //let start = (page - 1) * pageLimit
        //let end = start + pageLimit
        return Range(start...end)
    }
}

// MARK: ServiceType
extension RepositoryPaginationConfig where Self: ServiceType {
    
    public static var serviceSupports: [Any.Type] {
        return [RepositoryPaginationConfig.self]
    }
    
}
