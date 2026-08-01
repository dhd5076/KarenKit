//
//  VehicleRequests.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

public struct LicensePlateRelationshipRequest: Codable, Sendable {
    public let effectiveAt: Date?

    public init(effectiveAt: Date? = nil) {
        self.effectiveAt = effectiveAt
    }
}

public struct LicensePlateRequest: Codable, Sendable {
    public let displayNumber: String
    public let jurisdictionCode: String
    public let countryCode: String
    public let validFrom: Date?

    public init(
        displayNumber: String,
        jurisdictionCode: String,
        countryCode: String,
        validFrom: Date? = nil
    ) {
        self.displayNumber = displayNumber
        self.jurisdictionCode = jurisdictionCode
        self.countryCode = countryCode
        self.validFrom = validFrom
    }
}

public struct VehicleNameRequest: Codable, Sendable {
    public let displayName: String

    public init(displayName: String) {
        self.displayName = displayName
    }
}

public struct VehicleRequest: Codable, Sendable {
    public let displayName: String
    public let vehicleType: String
    public let modelYear: Int?
    public let makeId: UUID?
    public let modelId: UUID?
    public let trim: String?
    public let color: String?
    public let vin: String?

    public init(
        displayName: String,
        vehicleType: String,
        modelYear: Int? = nil,
        makeId: UUID? = nil,
        modelId: UUID? = nil,
        trim: String? = nil,
        color: String? = nil,
        vin: String? = nil
    ) {
        self.displayName = displayName
        self.vehicleType = vehicleType
        self.modelYear = modelYear
        self.makeId = makeId
        self.modelId = modelId
        self.trim = trim
        self.color = color
        self.vin = vin
    }
}

