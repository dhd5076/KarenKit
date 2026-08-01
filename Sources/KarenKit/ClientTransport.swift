import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

final class ClientTransport: @unchecked Sendable {
    private let baseURL: URL
    private let applicationToken: String
    private let session: URLSession
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    init(
        baseURL: URL,
        applicationToken: String,
        session: URLSession
    ) {
        self.baseURL = baseURL
        self.applicationToken = applicationToken
        self.session = session

        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601

        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func get<Response: Decodable & Sendable>(
        _ path: [String]
    ) async throws -> Response {
        try await send(method: "GET", path: path)
    }

    func send<Response: Decodable & Sendable>(
        method: String,
        path: [String]
    ) async throws -> Response {
        try await send(
            method: method,
            path: path,
            encodedBody: nil
        )
    }

    func send<Body: Encodable & Sendable, Response: Decodable & Sendable>(
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
