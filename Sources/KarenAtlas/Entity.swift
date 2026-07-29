//
//  Entity.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent
import KarenKit

/// A lightweight snapshot of a durable object stored by KarenAtlas.
///
/// Attributes and relationships are loaded on demand and currently perform a
/// database query for each method call.
public struct Entity: Identifiable, Sendable {
    /// The entity's persistent identifier.
    public let id: UUID
    /// The entity's semantic type.
    public let type: EntityType
    /// A human-readable name available without loading domain-specific details.
    public let displayName: String

    init(record: EntityRecord) throws {
        self.id = try record.requireID()
        self.type = EntityType(rawValue: record.type)
        self.displayName = record.displayName
    }

    /// Returns the current value for one attribute.
    ///
    /// - Returns: The stored string, or `nil` when the attribute is absent.
    public func attribute(_ key: AttributeKey) async throws -> String? {
        let database = try await Atlas.database()

        return try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == key.rawValue)
            .first()?
            .value
    }
    
    /// Returns every current attribute associated with the entity.
    public func attributes() async throws -> [AttributeKey: String] {
        let database = try await Atlas.database()
        let records = try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .all()
        
        return Dictionary(
            uniqueKeysWithValues: records.map {
                (AttributeKey(rawValue: $0.attributeName), $0.value)
            }
        )
    }
    
    /// Creates or replaces one attribute value.
    ///
    /// The `valueType` is descriptive metadata in the current implementation;
    /// Atlas does not validate or decode it.
    public func setAttribute(
        _ key: AttributeKey,
        to value: String,
        valueType: String = "string"
    ) async throws {
        let database = try await Atlas.database()

        if let record = try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == key.rawValue)
            .first() {
            record.value = value
            record.valueType = valueType
            try await record.update(on: database)
        } else {
            let record = AttributeRecord()
            
            record.$entity.id = id
            record.attributeName = key.rawValue
            record.value = value
            record.valueType = valueType
            
            try await record.create(on: database)
        }
    }
    
    /// Removes the current value for an attribute.
    public func removeAttribute(_ key: AttributeKey) async throws {
        let database = try await Atlas.database()

        try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == key.rawValue)
            .delete()
    }
    
    /// Creates a directional relationship from this entity to another entity.
    ///
    /// - Parameters:
    ///   - entity: The target entity.
    ///   - relationshipType: The semantic meaning of the connection.
    ///   - validFrom: An optional date at which the relationship became valid.
    /// - Returns: The newly persisted relationship.
    @discardableResult
    public func relate(
        to entity: Entity,
        as relationshipType: RelationshipType,
        validFrom: Date? = nil
    ) async throws -> Relationship {
        let database = try await Atlas.database()
        let record = RelationshipRecord(
            subject: id,
            relationshipType: relationshipType.rawValue,
            object: entity.id,
            validFrom: validFrom
        )
        
        try await record.create(on: database)
        
        return try Relationship(record: record)
    }

    /// Replaces the entity's display name and returns an updated snapshot.
    public func updateDisplayName(_ displayName: String) async throws -> Entity {
        let database = try await Atlas.database()

        guard let record = try await EntityRecord.find(id, on: database) else {
            throw AtlasError.entityNotFound(id)
        }

        record.displayName = displayName
        try await record.update(on: database)

        return try Entity(record: record)
    }

    /// Returns relationships where this entity is either subject or object.
    ///
    /// - Parameter includeEnded: Whether historical, ended relationships should
    ///   be included. The default returns active relationships only.
    public func relationships(
        includeEnded: Bool = false
    ) async throws -> [Relationship] {
        let database = try await Atlas.database()
        let query = RelationshipRecord.query(on: database)
            .group(.or) { group in
                group.filter(\.$subject.$id == id)
                group.filter(\.$object.$id == id)
            }
        
        if !includeEnded {
            query.filter(\.$validUntil == nil)
        }
        
        return try await query.all().map {
            try Relationship(record: $0)
        }
    }
}
