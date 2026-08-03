//
//  Person.swift
//  KarenKit
//

import Foundation

public extension EntityType {
    static let person = EntityType(rawValue: "person")
}

public extension AttributeKey {
    static let firstName = AttributeKey(rawValue: "first_name")
    static let middleName = AttributeKey(rawValue: "middle_name")
    static let lastName = AttributeKey(rawValue: "last_name")
}

/// A portable representation of a person backed by an Atlas entity.
public struct Person: Identifiable, Codable, Sendable {
    public let id: UUID
    public let displayName: String
    public let firstName: String
    public let middleName: String?
    public let lastName: String?

    public init(
        id: UUID,
        displayName: String,
        firstName: String,
        middleName: String? = nil,
        lastName: String? = nil
    ) {
        self.id = id
        self.displayName = displayName
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
    }
}
