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
    associatedtype DB: Database
    
    /// The connection pool, used for connections to the database layer.
    var db: DB.ConnectionPool { get }
    
    //init(_ db: DatabaseConnectionPool<ConfiguredDatabase<DB>>)
    
    func all() -> Future<[DBModel]>
    func find(id: DBModel.ID) -> Future<DBModel?>
    func save(_ entity: DBModel) -> Future<DBModel>
    func delete(id: DBModel.ID) -> Future<Void>
    
}

extension FluentRepository where DBModel.Database: QuerySupporting {
    
    /// The default implementation, retrieves all the models.
    public func all() -> Future<[DBModel]> {
        return db.withConnection { conn in
            return DBModel.query(on: conn).all()
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
    
}
