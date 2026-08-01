//
//  LicensePlateRelationshipRequest.swift
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
