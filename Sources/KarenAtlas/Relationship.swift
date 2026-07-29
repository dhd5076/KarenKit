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

    init(record: RelationshipRecord) throws {
        self.id = try record.requireID()
        self.type = record.relationshipType
        self.subject = record.$subject.id
        self.object = record.$object.id
        self.validFrom = record.validFrom
        self.validUntil = record.validUntil
    }

    @discardableResult
    public func end(at date: Date = Date()) async throws -> Relationship {
        let database = try await Atlas.database()

        guard let record = try await RelationshipRecord.find(id, on: database) else {
            throw AtlasError.relationshipNotFound(id)
        }
        
        record.validUntil = date
        try await record.update(on: database)
        
        return try Relationship(record: record)
    }
}
