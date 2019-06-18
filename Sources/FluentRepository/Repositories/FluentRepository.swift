import Vapor
import Fluent


/**
 # FluentRepository
 ------------
 
 The CRUD interface between a model and the database layer, this allows for easier
 testing and swapping the storage mechanism.
 
 
 */
public protocol FluentRepository {
    
    /// The database model the repository will interface with.
    associatedtype DBModel: Model
    
    /// The database that is associated with the database layer.
    associatedtype DB: Database
    
    /// The connection pool, used for connections to the database layer.
    var db: DB.ConnectionPool { get }
    
    /// Pagination configuration
    var pageConfig: RepositoryPaginationConfig { get }
    
    /// Retrieve all the models from the database layer.
    func all() -> Future<[DBModel]>
    
    /// Retrieve a certain page of models from the database layer,
    /// based on the `pageConfig.pageLimit`.
    func all(page: Int) throws -> Future<[DBModel]>
    
    /// Retrieve a single model by id.
    func find(id: DBModel.ID) -> Future<DBModel?>
    
    /// Save or update a model to the database layer.
    func save(_ entity: DBModel) -> Future<DBModel>
    
    /// Delete a moodel from the database layer.
    func delete(id: DBModel.ID) -> Future<Void>
    
    func withConnection<T>(_ closure: @escaping (DBModel.Database.Connection) throws -> Future<T>) -> Future<T>
    
}

// MARK:  Default implementations.
extension FluentRepository where DBModel.Database: QuerySupporting, DBModel.Database == DB {
    
    /// The default implementation, retrieves all the models.
    public func all() -> Future<[DBModel]> {
        return db.withConnection { conn in
            return DBModel.query(on: conn).all()
        }
    }
    
    /// The default implementation, retrieves a models by page.
    public func all(page: Int) throws -> Future<[DBModel]> {
        return db.withConnection { conn in
            return DBModel.query(on: conn)
                .range(try self.pageConfig.range(for: page))
                .all()
        }
    }
    
    /// The default implementation, retrieves an optional
    /// model by `id`.
    public func find(id: DBModel.ID) -> Future<DBModel?> {
        return db.withConnection { conn in
            return DBModel.find(id, on: conn)
        }
    }
    
    /// The default implementation, saves or updates a model.
    public func save(_ entity: DBModel) -> Future<DBModel> {
        return db.withConnection { conn in
            return entity.save(on: conn)
        }
    }
    
    /// The default implementation, removes a model by `id`.
    public func delete(id: DBModel.ID) -> Future<Void> {
        return db.withConnection { conn in
            return DBModel.find(id, on: conn).flatMap { user in
                guard let user = user else {
                    throw Abort(.notFound)
                }
                return user.delete(on: conn)
            }
        }
    }
    
    public func withConnection<T>(_ closure: @escaping (DB.Connection) throws -> Future<T>) -> Future<T> {
        return db.withConnection(closure)
    }
    
}

