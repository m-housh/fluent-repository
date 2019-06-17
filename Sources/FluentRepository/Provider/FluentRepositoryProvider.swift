//
//  FluentRepositoryProvider.swift
//  FluentRepository
//
//  Created by Michael Housh on 6/17/19.
//

import Vapor


/**
 # FluentRepositoryProvider
 ---------
 
 Registers services to the vapor application.
 
*/
public final class FluentRepositoryProvider: Provider {
    
    public init() { }
    
    public func register(_ services: inout Services) throws {
        services.register(DefaultPaginationConfig.self)
    }
    
    public func didBoot(_ container: Container) throws -> EventLoopFuture<Void> {
        return .done(on: container)
    }
    
    
}
