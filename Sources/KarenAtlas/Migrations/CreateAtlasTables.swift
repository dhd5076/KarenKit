//
//  CreateAtlasTables.swift
//  KarenShared
//
//  Created by Dylan Dunn on 7/28/26.
//

import Fluent

public struct CreateAtlasTables: AsyncMigration {
    
    public init() { }
    
    public func prepare(on database: any Database) async throws {
        try await database.schema(EntityRecord.schema)
            .id()
            .field(EntityRecord.FieldKeys.type, .string, .required)
            .field(EntityRecord.FieldKeys.displayName, .string, .required)
            .create()
        
        try await database.schema(AttributeRecord.schema)
            .id()
            .field(
                AttributeRecord.FieldKeys.entityID,
                .uuid,
                .required,
                .references(EntityRecord.schema, "id", onDelete: .cascade)
            )
            .field(AttributeRecord.FieldKeys.attributeName, .string, .required)
            .field(AttributeRecord.FieldKeys.value, .string, .required)
            .field(AttributeRecord.FieldKeys.valueType, .string, .required)
            .unique(
                on: AttributeRecord.FieldKeys.entityID,
                AttributeRecord.FieldKeys.attributeName
            )
            .create()
        
        try await database.schema(RelationshipRecord.schema)
            .id()
            .field(
                RelationshipRecord.FieldKeys.subject,
                .uuid,
                .required,
                .references(EntityRecord.schema, "id", onDelete: .cascade)
            )
            .field(RelationshipRecord.FieldKeys.relationshipType, .string, .required)
            .field(
                RelationshipRecord.FieldKeys.object,
                .uuid,
                .required,
                .references(EntityRecord.schema, "id", onDelete: .cascade)
            )
            .field(RelationshipRecord.FieldKeys.validFrom, .datetime)
            .field(RelationshipRecord.FieldKeys.validUntil, .datetime)
            .create()
    }
    
    public func revert(on database: any Database) async throws {
        try await database.schema(RelationshipRecord.schema).delete()
        try await database.schema(AttributeRecord.schema).delete()
        try await database.schema(EntityRecord.schema).delete()
    }
}
