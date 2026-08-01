//
//  VehicleNameRequest.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

public struct VehicleNameRequest: Codable, Sendable {
    public let displayName: String

    public init(displayName: String) {
        self.displayName = displayName
    }
}
