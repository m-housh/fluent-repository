//
//  VaporTestCase.swift
//  FluentRepositoryTests
//
//  Created by Michael Housh on 3/15/19.
//

import Vapor
import FluentSQLite
import XCTest
import VaporTestable

@testable import FluentRepository


/// A fluent model for our tests.
struct User: SQLiteModel, Migration, Parameter, Content {
    var id: Int?
    var name: String
    
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

/// A concrete base repository class for sqlite.
class SQLiteBaseRepository<M, R>: Repository<M> where M: Model, M.Database == SQLiteDatabase { }

extension SQLiteBaseRepository: ServiceType {
    
    static func makeService(for container: Container) throws -> Self {
        let db = try container.connectionPool(to: .sqlite)
        return try .init(db, on: container)
        
    }
    
    static var serviceSupports: [Any.Type] {
        return [R.self]
    }
}


// Representation of a `User` repository for our tests.
protocol UserRepository {
    
    func all() -> Future<[User]>
    func find(id: Int) -> Future<User?>
    func save(_ user: User) -> Future<User>
    func delete(id: Int) -> Future<Void>
    /// optional
    func withConnection<T>(_ closure: @escaping (User.Database.Connection) throws -> Future<T>) -> Future<T>
}

/// Concrete sqlite version of a `UserRepository`.
final class SQLiteUserRepository: SQLiteBaseRepository<User, UserRepository> { }

extension SQLiteUserRepository: UserRepository { }


/// An api route controller for our `UserRepository`.
final class UserController: RepositoryController<SQLiteUserRepository> { }

extension UserController: RouteCollection { }

/// Pagination configuration for our tests.
struct TestPaginationConfig: RepositoryPaginationConfig {
    var pageLimit: Int = 2
}

extension TestPaginationConfig: ServiceType {
    
    static func makeService(for container: Container) throws -> TestPaginationConfig {
        return TestPaginationConfig()
    }
}

/// Our base test case.  Sets up a vapor application that
/// can be used for our tests.
class VaporTestCase: XCTestCase, VaporTestable {
    
    var app: Application!
    
    override func setUp() {
        perform {
            self.app = try makeApplication()
        }
    }
    
    func revert() throws {
        perform {
            try self.revert()
        }
    }
    
    func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
        
        /// Register providers first.
        try services.register(FluentSQLiteProvider())
        try services.register(FluentRepositoryProvider())
        
        services.register(SQLiteUserRepository.self)
        config.prefer(SQLiteUserRepository.self, for: UserRepository.self)
        
        services.register(TestPaginationConfig.self)
        
        services.register(Router.self) { container -> EngineRouter in
            let router = EngineRouter.default()
            try self.routes(router, container)
            return router
        }
        
        // Configure a SQLite database
        let sqlite = try SQLiteDatabase(storage: .memory)
        
        // Register the configured SQLite database to the database config.
        var databases = DatabasesConfig()
        databases.add(database: sqlite, as: .sqlite)
        //databases.enableLogging(on: .sqlite)
        services.register(databases)
        
        var middlewares = MiddlewareConfig.default()
        middlewares.use(ErrorMiddleware.self)
        services.register(middlewares)
        
        var migrations = MigrationConfig()
        migrations.add(model: User.self, database: .sqlite)
        services.register(migrations)
        
        config.prefer(TestPaginationConfig.self, for: RepositoryPaginationConfig.self)
    }
    
    func routes(_ router: Router, _ container: Container) throws {
        //let repo = try container.make(UserRepository.self)
        try router.register(collection: try UserController("/user", on: container))
    }

}

