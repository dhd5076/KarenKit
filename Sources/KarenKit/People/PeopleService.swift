//
//  PeopleService.swift
//  KarenKit
//

import Foundation

/// Client API for the People module.
public struct PeopleService: Sendable {
    private let transport: ClientTransport

    init(transport: ClientTransport) {
        self.transport = transport
    }

    public func getAll() async throws -> [Person] {
        try await transport.get([PeopleModule.route])
    }

    public func get(id: UUID) async throws -> Person {
        try await transport.get([PeopleModule.route, id.uuidString])
    }

    public func search(name: String) async throws -> [Person] {
        try await transport.get(
            [PeopleModule.route, "search"],
            queryItems: [URLQueryItem(name: "name", value: name)]
        )
    }

    public func create(_ request: PersonRequest) async throws -> Person {
        try await transport.send(
            method: "POST",
            path: [PeopleModule.route],
            body: request
        )
    }

    public func update(
        id: UUID,
        request: PersonRequest
    ) async throws -> Person {
        try await transport.send(
            method: "PUT",
            path: [PeopleModule.route, id.uuidString],
            body: request
        )
    }
}
