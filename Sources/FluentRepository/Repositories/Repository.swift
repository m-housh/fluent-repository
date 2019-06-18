//
//  BaseRepository.swift
//  FluentRepository
//
//  Created by Michael Housh on 3/15/19.
//

import Vapor
import Fluent


/**
 # BaseRepository
 ----------------
 
 Implements the basic `Repository` methods, so classes that inherit from this class don't need to implement, unless they need to over-ride.  This is alsoo needed for access to the default `Repository` implementations.
 
 ## Usage
 ---------
 
 Create a protocol for the specific model.
 ````
 protocol UserRepository {
 
 func all() -> Future<[User]>
 func find(id: UUID) -> Future<User?>
 func save(_ user: User) -> Future<User>
 func delete(id: UUID) -> Future<Void>
 }
 
 // Create a sub-class for your model.
 
 class SQLiteUserRepository: BaseRepository<User>, UserRepository {
 // This will have all default CRUD methods implemented,
 // add overrides / custom methods.
 ...
 }
 
 ````
 
 Resgister the repository in your configuration.
 ### repositories.swift
 ````
 services.register(SQLiteUserRepository.self)
 config.prefer(SQLiteUserRepository.self, for: UserRepository.self)
 ````
 
 */
open class Repository<T>: FluentRepository where T: Model {
    
    /// The database model to interface with.
    /// - seealso: `FluentRepository` protocol.
    public typealias DBModel = T
    public typealias DB = T.Database
    
    /// The database connection pool.
    /// - seealso: `FluentRepository` protocol.
    public let db: DB.ConnectionPool
    public let pageConfig: RepositoryPaginationConfig
    
    /// - parameter db: The database connection.
    /// - seealso: `FluentRepository` protocol.
    public required init<C>(_ db: C, on worker: Container) throws where C: DatabaseConnectionPool<ConfiguredDatabase<DB>> {
        
        self.pageConfig = try worker.make(RepositoryPaginationConfig.self)
        self.db = db
    }
}
