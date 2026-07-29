//
//  Atlas.swift
//  KarenKit
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent
import KarenKit

/// Errors produced by KarenAtlas infrastructure.
public enum AtlasError: Error, Sendable {
    /// Atlas was used before a database was configured.
    case notConfigured
    /// No entity exists with the requested identifier.
    case entityNotFound(UUID)
    /// No relationship exists with the requested identifier.
    case relationshipNotFound(UUID)
}

private actor AtlasConfiguration {
    private var database: (any Database)?
    
    func configure(database: any Database) {
        self.database = database
    }
    
    func configuredDatabase() throws -> any Database {
        guard let database else {
            throw AtlasError.notConfigured
        }
        
        return database
    }
}

/// The process-wide entry point for configuring and querying KarenAtlas.
///
/// Configure Atlas once during server startup with ``configure(database:)``.
/// Domain code normally creates an ``Entity`` and then uses its instance methods
/// to manage attributes and relationships.
public enum Atlas {
    private static let configuration = AtlasConfiguration()
    @TaskLocal private static var scopedDatabase: (any Database)?
    
    /// Configures the Fluent database used by subsequent Atlas operations.
    ///
    /// - Parameter database: The application database connection.
    public static func configure(database: any Database) async {
        await configuration.configure(database: database)
    }
    
    /// Creates an entity with a semantic type and display name.
    ///
    /// - Parameters:
    ///   - type: The entity's persistent semantic type.
    ///   - displayName: A human-readable name suitable for generic interfaces.
    /// - Returns: The newly persisted entity.
    public static func createEntity(
        type: EntityType,
        displayName: String
    ) async throws -> Entity {
        let database = try await database()
        let record = EntityRecord()
        
        record.type = type.rawValue
        record.displayName = displayName
        
        try await record.create(on: database)
        
        return try Entity(record: record)
    }

    /// Creates an entity using concise, unlabeled arguments.
    ///
    /// This is equivalent to ``createEntity(type:displayName:)``.
    public static func createEntity(
        _ type: EntityType,
        _ displayName: String
    ) async throws -> Entity {
        try await createEntity(type: type, displayName: displayName)
    }
    
    /// Fetches an entity by its identifier.
    ///
    /// - Throws: ``AtlasError/entityNotFound(_:)`` when the entity does not exist.
    public static func entity(id: UUID) async throws -> Entity {
        let database = try await database()
        
        guard let record = try await EntityRecord.find(id, on: database) else {
            throw AtlasError.entityNotFound(id)
        }
        
        return try Entity(record: record)
    }
    
    /// Fetches all entities, optionally filtering by semantic type.
    ///
    /// - Parameter type: The entity type to return, or `nil` for every entity.
    public static func entities(
        ofType type: EntityType? = nil
    ) async throws -> [Entity] {
        let database = try await database()
        let query = EntityRecord.query(on: database)
        
        if let type {
            query.filter(\.$type == type.rawValue)
        }
        
        return try await query.all().map {
            try Entity(record: $0)
        }
    }

    /// Queries relationships using optional subject, object, and type filters.
    ///
    /// - Parameters:
    ///   - subject: The originating entity identifier.
    ///   - object: The target entity identifier.
    ///   - type: The semantic relationship type.
    ///   - includeEnded: Whether relationships with an end date should be returned.
    /// - Returns: Matching active relationships, or complete history when requested.
    public static func relationships(
        subject: UUID? = nil,
        object: UUID? = nil,
        type: RelationshipType? = nil,
        includeEnded: Bool = false
    ) async throws -> [Relationship] {
        let database = try await database()
        let query = RelationshipRecord.query(on: database)

        if let subject {
            query.filter(\.$subject.$id == subject)
        }

        if let object {
            query.filter(\.$object.$id == object)
        }

        if let type {
            query.filter(\.$relationshipType == type.rawValue)
        }

        if !includeEnded {
            query.filter(\.$validUntil == nil)
        }

        return try await query.all().map {
            try Relationship(record: $0)
        }
    }

    /// Executes Atlas operations in a Fluent database transaction.
    ///
    /// Entity and relationship methods called from `operation` automatically use
    /// the transaction-scoped database.
    public static func transaction<Value: Sendable>(
        _ operation: @escaping @Sendable () async throws -> Value
    ) async throws -> Value {
        let database = try await database()

        return try await database.transaction { transaction in
            try await $scopedDatabase.withValue(transaction) {
                try await operation()
            }
        }
    }

    static func database() async throws -> any Database {
        if let scopedDatabase {
            return scopedDatabase
        }

        return try await configuration.configuredDatabase()
    }
}
