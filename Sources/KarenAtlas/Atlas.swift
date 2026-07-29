//
//  Atlas.swift
//  KarenKit
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent

public enum AtlasError: Error, Sendable {
    case notConfigured
    case entityNotFound(UUID)
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

public enum Atlas {
    private static let configuration = AtlasConfiguration()
    @TaskLocal private static var scopedDatabase: (any Database)?
    
    public static func configure(database: any Database) async {
        await configuration.configure(database: database)
    }
    
    public static func createEntity(
        type: String,
        displayName: String
    ) async throws -> Entity {
        let database = try await database()
        let record = EntityRecord()
        
        record.type = type
        record.displayName = displayName
        
        try await record.create(on: database)
        
        return try Entity(record: record)
    }
    
    public static func entity(id: UUID) async throws -> Entity {
        let database = try await database()
        
        guard let record = try await EntityRecord.find(id, on: database) else {
            throw AtlasError.entityNotFound(id)
        }
        
        return try Entity(record: record)
    }
    
    public static func entities(
        ofType type: String? = nil
    ) async throws -> [Entity] {
        let database = try await database()
        let query = EntityRecord.query(on: database)
        
        if let type {
            query.filter(\.$type == type)
        }
        
        return try await query.all().map {
            try Entity(record: $0)
        }
    }

    public static func relationships(
        subject: UUID? = nil,
        object: UUID? = nil,
        type: String? = nil,
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
            query.filter(\.$relationshipType == type)
        }

        if !includeEnded {
            query.filter(\.$validUntil == nil)
        }

        return try await query.all().map {
            try Relationship(record: $0)
        }
    }

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
