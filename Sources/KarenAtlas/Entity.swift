//
//  Entity.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent

public struct Entity: Identifiable, Sendable {
    public let id: UUID
    public let type: String
    public let displayName: String

    init(record: EntityRecord) throws {
        self.id = try record.requireID()
        self.type = record.type
        self.displayName = record.displayName
    }

    public func attribute(_ name: String) async throws -> String? {
        let database = try await Atlas.database()

        return try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == name)
            .first()?
            .value
    }
    
    public func attributes() async throws -> [String: String] {
        let database = try await Atlas.database()
        let records = try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .all()
        
        return Dictionary(
            uniqueKeysWithValues: records.map {
                ($0.attributeName, $0.value)
            }
        )
    }
    
    public func setAttribute(
        _ name: String,
        to value: String,
        valueType: String = "string"
    ) async throws {
        let database = try await Atlas.database()

        if let record = try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == name)
            .first() {
            record.value = value
            record.valueType = valueType
            try await record.update(on: database)
        } else {
            let record = AttributeRecord()
            
            record.$entity.id = id
            record.attributeName = name
            record.value = value
            record.valueType = valueType
            
            try await record.create(on: database)
        }
    }
    
    public func removeAttribute(_ name: String) async throws {
        let database = try await Atlas.database()

        try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == name)
            .delete()
    }
    
    @discardableResult
    public func relate(
        to entity: Entity,
        as relationshipType: String,
        validFrom: Date? = nil
    ) async throws -> Relationship {
        let database = try await Atlas.database()
        let record = RelationshipRecord(
            subject: id,
            relationshipType: relationshipType,
            object: entity.id,
            validFrom: validFrom
        )
        
        try await record.create(on: database)
        
        return try Relationship(record: record)
    }

    public func updateDisplayName(_ displayName: String) async throws -> Entity {
        let database = try await Atlas.database()

        guard let record = try await EntityRecord.find(id, on: database) else {
            throw AtlasError.entityNotFound(id)
        }

        record.displayName = displayName
        try await record.update(on: database)

        return try Entity(record: record)
    }

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
