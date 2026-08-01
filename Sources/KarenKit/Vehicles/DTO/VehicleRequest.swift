//
//  VehicleRequest.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

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
