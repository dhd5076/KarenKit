//
//  VehicleMake.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//
import Foundation

public struct VehicleMake: Codable, Sendable {
    public let id: UUID
    public let displayName: String

    public init(id: UUID, displayName: String) {
        self.id = id
        self.displayName = displayName
    }
}
