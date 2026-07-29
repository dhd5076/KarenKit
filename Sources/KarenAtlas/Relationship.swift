//
//  Relationship.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent
import KarenKit

/// A directional, optionally time-bounded connection between two Atlas entities.
public struct Relationship: Identifiable, Sendable {
    /// The relationship's persistent identifier.
    public let id: UUID
    /// The semantic meaning of the relationship.
    public let type: RelationshipType
    /// The originating entity identifier.
    public let subject: UUID
    /// The target entity identifier.
    public let object: UUID
    /// The optional date at which the relationship became valid.
    public let validFrom: Date?
    /// The optional date at which the relationship stopped being valid.
    public let validUntil: Date?

    init(record: RelationshipRecord) throws {
        self.id = try record.requireID()
        self.type = RelationshipType(rawValue: record.relationshipType)
        self.subject = record.$subject.id
        self.object = record.$object.id
        self.validFrom = record.validFrom
        self.validUntil = record.validUntil
    }

    /// Ends the relationship without deleting its historical record.
    ///
    /// - Parameter date: The relationship's end date. The default is now.
    /// - Returns: An updated relationship snapshot.
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
