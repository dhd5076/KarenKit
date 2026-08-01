//
//  Atlas.swift
//  KarenAtlas
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

        return try await entityQuery(on: database, type: type).all().map {
            try Entity(record: $0)
        }
    }

    /// Fetches one entity, optionally filtering by semantic type.
    ///
    /// This method does not define an order among multiple matches. Use it when
    /// any matching entity is sufficient or uniqueness is enforced separately.
    ///
    /// - Parameter type: The entity type to match, or `nil` for any type.
    /// - Returns: A matching entity, or `nil` when no entity matches.
    public static func entity(
        ofType type: EntityType? = nil
    ) async throws -> Entity? {
        let database = try await database()

        guard let record = try await entityQuery(
            on: database,
            type: type
        ).first() else {
            return nil
        }

        return try Entity(record: record)
    }

    /// Fetches one entity whose attribute has the requested value.
    ///
    /// The attribute and value are required together so callers cannot create an
    /// incomplete attribute filter. The semantic type remains optional.
    ///
    /// - Parameters:
    ///   - type: The entity type to match, or `nil` for any type.
    ///   - attribute: The attribute to search.
    ///   - value: The exact stored value to match.
    /// - Returns: A matching entity, or `nil` when no entity matches.
    public static func entity(
        ofType type: EntityType? = nil,
        where attribute: AttributeKey,
        equals value: String
    ) async throws -> Entity? {
        let database = try await database()
        let query = entityQuery(on: database, type: type)

        query.join(
            AttributeRecord.self,
            on: \EntityRecord.$id == \AttributeRecord.$entity.$id
        )
        query.filter(
            AttributeRecord.self,
            \.$attributeName == attribute.rawValue
        )
        query.filter(AttributeRecord.self, \.$value == value)

        guard let record = try await query.first() else {
            return nil
        }

        return try Entity(record: record)
    }

    /// Constructs the shared Fluent query used by entity lookups.
    private static func entityQuery(
        on database: any Database,
        type: EntityType?
    ) -> QueryBuilder<EntityRecord> {
        let query = EntityRecord.query(on: database)

        if let type {
            query.filter(\.$type == type.rawValue)
        }

        return query
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

        return try await relationshipQuery(
            on: database,
            subject: subject,
            object: object,
            type: type,
            includeEnded: includeEnded
        )
        .all()
        .map { try Relationship(record: $0) }
    }

    /// Fetches one relationship using optional subject, object, and type filters.
    ///
    /// By default, the query only considers active relationships. Pass
    /// `includeEnded: true` to include historical relationships.
    ///
    /// This method does not enforce relationship cardinality or define an order
    /// among multiple matches. Domain code should only use it where returning any
    /// matching relationship is sufficient or where uniqueness is enforced
    /// separately.
    ///
    /// - Parameters:
    ///   - subject: The originating entity identifier.
    ///   - object: The target entity identifier.
    ///   - type: The semantic relationship type.
    ///   - includeEnded: Whether relationships with an end date may be returned.
    /// - Returns: A matching relationship, or `nil` when no relationship matches.
    public static func relationship(
        subject: UUID? = nil,
        object: UUID? = nil,
        type: RelationshipType? = nil,
        includeEnded: Bool = false
    ) async throws -> Relationship? {
        let database = try await database()

        guard let record = try await relationshipQuery(
            on: database,
            subject: subject,
            object: object,
            type: type,
            includeEnded: includeEnded
        ).first() else {
            return nil
        }

        return try Relationship(record: record)
    }

    /// Fetches a relationship by its persistent identifier.
    ///
    /// - Throws: ``AtlasError/relationshipNotFound(_:)`` when the relationship
    ///   does not exist.
    public static func relationship(id: UUID) async throws -> Relationship {
        let database = try await database()

        guard let record = try await RelationshipRecord.find(id, on: database) else {
            throw AtlasError.relationshipNotFound(id)
        }

        return try Relationship(record: record)
    }

    /// Constructs the shared Fluent query used by singular and plural lookups.
    private static func relationshipQuery(
        on database: any Database,
        subject: UUID?,
        object: UUID?,
        type: RelationshipType?,
        includeEnded: Bool
    ) -> QueryBuilder<RelationshipRecord> {
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

        return query
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
