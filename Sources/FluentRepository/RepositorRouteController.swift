//
//  RepositoryRouteController.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/10/19.
//

import Vapor


public protocol RepositoryRouteController {
    
    associatedtype Repository: FluentRepository
    associatedtype ReturnType: Content
    
    var repository: Repository { get }
    var path: String { get }
    
    func all(_ request: Request) throws -> Future<[ReturnType]>
    
    func find(_ request: Request) throws -> Future<ReturnType>
    
    func save(_ request: Request, model: Repository.DBModel) throws -> Future<ReturnType>
    
    func delete(_ request: Request) throws -> Future<HTTPStatus>
}

extension RepositoryRouteController where Self: RouteCollection, Repository.DBModel: Parameter, Repository.DBModel: RequestDecodable {
    
    func boot(router: Router) {
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
    
    public required init(_ path: String, on worker: Container) throws {
        self.path = path
        self.repository = try worker.make(R.self)
    }
    
    public func all(_ request: Request) throws -> EventLoopFuture<[ReturnType]> {
        return repository.all()
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
