import Foundation

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
    public let vehicles: VehicleService

    let transport: ClientTransport

    public init(
        baseURL: URL,
        applicationToken: String = "",
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.applicationToken = applicationToken
        let transport = ClientTransport(
            baseURL: baseURL,
            applicationToken: applicationToken,
            session: session
        )
        self.transport = transport
        self.vehicles = VehicleService(transport: transport)
    }
}
