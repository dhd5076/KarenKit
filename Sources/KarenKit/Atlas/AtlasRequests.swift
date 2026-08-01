import Foundation

public struct CreateAtlasEntityRequest: Codable, Sendable {
    public let type: EntityType
    public let displayName: String

    public init(type: EntityType, displayName: String) {
        self.type = type
        self.displayName = displayName
    }
}

public struct UpdateAtlasEntityRequest: Codable, Sendable {
    public let displayName: String

    public init(displayName: String) {
        self.displayName = displayName
    }
}

public struct SetAtlasAttributeRequest: Codable, Sendable {
    public let value: String
    public let valueType: String?

    public init(value: String, valueType: String? = nil) {
        self.value = value
        self.valueType = valueType
    }
}

public struct CreateAtlasRelationshipRequest: Codable, Sendable {
    public let subject: UUID
    public let type: RelationshipType
    public let object: UUID
    public let validFrom: Date?

    public init(
        subject: UUID,
        type: RelationshipType,
        object: UUID,
        validFrom: Date? = nil
    ) {
        self.subject = subject
        self.type = type
        self.object = object
        self.validFrom = validFrom
    }
}

public struct EndAtlasRelationshipRequest: Codable, Sendable {
    public let validUntil: Date?

    public init(validUntil: Date? = nil) {
        self.validUntil = validUntil
    }
}
