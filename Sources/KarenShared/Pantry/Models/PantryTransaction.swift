//
//  Untitled.swift
//  karen-lib
//
//  Created by Dylan Dunn on 6/6/26.
//

import Foundation

public enum PantryTransaction {
    public static let baseRoute = "transactions"
    public static let icon = "arrow.left.arrow.right"
    
    public struct DTO: Codable, Sendable {
        public let id: UUID?
        public let type: PantryTransactionType
        public let product: UUID
        public let batch: UUID?
        public let fromPantry: UUID?
        public let toPantry: UUID?
        public let quantity: Double
        public let note: String?
        
        public init(
            id: UUID? = nil,
            type: PantryTransactionType,
            product: UUID,
            batch: UUID? = nil,
            fromPantry: UUID? = nil,
            toPantry: UUID? = nil,
            quantity: Double,
            note: String? = nil
        ) {
            self.id = id
            self.type = type
            self.product = product
            self.batch = batch
            self.fromPantry = fromPantry
            self.toPantry = toPantry
            self.quantity = quantity
            self.note = note
        }
        
    }
}

public enum PantryTransactionType: String, Codable, Sendable {
    case add
    case consume
    case transfer
    case adjust
    case spoil
}
