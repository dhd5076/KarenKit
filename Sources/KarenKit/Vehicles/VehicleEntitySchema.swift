//
//  VehicleEntitySchema.swift
//  KarenKit
//
//  Created by Codex on 7/28/26.
//

public enum VehicleEntitySchema {
    public enum EntityType {
        public static let vehicle = "vehicle"
        public static let make = "vehicle_make"
        public static let model = "vehicle_model"
        public static let licensePlate = "license_plate"
    }

    public enum Attribute {
        public static let vehicleType = "vehicle_type"
        public static let modelYear = "model_year"
        public static let trim = "trim"
        public static let color = "color"
        public static let vin = "vin"
        public static let normalizedName = "normalized_name"
        public static let displayNumber = "display_number"
        public static let normalizedNumber = "normalized_number"
        public static let jurisdictionCode = "jurisdiction_code"
        public static let countryCode = "country_code"
    }

    public enum Relationship {
        public static let vehicleMake = "vehicle_make"
        public static let vehicleModel = "vehicle_model"
        public static let modelMake = "model_make"
        public static let licensePlateAssignment = "license_plate_assignment"
    }
}
