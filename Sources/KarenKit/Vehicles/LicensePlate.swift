//
//  LicensePlate.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//
import Foundation

public struct LicensePlate: Codable, Sendable {
    public let id: UUID
    public let entityId: UUID
    public let displayNumber: String
    public let normalizedNumber: String
    public let jurisdictionCode: String
    public let countryCode: String

    public init(
        id: UUID,
        entityId: UUID,
        displayNumber: String,
        normalizedNumber: String,
        jurisdictionCode: String,
        countryCode: String
    ) {
        self.id = id
        self.entityId = entityId
        self.displayNumber = displayNumber
        self.normalizedNumber = normalizedNumber
        self.jurisdictionCode = jurisdictionCode
        self.countryCode = countryCode
    }
}
