//
//  LicensePlateRequest.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

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
