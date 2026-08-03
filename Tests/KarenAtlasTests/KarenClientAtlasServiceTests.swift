import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Testing
@testable import KarenKit

@Suite("KarenClient Atlas service", .serialized)
struct KarenClientAtlasServiceTests {
    @Test("Wraps every non-destructive Atlas endpoint")
    func atlasEndpoints() async throws {
        let entityId = UUID()
        let relationshipId = UUID()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [AtlasMockURLProtocol.self]
        let client = KarenClient(
            baseURL: try #require(URL(string: "https://karen.test/api")),
            applicationToken: "test-token",
            session: URLSession(configuration: configuration)
        )

        AtlasMockURLProtocol.requests = []
        AtlasMockURLProtocol.entityId = entityId
        AtlasMockURLProtocol.relationshipId = relationshipId

        _ = try await client.atlas.getEntities(ofType: .vehicle)
        _ = try await client.atlas.createEntity(
            CreateAtlasEntityRequest(
                type: .vehicle,
                displayName: "My Truck"
            )
        )
        _ = try await client.atlas.getEntity(id: entityId)
        _ = try await client.atlas.updateEntity(
            id: entityId,
            request: UpdateAtlasEntityRequest(displayName: "Frontier")
        )
        _ = try await client.atlas.getAttributes(entityId: entityId)
        _ = try await client.atlas.getAttribute(
            entityId: entityId,
            key: .color
        )
        _ = try await client.atlas.setAttribute(
            entityId: entityId,
            key: .color,
            request: SetAtlasAttributeRequest(value: "blue")
        )
        _ = try await client.atlas.getRelationships(
            entityId: entityId,
            includeEnded: true
        )
        _ = try await client.atlas.getRelationships(
            subject: entityId,
            object: entityId,
            type: RelationshipType(rawValue: "owns"),
            includeEnded: true
        )
        _ = try await client.atlas.createRelationship(
            CreateAtlasRelationshipRequest(
                subject: entityId,
                type: RelationshipType(rawValue: "owns"),
                object: entityId
            )
        )
        _ = try await client.atlas.getRelationship(id: relationshipId)
        _ = try await client.atlas.endRelationship(id: relationshipId)

        let requests = AtlasMockURLProtocol.requests
        #expect(requests.count == 12)
        #expect(requests.allSatisfy {
            $0.value(forHTTPHeaderField: "Authorization")
                == "Bearer test-token"
        })

        let entityListRequest = try #require(requests.first)
        let entityListQuery = URLComponents(
            url: try #require(entityListRequest.url),
            resolvingAgainstBaseURL: false
        )?.queryItems
        #expect(entityListRequest.httpMethod == "GET")
        #expect(entityListRequest.url?.path == "/api/atlas/entities")
        #expect(entityListQuery?.contains {
            $0.name == "type" && $0.value == "vehicle"
        } == true)

        let relationshipQueryRequest = requests[8]
        let relationshipQuery = URLComponents(
            url: try #require(relationshipQueryRequest.url),
            resolvingAgainstBaseURL: false
        )?.queryItems ?? []
        #expect(relationshipQueryRequest.url?.path == "/api/atlas/relationships")
        #expect(relationshipQuery.contains {
            $0.name == "subject" && $0.value == entityId.uuidString
        })
        #expect(relationshipQuery.contains {
            $0.name == "object" && $0.value == entityId.uuidString
        })
        #expect(relationshipQuery.contains {
            $0.name == "type" && $0.value == "owns"
        })
        #expect(relationshipQuery.contains {
            $0.name == "includeEnded" && $0.value == "true"
        })

        #expect(requests[1].httpMethod == "POST")
        #expect(requests[3].httpMethod == "PATCH")
        #expect(requests[6].httpMethod == "PUT")
        #expect(requests[11].url?.path == "/api/atlas/relationships/\(relationshipId.uuidString)/end")
    }
}

private final class AtlasMockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requests: [URLRequest] = []
    nonisolated(unsafe) static var entityId = UUID()
    nonisolated(unsafe) static var relationshipId = UUID()

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    override func startLoading() {
        Self.requests.append(request)

        do {
            let data = try responseData(for: request)
            guard let url = request.url,
                  let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
                  ) else {
                throw URLError(.badURL)
            }

            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}

    private func responseData(for request: URLRequest) throws -> Data {
        let path = request.url?.path ?? ""
        let method = request.httpMethod ?? "GET"
        let encoder = JSONEncoder()

        if path.hasSuffix("/entities"), method == "GET" {
            return try encoder.encode([AtlasEntity]())
        }

        if path.contains("/attributes") {
            if path.hasSuffix("/attributes") {
                return try encoder.encode([AtlasAttribute]())
            }

            return try encoder.encode(
                AtlasAttribute(key: .color, value: "blue", valueType: "string")
            )
        }

        if path.hasSuffix("/relationships"), method == "GET" {
            return try encoder.encode([AtlasRelationship]())
        }

        if path.contains("/relationships") {
            return try encoder.encode(
                AtlasRelationship(
                    id: Self.relationshipId,
                    type: RelationshipType(rawValue: "owns"),
                    subject: Self.entityId,
                    object: Self.entityId
                )
            )
        }

        return try encoder.encode(
            AtlasEntity(
                id: Self.entityId,
                type: .vehicle,
                displayName: "My Truck"
            )
        )
    }
}
