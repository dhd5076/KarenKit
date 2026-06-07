//
//  Pantry.swift
//  karen-lib
//
//  Created by Dylan Dunn on 6/6/26.
//

import Foundation

public enum Pantry {
    public static let baseRoute = "pantries"
    
    public struct DTO: Codable, Sendable {
        public let id: UUID?
        public let name: String
        
        public init(id: UUID? = nil, name: String) {
            self.id = id
            self.name = name
        }
    }
}
