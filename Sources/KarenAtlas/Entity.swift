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
    
    private let database: any Database
    
    init(record: EntityRecord, database: any Database) throws {
        self.id = try record.requireID()
        self.type = record.type
        self.displayName = record.displayName
        self.database = database
    }
    
    public func attribute(_ name: String) async throws -> String? {
        try await AttributeRecord.query(on: database)
            .filter(\.$entity.$id == id)
            .filter(\.$attributeName == name)
            .first()?
            .value
    }
    
    public func attributes() async throws -> [String: String] {
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
        let record = RelationshipRecord(
            subject: id,
            relationshipType: relationshipType,
            object: entity.id,
            validFrom: validFrom
        )
        
        try await record.create(on: database)
        
        return try Relationship(record: record, database: database)
    }
    
    public func relationships(
        includeEnded: Bool = false
    ) async throws -> [Relationship] {
        let query = RelationshipRecord.query(on: database)
            .group(.or) { group in
                group.filter(\.$subject.$id == id)
                group.filter(\.$object.$id == id)
            }
        
        if !includeEnded {
            query.filter(\.$validUntil == nil)
        }
        
        return try await query.all().map {
            try Relationship(record: $0, database: database)
        }
    }
}
