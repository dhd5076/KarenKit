//
//  AtlasEntity.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation

/// A portable representation of an entity returned by KarenServer.
public struct AtlasEntity: Identifiable, Codable, Sendable {
    public let id: UUID
    public let type: EntityType
    public let displayName: String

    public init(
        id: UUID,
        type: EntityType,
        displayName: String
    ) {
        self.id = id
        self.type = type
        self.displayName = displayName
    }
}
