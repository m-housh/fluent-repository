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
    func range(for page: Int) -> Range<Int>
}

// MARK: Default Implementations
extension RepositoryPaginationConfig {
        
    public func range(for page: Int) -> Range<Int> {
        let start = (page - 1) * pageLimit
        let end = start + pageLimit
        return Range(start...end)
    }
}

// MARK: ServiceType
extension RepositoryPaginationConfig where Self: ServiceType {
    
    public static var serviceSupports: [Any.Type] {
        return [RepositoryPaginationConfig.self]
    }
    
}
