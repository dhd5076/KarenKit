import Fluent
import FluentSQLiteDriver
import Foundation
import KarenKit
import Testing
import Vapor
@testable import KarenAtlas

@Suite("KarenAtlas", .serialized)
struct KarenAtlasTests {
    @Test("Encodes Atlas identifiers as plain strings")
    func identifierCoding() throws {
        let encoded = try JSONEncoder().encode(
            CreateAtlasEntityRequest(
                type: .vehicle,
                displayName: "My Truck"
            )
        )
        let json = try #require(
            JSONSerialization.jsonObject(with: encoded) as? [String: String]
        )

        #expect(json["type"] == "vehicle")
        #expect(json["displayName"] == "My Truck")
    }

    @Test("Creates, fetches, and filters entities")
    func entityLifecycle() async throws {
        try await withAtlas {
            let vehicle = try await Atlas.createEntity(.vehicle, "My Truck")
            _ = try await Atlas.createEntity(
                type: EntityType(rawValue: "person"),
                displayName: "Dylan"
            )
            
            let fetched = try await Atlas.entity(id: vehicle.id)
            let vehicles = try await Atlas.entities(ofType: .vehicle)
            let allEntities = try await Atlas.entities()
            
            #expect(fetched.id == vehicle.id)
            #expect(fetched.type == .vehicle)
            #expect(fetched.displayName == "My Truck")
            #expect(vehicles.map(\.id) == [vehicle.id])
            #expect(allEntities.count == 2)
        }
    }

    @Test("Finds one entity by type and attribute value")
    func findEntity() async throws {
        try await withAtlas {
            let vehicle = try await Atlas.createEntity(.vehicle, "My Truck")
            let person = try await Atlas.createEntity(
                EntityType(rawValue: "person"),
                "Dylan"
            )

            try await vehicle.setAttribute(.vin, to: "ABC123")
            try await person.setAttribute(.vin, to: "ABC123")

            let typedMatch = try await Atlas.entity(
                ofType: .vehicle,
                where: .vin,
                equals: "ABC123"
            )
            let untypedMatch = try await Atlas.entity(
                where: .vin,
                equals: "ABC123"
            )
            let typeOnlyMatch = try await Atlas.entity(ofType: .vehicle)
            let missing = try await Atlas.entity(
                ofType: .vehicle,
                where: .vin,
                equals: "MISSING"
            )

            #expect(typedMatch?.id == vehicle.id)
            #expect(untypedMatch?.id == vehicle.id || untypedMatch?.id == person.id)
            #expect(typeOnlyMatch?.id == vehicle.id)
            #expect(missing == nil)
        }
    }
    
    @Test("Creates, updates, lists, and removes attributes")
    func attributeLifecycle() async throws {
        try await withAtlas {
            let vehicle = try await Atlas.createEntity(
                type: .vehicle,
                displayName: "My Truck"
            )
            
            let missingValue = try await vehicle.attribute(.color)
            #expect(missingValue == nil)
            
            try await vehicle.setAttribute(
                .color,
                to: "blue",
                valueType: "color-name"
            )
            let createdValue = try await vehicle.attribute(.color)
            let createdAttribute = try await vehicle.attributeValue(.color)
            #expect(createdValue == "blue")
            #expect(createdAttribute?.valueType == "color-name")
            
            try await vehicle.setAttribute(.color, to: "red")
            let updatedValue = try await vehicle.attribute(.color)
            let attributes = try await vehicle.attributes()
            let attributeValues = try await vehicle.attributeValues()
            
            #expect(updatedValue == "red")
            #expect(attributes == [.color: "red"])
            #expect(attributeValues.count == 1)
            #expect(attributeValues[0].key == .color)
            #expect(attributeValues[0].valueType == "string")
            
            try await vehicle.removeAttribute(.color)
            let removedValue = try await vehicle.attribute(.color)
            #expect(removedValue == nil)
        }
    }
    
    @Test("Creates, queries, and ends relationships")
    func relationshipLifecycle() async throws {
        try await withAtlas {
            let owner = try await Atlas.createEntity(
                type: EntityType(rawValue: "person"),
                displayName: "Dylan"
            )
            let vehicle = try await Atlas.createEntity(
                type: .vehicle,
                displayName: "My Truck"
            )
            
            let relationship = try await owner.relate(
                to: vehicle,
                as: RelationshipType(rawValue: "owns")
            )
            let activeRelationships = try await vehicle.relationships()
            let activeRelationship = try await Atlas.relationship(
                subject: owner.id,
                object: vehicle.id,
                type: RelationshipType(rawValue: "owns")
            )
            let relationshipById = try await Atlas.relationship(
                id: relationship.id
            )
            let missingRelationship = try await Atlas.relationship(
                subject: vehicle.id,
                type: RelationshipType(rawValue: "owns")
            )
            
            #expect(relationship.subject == owner.id)
            #expect(relationship.object == vehicle.id)
            #expect(relationship.type == RelationshipType(rawValue: "owns"))
            #expect(activeRelationships.map(\.id) == [relationship.id])
            #expect(activeRelationship?.id == relationship.id)
            #expect(relationshipById.id == relationship.id)
            #expect(missingRelationship == nil)
            
            let endedAt = Date(timeIntervalSince1970: 1_800_000_000)
            let endedRelationship = try await relationship.end(at: endedAt)
            let remainingActive = try await vehicle.relationships()
            let completeHistory = try await vehicle.relationships(
                includeEnded: true
            )
            let inactiveRelationship = try await Atlas.relationship(
                subject: owner.id,
                type: RelationshipType(rawValue: "owns")
            )
            let historicalRelationship = try await Atlas.relationship(
                subject: owner.id,
                type: RelationshipType(rawValue: "owns"),
                includeEnded: true
            )
            
            #expect(endedRelationship.validUntil == endedAt)
            #expect(remainingActive.isEmpty)
            #expect(completeHistory.map(\.id) == [relationship.id])
            #expect(inactiveRelationship == nil)
            #expect(historicalRelationship?.id == relationship.id)
        }
    }
    
    private func withAtlas(
        _ operation: @escaping @Sendable () async throws -> Void
    ) async throws {
        let app = try await Application.make(.testing)
        
        app.databases.use(.sqlite(.memory), as: .sqlite)
        app.migrations.add(CreateAtlasTables())
        
        do {
            try await app.autoMigrate()
            await Atlas.configure(database: app.db)
            try await operation()
            try await app.asyncShutdown()
        } catch {
            try? await app.asyncShutdown()
            throw error
        }
    }
}
