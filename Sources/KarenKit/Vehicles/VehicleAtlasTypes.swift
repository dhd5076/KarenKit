//
//  VehicleAtlasTypes.swift
//  KarenKit
//
//  Created by Codex on 7/28/26.
//

public extension EntityType {
    static let vehicle = EntityType(rawValue: "vehicle")
    static let vehicleMake = EntityType(rawValue: "vehicle_make")
    static let vehicleModel = EntityType(rawValue: "vehicle_model")
    static let licensePlate = EntityType(rawValue: "license_plate")
}

public extension AttributeKey {
    static let vehicleType = AttributeKey(rawValue: "vehicle_type")
    static let modelYear = AttributeKey(rawValue: "model_year")
    static let trim = AttributeKey(rawValue: "trim")
    static let color = AttributeKey(rawValue: "color")
    static let vin = AttributeKey(rawValue: "vin")
    static let normalizedName = AttributeKey(rawValue: "normalized_name")
    static let displayNumber = AttributeKey(rawValue: "display_number")
    static let normalizedNumber = AttributeKey(rawValue: "normalized_number")
    static let jurisdictionCode = AttributeKey(rawValue: "jurisdiction_code")
    static let countryCode = AttributeKey(rawValue: "country_code")
}

public extension RelationshipType {
    static let vehicleMake = RelationshipType(rawValue: "vehicle_make")
    static let vehicleModel = RelationshipType(rawValue: "vehicle_model")
    static let modelMake = RelationshipType(rawValue: "model_make")
    static let licensePlateAssignment = RelationshipType(
        rawValue: "license_plate_assignment"
    )
}
