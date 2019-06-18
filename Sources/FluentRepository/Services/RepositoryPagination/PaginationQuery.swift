//
//  PaginationQuery.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/23/19.
//

import Vapor


public protocol PaginationQuery: Content {
    var page: Int? { get }
}


public struct DefaultPaginationQuery: Content {
    public let page: Int?
}
