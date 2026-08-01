//
//  Product.swift
//  KarenKit
//
//  Created by Dylan Dunn on 7/29/26.
//
import Foundation

public extension EntityType {
    static let product = EntityType(rawValue: "product")
}

public enum ProductUnit: Codable, Sendable {
    case each
    case ml
    case g
}

public struct Product: Codable, Sendable {
    public let id: UUID
    public let displayName: String
    public let defaultUnit: ProductUnit
}
