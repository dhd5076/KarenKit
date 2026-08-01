//
//  VehicleLicensePlateAssigment.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

public struct VehicleLicensePlateAssignment: Codable, Sendable {
    public let relationshipId: UUID
    public let licensePlate: LicensePlate
    public let validFrom: Date?
    public let validUntil: Date?

    public init(
        relationshipId: UUID,
        licensePlate: LicensePlate,
        validFrom: Date? = nil,
        validUntil: Date? = nil
    ) {
        self.relationshipId = relationshipId
        self.licensePlate = licensePlate
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
