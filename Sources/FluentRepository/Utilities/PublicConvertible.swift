//
//  PublicConvertible.swift
//  FluentRepository
//
//  Created by Michael Housh on 5/23/19.
//

import Vapor


public protocol PublicConvertible {
    
    associatedtype PublicType: Content
    
    var `public`: PublicType { get }
    
}
