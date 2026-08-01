//
//  VehicleModel.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//
import Foundation

public struct VehicleModel: Codable, Sendable {
    public let id: UUID
    public let makeId: UUID
    public let displayName: String

    public init(id: UUID, makeId: UUID, displayName: String) {
        self.id = id
        self.makeId = makeId
        self.displayName = displayName
    }
}
