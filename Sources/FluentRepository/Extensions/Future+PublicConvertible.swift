//
//  Future+PublicConvertible.swift
//  FluentRepository
//
//  Created by Michael Housh on 6/17/19.
//

import Vapor


extension Future where T: PublicConvertible {
    
    func `public`() throws -> Future<T.PublicType> {
        return map { model in return model.public }
    }
}


