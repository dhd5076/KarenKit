//
//  AtlasService.swift
//  KarenKit
//
//  Created by Dylan Dunn on 8/3/26.
//

import Foundation

public struct AtlasService: Sendable {
    private let transport: ClientTransport

    init(transport: ClientTransport) {
        self.transport = transport
    }

    public func getEntities(
        ofType type: EntityType? = nil
    ) async throws -> [AtlasEntity] {
        var queryItems: [URLQueryItem] = []

        if let type {
            queryItems.append(
                URLQueryItem(name: "type", value: type.rawValue)
            )
        }

        return try await transport.get(
            [AtlasModule.route, "entities"],
            queryItems: queryItems
        )
    }

    public func createEntity(
        _ request: CreateAtlasEntityRequest
    ) async throws -> AtlasEntity {
        try await transport.send(
            method: "POST",
            path: [AtlasModule.route, "entities"],
            body: request
        )
    }

    public func getEntity(id: UUID) async throws -> AtlasEntity {
        try await transport.get([
            AtlasModule.route,
            "entities",
            id.uuidString
        ])
    }

    public func updateEntity(
        id: UUID,
        request: UpdateAtlasEntityRequest
    ) async throws -> AtlasEntity {
        try await transport.send(
            method: "PATCH",
            path: [AtlasModule.route, "entities", id.uuidString],
            body: request
        )
    }

    public func getAttributes(
        entityId: UUID
    ) async throws -> [AtlasAttribute] {
        try await transport.get([
            AtlasModule.route,
            "entities",
            entityId.uuidString,
            "attributes"
        ])
    }

    public func getAttribute(
        entityId: UUID,
        key: AttributeKey
    ) async throws -> AtlasAttribute {
        try await transport.get([
            AtlasModule.route,
            "entities",
            entityId.uuidString,
            "attributes",
            key.rawValue
        ])
    }

    public func setAttribute(
        entityId: UUID,
        key: AttributeKey,
        request: SetAtlasAttributeRequest
    ) async throws -> AtlasAttribute {
        try await transport.send(
            method: "PUT",
            path: [
                AtlasModule.route,
                "entities",
                entityId.uuidString,
                "attributes",
                key.rawValue
            ],
            body: request
        )
    }

    public func getRelationships(
        entityId: UUID,
        includeEnded: Bool = false
    ) async throws -> [AtlasRelationship] {
        try await transport.get(
            [
                AtlasModule.route,
                "entities",
                entityId.uuidString,
                "relationships"
            ],
            queryItems: includeEndedQueryItems(includeEnded)
        )
    }

    public func getRelationships(
        subject: UUID? = nil,
        object: UUID? = nil,
        type: RelationshipType? = nil,
        includeEnded: Bool = false
    ) async throws -> [AtlasRelationship] {
        var queryItems: [URLQueryItem] = []

        if let subject {
            queryItems.append(
                URLQueryItem(name: "subject", value: subject.uuidString)
            )
        }

        if let object {
            queryItems.append(
                URLQueryItem(name: "object", value: object.uuidString)
            )
        }

        if let type {
            queryItems.append(
                URLQueryItem(name: "type", value: type.rawValue)
            )
        }

        queryItems.append(contentsOf: includeEndedQueryItems(includeEnded))

        return try await transport.get(
            [AtlasModule.route, "relationships"],
            queryItems: queryItems
        )
    }

    public func createRelationship(
        _ request: CreateAtlasRelationshipRequest
    ) async throws -> AtlasRelationship {
        try await transport.send(
            method: "POST",
            path: [AtlasModule.route, "relationships"],
            body: request
        )
    }

    public func getRelationship(id: UUID) async throws -> AtlasRelationship {
        try await transport.get([
            AtlasModule.route,
            "relationships",
            id.uuidString
        ])
    }

    public func endRelationship(
        id: UUID,
        validUntil: Date? = nil
    ) async throws -> AtlasRelationship {
        try await transport.send(
            method: "POST",
            path: [
                AtlasModule.route,
                "relationships",
                id.uuidString,
                "end"
            ],
            body: EndAtlasRelationshipRequest(validUntil: validUntil)
        )
    }

    private func includeEndedQueryItems(
        _ includeEnded: Bool
    ) -> [URLQueryItem] {
        guard includeEnded else {
            return []
        }

        return [URLQueryItem(name: "includeEnded", value: "true")]
    }
}
