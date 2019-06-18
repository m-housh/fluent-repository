//
//  DefaultPaginationConfig.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/23/19.
//

import Vapor


public final class DefaultPaginationConfig: RepositoryPaginationConfig {
    
    /// The limit of items per page.
    /// - seealso: `RepositoryPaginationConfig`
    public let pageLimit: Int
    
    public init(pageLimit: Int = 25) throws {
        
        guard pageLimit > 0 else {
            throw PaginationError.invalidPageLimit
        }
        
        self.pageLimit = pageLimit
    }
}

// MARK: Service Type
extension DefaultPaginationConfig: ServiceType {
    
    public static func makeService(for container: Container) throws -> DefaultPaginationConfig {
        return try DefaultPaginationConfig()
    }
}
