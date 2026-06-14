//
//  AddBatchToPantryRequest.swift
//  KarenShared
//
//  Created by Dylan Dunn on 6/13/26.
//
import Foundation

public struct AddBatchToPantryRequest: Codable, Sendable {
    public let product: UUID
    public let quantity: Double
    public let source: String
    public let acquiredAt: Date?
    public let note: String?
    
    public init(
        product: UUID,
        quantity: Double,
        source: String,
        acquiredAt: Date? = nil,
        note: String?
    ) {
        self.product = product
        self.quantity = quantity
        self.source = source
        self.acquiredAt = acquiredAt
        self.note = note
    }
}
