import Foundation

/// A portable representation of one current Atlas attribute value.
public struct AtlasAttribute: Codable, Sendable {
    public let key: AttributeKey
    public let value: String
    public let valueType: String

    public init(
        key: AttributeKey,
        value: String,
        valueType: String
    ) {
        self.key = key
        self.value = value
        self.valueType = valueType
    }
}
