//
//  CurrentWeather.swift
//  KarenShared
//

import Foundation

public struct CurrentWeather: Codable, Sendable {
    public static let baseRoute = "current"
    public static let icon = "cloud.sun"

    public let condition: String
    public let temperature: Double
    public let temperatureUnit: String
    public let apparentTemperature: Double?
    public let humidity: Double?
    public let updatedAt: Date

    public init(
        condition: String,
        temperature: Double,
        temperatureUnit: String,
        apparentTemperature: Double? = nil,
        humidity: Double? = nil,
        updatedAt: Date
    ) {
        self.condition = condition
        self.temperature = temperature
        self.temperatureUnit = temperatureUnit
        self.apparentTemperature = apparentTemperature
        self.humidity = humidity
        self.updatedAt = updatedAt
    }
}
