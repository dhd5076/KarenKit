//
//  Relationship.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent

public struct Relationship: Identifiable, Sendable {
    public let id: UUID
    public let type: String
    public let subject: UUID
    public let object: UUID
    public let validFrom: Date?
    public let validUntil: Date?
    
    private let database: any Database
    
    init(
        record: RelationshipRecord,
        database: any Database
    ) throws {
        self.id = try record.requireID()
        self.type = record.relationshipType
        self.subject = record.$subject.id
        self.object = record.$object.id
        self.validFrom = record.validFrom
        self.validUntil = record.validUntil
        self.database = database
    }
    
    @discardableResult
    public func end(at date: Date = Date()) async throws -> Relationship {
        guard let record = try await RelationshipRecord.find(id, on: database) else {
            throw AtlasError.relationshipNotFound(id)
        }
        
        record.validUntil = date
        try await record.update(on: database)
        
        return try Relationship(record: record, database: database)
    }
}
