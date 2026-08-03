import Foundation

#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

import Testing
@testable import KarenKit

@Suite("KarenClient People service", .serialized)
struct KarenClientPeopleServiceTests {
    @Test("Wraps every People endpoint")
    func peopleEndpoints() async throws {
        let personId = UUID()
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [PeopleMockURLProtocol.self]
        let client = KarenClient(
            baseURL: try #require(URL(string: "https://karen.test/api")),
            applicationToken: "test-token",
            session: URLSession(configuration: configuration)
        )

        PeopleMockURLProtocol.requests = []
        PeopleMockURLProtocol.personId = personId

        _ = try await client.people.getAll()
        _ = try await client.people.get(id: personId)
        _ = try await client.people.search(name: "Dylan Dunn")
        _ = try await client.people.create(
            PersonRequest(firstName: "Dylan", lastName: "Dunn")
        )
        _ = try await client.people.update(
            id: personId,
            request: PersonRequest(firstName: "Dylan")
        )

        let requests = PeopleMockURLProtocol.requests
        #expect(requests.count == 5)
        #expect(requests.allSatisfy {
            $0.value(forHTTPHeaderField: "Authorization")
                == "Bearer test-token"
        })

        #expect(requests[0].httpMethod == "GET")
        #expect(requests[0].url?.path == "/api/people")
        #expect(requests[1].url?.path == "/api/people/\(personId.uuidString)")

        let searchComponents = URLComponents(
            url: try #require(requests[2].url),
            resolvingAgainstBaseURL: false
        )
        #expect(requests[2].url?.path == "/api/people/search")
        #expect(searchComponents?.queryItems?.contains {
            $0.name == "name" && $0.value == "Dylan Dunn"
        } == true)

        #expect(requests[3].httpMethod == "POST")
        #expect(requests[3].url?.path == "/api/people")
        #expect(requests[4].httpMethod == "PUT")
        #expect(requests[4].url?.path == "/api/people/\(personId.uuidString)")
    }
}

private final class PeopleMockURLProtocol: URLProtocol, @unchecked Sendable {
    nonisolated(unsafe) static var requests: [URLRequest] = []
    nonisolated(unsafe) static var personId = UUID()

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
        let person = Person(
            id: Self.personId,
            displayName: "Dylan Dunn",
            firstName: "Dylan",
            lastName: "Dunn"
        )
        let isList = request.httpMethod == "GET" &&
            (request.url?.path == "/api/people" ||
                request.url?.path == "/api/people/search")

        if isList {
            return try JSONEncoder().encode([person])
        }

        return try JSONEncoder().encode(person)
    }
}
