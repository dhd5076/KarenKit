//
//  ConsumePantryBatchRequest.swift
//  KarenShared
//
//  Created by Dylan Dunn on 6/14/26.
//

import Foundation

public struct ConsumePantryBatchRequest: Codable, Sendable {
    public let quantity: Double
    public let note: String?

    public init(
        quantity: Double,
        note: String? = nil
    ) {
        self.quantity = quantity
        self.note = note
    }
}
