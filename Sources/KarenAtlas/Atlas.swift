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
    
    public static func configure(database: any Database) async {
        await configuration.configure(database: database)
    }
    
    public static func createEntity(
        type: String,
        displayName: String
    ) async throws -> Entity {
        let database = try await configuration.configuredDatabase()
        let record = EntityRecord()
        
        record.type = type
        record.displayName = displayName
        
        try await record.create(on: database)
        
        return try Entity(record: record, database: database)
    }
    
    public static func entity(id: UUID) async throws -> Entity {
        let database = try await configuration.configuredDatabase()
        
        guard let record = try await EntityRecord.find(id, on: database) else {
            throw AtlasError.entityNotFound(id)
        }
        
        return try Entity(record: record, database: database)
    }
    
    public static func entities(
        ofType type: String? = nil
    ) async throws -> [Entity] {
        let database = try await configuration.configuredDatabase()
        let query = EntityRecord.query(on: database)
        
        if let type {
            query.filter(\.$type == type)
        }
        
        return try await query.all().map {
            try Entity(record: $0, database: database)
        }
    }
}
