//
//  Database+ConnectionPool.swift
//  FluentRepository
//
//  Created by Michael Housh on 3/15/19.
//

import Vapor

extension Database {
    
    /// A connection pool to the database, used for the
    /// `Repository` protocol.
    public typealias ConnectionPool = DatabaseConnectionPool<ConfiguredDatabase<Self>>
}
