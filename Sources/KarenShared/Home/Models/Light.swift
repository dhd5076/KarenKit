//
//  Light.swift
//  KarenShared
//
//  Created by Dylan Dunn on 6/21/26.
//
import Foundation

public struct Light: Codable, Sendable {
    public static let baseRoute = "lights"
    public static let icon = "lightbulb"
    
    public let id: String
    public let name: String
    public let isOn: Bool
    public let brightness: Double?
    
    public init(
        id: String,
        name: String,
        isOn: Bool,
        brightness: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.isOn = isOn
        self.brightness = brightness
    }
}
