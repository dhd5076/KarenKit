//
//  Task.swift
//  KarenShared
//
//  Created by Dylan Dunn on 6/14/26.
//

import Foundation

public struct Task: Codable, Sendable {
    public static let baseRoute = "tasks"
    public static let icon = "shippingbox"
    
    public let id: UUID?
    public let title: String
    public let dueAt: Date
    public let isCompleted: Bool
    public let completedAt: Date
    public let source: String
    
    public init(
        id: UUID? = nil,
        title: String,
        dueAt: Date,
        isCompleted: Bool,
        completedAt: Date,
        source: String
    ) {
        self.id = id
        self.title = title
        self.dueAt = dueAt
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.source = source
    }
}
