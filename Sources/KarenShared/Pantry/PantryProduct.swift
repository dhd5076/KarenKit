//
//  Product.swift
//  karen-lib
//
//  Created by Dylan Dunn on 6/6/26.
//

import Foundation

public struct PantryProduct: Codable, Sendable {
    public static let baseRoute = "products"
    public static let icon = "tag"
    
    public let id: UUID?
    public let name: String
    public let unit: String
    public let proteinPerUnit: Double
    public let carbsPerUnit: Double
    public let fatPerUnit: Double
    public let shelfLife: Int
    
    public init(
        id: UUID? = nil,
        name: String,
        unit: String,
        proteinPerUnit: Double,
        carbsPerUnit: Double,
        fatPerUnit: Double,
        shelfLife: Int
    ) {
        self.id = id
        self.name = name
        self.unit = unit
        self.proteinPerUnit = proteinPerUnit
        self.carbsPerUnit = carbsPerUnit
        self.fatPerUnit = fatPerUnit
        self.shelfLife = shelfLife
    }
        
}
