//
//  AtlasTypes.swift
//  KarenKit
//
//  Created by Codex on 7/28/26.
//

/// A stable, extensible identifier for a kind of Atlas entity.
///
/// Known identifiers are declared as static members by domain modules. Use
/// ``init(rawValue:)`` when a type must be defined dynamically.
public struct EntityType: RawRepresentable, Hashable, Codable, Sendable {
    /// The string persisted by KarenAtlas.
    public let rawValue: String

    /// Creates an entity type from its persistent identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A stable, extensible identifier for a scalar Atlas attribute.
public struct AttributeKey: RawRepresentable, Hashable, Codable, Sendable {
    /// The string persisted by KarenAtlas.
    public let rawValue: String

    /// Creates an attribute key from its persistent identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}

/// A stable, extensible identifier for a directional relationship between entities.
public struct RelationshipType: RawRepresentable, Hashable, Codable, Sendable {
    /// The string persisted by KarenAtlas.
    public let rawValue: String

    /// Creates a relationship type from its persistent identifier.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
}
