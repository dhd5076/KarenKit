//
//  Batch.swift
//  karen-lib
//
//  Created by Dylan Dunn on 6/6/26.
//

import Foundation

public enum PantryBatch {
    public static let baseRoute = "batches"
    
    public struct DTO: Codable, Sendable {
        public let id: UUID?
        public let pantry: UUID
        public let product: UUID
        public let quantity: Double
        public let source: String
        public let acquiredAt: Date
        
        public init(
            id: UUID? = nil,
            pantry: UUID,
            product: UUID,
            quantity: Double,
            source: String,
            acquiredAt: Date
        ) {
            self.id = id
            self.pantry = pantry
            self.product = product
            self.quantity = quantity
            self.source = source
            self.acquiredAt = acquiredAt
        }
        
    }
}
