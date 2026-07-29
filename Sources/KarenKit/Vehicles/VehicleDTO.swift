//
//  VehicleDTO.swift
//  KarenShared
//
//  Created by Dylan Dunn on 7/24/26.
//

import Foundation

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

public struct VehicleMakeResponse: Codable, Sendable {
    public let id: UUID
    public let displayName: String

    public init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}

public struct VehicleModelResponse: Codable, Sendable {
    public let id: UUID
    public let makeId: UUID
    public let displayName: String

    public init(id: UUID, makeId: UUID, displayName: String) {
        self.id = id
        self.makeId = makeId
        self.displayName = displayName
    }
}

public struct VehicleResponse: Codable, Sendable {
    public let id: UUID
    public let entityId: UUID
    public let displayName: String
    public let vehicleType: String
    public let modelYear: Int?
    public let make: VehicleMakeResponse?
    public let model: VehicleModelResponse?
    public let trim: String?
    public let color: String?
    public let vin: String?

    public init(
        id: UUID,
        entityId: UUID,
        displayName: String,
        vehicleType: String,
        modelYear: Int? = nil,
        make: VehicleMakeResponse? = nil,
        model: VehicleModelResponse? = nil,
        trim: String? = nil,
        color: String? = nil,
        vin: String? = nil
    ) {
        self.id = id
        self.entityId = entityId
        self.displayName = displayName
        self.vehicleType = vehicleType
        self.modelYear = modelYear
        self.make = make
        self.model = model
        self.trim = trim
        self.color = color
        self.vin = vin
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

public struct LicensePlateRelationshipRequest: Codable, Sendable {
    public let effectiveAt: Date?

    public init(effectiveAt: Date? = nil) {
        self.effectiveAt = effectiveAt
    }
}

public struct LicensePlateResponse: Codable, Sendable {
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

public struct VehicleLicensePlateResponse: Codable, Sendable {
    public let relationshipId: UUID
    public let licensePlate: LicensePlateResponse
    public let validFrom: Date?
    public let validUntil: Date?

    public init(
        relationshipId: UUID,
        licensePlate: LicensePlateResponse,
        validFrom: Date? = nil,
        validUntil: Date? = nil
    ) {
        self.relationshipId = relationshipId
        self.licensePlate = licensePlate
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
