import Foundation

/// A portable representation of a directional Atlas relationship.
public struct AtlasRelationship: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: RelationshipType
    public let subject: UUID
    public let object: UUID
    public let validFrom: Date?
    public let validUntil: Date?

    public init(
        id: UUID,
        type: RelationshipType,
        subject: UUID,
        object: UUID,
        validFrom: Date? = nil,
        validUntil: Date? = nil
    ) {
        self.id = id
        self.type = type
        self.subject = subject
        self.object = object
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
