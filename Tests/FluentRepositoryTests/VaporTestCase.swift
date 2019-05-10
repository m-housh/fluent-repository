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

struct User: SQLiteModel, Migration, Parameter, Content {
    var id: Int?
    var name: String
    
    init(id: Int? = nil, name: String) {
        self.id = id
        self.name = name
    }
}

class SQLiteBaseRepository<M, R>: BaseRepository<M, SQLiteDatabase> where M: Model, M.Database == SQLiteDatabase { }

extension SQLiteBaseRepository: ServiceType {
    
    static func makeService(for container: Container) throws -> Self {
        return .init(try container.connectionPool(to: .sqlite))
    }
    
    static var serviceSupports: [Any.Type] {
        return [R.self]
    }
}


protocol UserRepository {
    
    func all() -> Future<[User]>
    func find(id: Int) -> Future<User?>
    func save(_ user: User) -> Future<User>
    func delete(id: Int) -> Future<Void>
}

final class SQLiteUserRepository: SQLiteBaseRepository<User, UserRepository> { }

extension SQLiteUserRepository: UserRepository { }

final class UserController: BasicRepositoryController<SQLiteUserRepository> { }

extension UserController: RouteCollection { }


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
        
        services.register(SQLiteUserRepository.self)
        config.prefer(SQLiteUserRepository.self, for: UserRepository.self)
        
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
    }
    
    func routes(_ router: Router, _ container: Container) throws {
        //let repo = try container.make(UserRepository.self)
        try router.register(collection: try UserController("/user", on: container))
    }

}

