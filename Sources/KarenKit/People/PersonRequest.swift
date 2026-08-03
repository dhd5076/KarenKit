//
//  PersonRequest.swift
//  KarenKit
//

/// Values accepted when creating or updating a person.
public struct PersonRequest: Codable, Sendable {
    public let firstName: String
    public let middleName: String?
    public let lastName: String?

    public init(
        firstName: String,
        middleName: String? = nil,
        lastName: String? = nil
    ) {
        self.firstName = firstName
        self.middleName = middleName
        self.lastName = lastName
    }
}

//TODO: Remove redundant DTOs where possible
