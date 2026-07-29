import Foundation
import KarenKit

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

public enum KarenClientError: Error, LocalizedError, Sendable {
    case invalidResponse
    case requestFailed(statusCode: Int, reason: String?)

    public var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "The server returned an invalid response."
        case let .requestFailed(statusCode, reason):
            return reason ?? "The request failed with status code \(statusCode)."
        }
    }
}

public final class KarenClient: @unchecked Sendable {
    public let baseURL: URL
    public let applicationToken: String

    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(
        baseURL: URL,
        applicationToken: String = "",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.applicationToken = applicationToken
        self.session = session

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    public func getVehicles() async throws -> [VehicleResponse] {
        try await get([VehicleModule.route])
    }

    public func getVehicle(id: UUID) async throws -> VehicleResponse {
        try await get([VehicleModule.route, id.uuidString])
    }

    public func createVehicle(_ request: VehicleRequest) async throws -> VehicleResponse {
        try await send(
            method: "POST",
            path: [VehicleModule.route],
            body: request
        )
    }

    public func updateVehicle(
        id: UUID,
        request: VehicleRequest
    ) async throws -> VehicleResponse {
        try await send(
            method: "PUT",
            path: [VehicleModule.route, id.uuidString],
            body: request
        )
    }

    public func getVehicleMakes() async throws -> [VehicleMakeResponse] {
        try await get([VehicleModule.route, "makes"])
    }

    public func createVehicleMake(
        displayName: String
    ) async throws -> VehicleMakeResponse {
        try await send(
            method: "POST",
            path: [VehicleModule.route, "makes"],
            body: VehicleNameRequest(displayName: displayName)
        )
    }

    public func getVehicleModels(makeId: UUID) async throws -> [VehicleModelResponse] {
        try await get([
            VehicleModule.route,
            "makes",
            makeId.uuidString,
            "models"
        ])
    }

    public func createVehicleModel(
        makeId: UUID,
        displayName: String
    ) async throws -> VehicleModelResponse {
        try await send(
            method: "POST",
            path: [
                VehicleModule.route,
                "makes",
                makeId.uuidString,
                "models"
            ],
            body: VehicleNameRequest(displayName: displayName)
        )
    }

    public func getLicensePlateHistory(
        vehicleId: UUID
    ) async throws -> [VehicleLicensePlateResponse] {
        try await get([
            VehicleModule.route,
            vehicleId.uuidString,
            "license-plates"
        ])
    }

    public func createAndAssignLicensePlate(
        vehicleId: UUID,
        request: LicensePlateRequest
    ) async throws -> VehicleLicensePlateResponse {
        try await send(
            method: "POST",
            path: [
                VehicleModule.route,
                vehicleId.uuidString,
                "license-plates"
            ],
            body: request
        )
    }

    public func assignLicensePlate(
        vehicleId: UUID,
        licensePlateId: UUID,
        effectiveAt: Date? = nil
    ) async throws -> VehicleLicensePlateResponse {
        try await send(
            method: "POST",
            path: [
                VehicleModule.route,
                vehicleId.uuidString,
                "license-plates",
                licensePlateId.uuidString,
                "assign"
            ],
            body: LicensePlateRelationshipRequest(effectiveAt: effectiveAt)
        )
    }

    public func unassignLicensePlate(
        vehicleId: UUID,
        licensePlateId: UUID,
        effectiveAt: Date? = nil
    ) async throws -> VehicleLicensePlateResponse {
        try await send(
            method: "POST",
            path: [
                VehicleModule.route,
                vehicleId.uuidString,
                "license-plates",
                licensePlateId.uuidString,
                "unassign"
            ],
            body: LicensePlateRelationshipRequest(effectiveAt: effectiveAt)
        )
    }

    private func get<Response: Decodable & Sendable>(
        _ path: [String]
    ) async throws -> Response {
        try await send(method: "GET", path: path)
    }

    private func send<Response: Decodable & Sendable>(
        method: String,
        path: [String]
    ) async throws -> Response {
        try await send(
            method: method,
            path: path,
            encodedBody: nil
        )
    }

    private func send<Body: Encodable & Sendable, Response: Decodable & Sendable>(
        method: String,
        path: [String],
        body: Body
    ) async throws -> Response {
        try await send(
            method: method,
            path: path,
            encodedBody: encoder.encode(body)
        )
    }

    private func send<Response: Decodable & Sendable>(
        method: String,
        path: [String],
        encodedBody: Data?
    ) async throws -> Response {
        var url = baseURL
        for component in path {
            url.appendPathComponent(component)
        }

        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        if encodedBody != nil {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        if !applicationToken.isEmpty {
            request.setValue(
                "Bearer \(applicationToken)",
                forHTTPHeaderField: "Authorization"
            )
        }

        request.httpBody = encodedBody

        let (data, response) = try await session.data(for: request)

        guard let response = response as? HTTPURLResponse else {
            throw KarenClientError.invalidResponse
        }

        guard 200..<300 ~= response.statusCode else {
            throw KarenClientError.requestFailed(
                statusCode: response.statusCode,
                reason: serverErrorReason(from: data)
            )
        }

        return try decoder.decode(Response.self, from: data)
    }

    private func serverErrorReason(from data: Data) -> String? {
        struct ErrorResponse: Decodable {
            let reason: String?
        }

        return try? decoder.decode(ErrorResponse.self, from: data).reason
    }
}
