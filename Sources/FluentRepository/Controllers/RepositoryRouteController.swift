//
//  RepositoryRouteController.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/10/19.
//

import Vapor


/**
 # RepositoryRouteController
 ------
 
 Handles api routes using a `FluentRepository`.
 
*/
public protocol RepositoryRouteController {
    
    /// The `FluentRepository` type used for database queries.
    associatedtype Repository: FluentRepository
    
    /// The return type, this is typically the database model.
    associatedtype ReturnType: Content
    
    /// The concrete `FluentRepository`.
    var repository: Repository { get }
    
    /// A path to register the api routes.
    var path: String { get }
    
    /// Get all the database models.
    func all(_ request: Request) throws -> Future<[ReturnType]>
    
    /// Get a database model by `id`.
    func find(_ request: Request) throws -> Future<ReturnType>
    
    /// Create or Update a database model.
    func save(_ request: Request, model: Repository.DBModel) throws -> Future<ReturnType>
    
    /// Delete a database model.
    func delete(_ request: Request) throws -> Future<HTTPStatus>
}

extension RepositoryRouteController where Self: RouteCollection, Repository.DBModel: Parameter, Repository.DBModel: RequestDecodable {
    
    public func boot(router: Router) {
        router.get(path, use: all)
        router.post(Repository.DBModel.self, at: path, use: save)
        router.get(path, Repository.DBModel.parameter, use: find)
        router.delete(path, Repository.DBModel.parameter, use: delete)
    }
}



public class BasicRepositoryController<R>: RepositoryRouteController where R: FluentRepository, R.DBModel: Content, R.DBModel: Parameter, R.DBModel.ResolvedParameter == Future<R.DBModel>, R: Service {
    
    public typealias Repository = R
    public typealias ReturnType = R.DBModel
    
    public let repository: R
    public let path: String
    
    public required init(_ path: String = "/", on worker: Container) throws {
        self.path = path
        self.repository = try worker.make(R.self)
    }
    
    public func all(_ request: Request) throws -> EventLoopFuture<[ReturnType]> {
        
        let pageQuery = try request.query.decode(DefaultPaginationQuery.self)
        
        guard let page = pageQuery.page else {
            return repository.all()
        }
        
        return repository.all(page: page)
    }
    
    public func save(_ request: Request, model: Repository.DBModel) throws -> EventLoopFuture<ReturnType> {
        return repository.save(model)
    }
    
    public func find(_ request: Request) throws -> EventLoopFuture<ReturnType> {
        return try request.parameters.next(Repository.DBModel.self)
    }
    
    public func delete(_ request: Request) throws -> EventLoopFuture<HTTPStatus> {
        return try request.parameters.next(Repository.DBModel.self).flatMap { model in
            return self.repository.delete(id: try model.requireID())
            }
            .transform(to: .ok)
    }
}

extension BasicRepositoryController: Service where R: Service { }

