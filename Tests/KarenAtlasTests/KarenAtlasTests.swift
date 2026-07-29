import Fluent
import FluentSQLiteDriver
import Foundation
import KarenKit
import Testing
import Vapor
@testable import KarenAtlas

@Suite("KarenAtlas", .serialized)
struct KarenAtlasTests {
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
    
    @Test("Creates, updates, lists, and removes attributes")
    func attributeLifecycle() async throws {
        try await withAtlas {
            let vehicle = try await Atlas.createEntity(
                type: .vehicle,
                displayName: "My Truck"
            )
            
            let missingValue = try await vehicle.attribute(.color)
            #expect(missingValue == nil)
            
            try await vehicle.setAttribute(.color, to: "blue")
            let createdValue = try await vehicle.attribute(.color)
            #expect(createdValue == "blue")
            
            try await vehicle.setAttribute(.color, to: "red")
            let updatedValue = try await vehicle.attribute(.color)
            let attributes = try await vehicle.attributes()
            
            #expect(updatedValue == "red")
            #expect(attributes == [.color: "red"])
            
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
            
            #expect(relationship.subject == owner.id)
            #expect(relationship.object == vehicle.id)
            #expect(relationship.type == RelationshipType(rawValue: "owns"))
            #expect(activeRelationships.map(\.id) == [relationship.id])
            
            let endedAt = Date(timeIntervalSince1970: 1_800_000_000)
            let endedRelationship = try await relationship.end(at: endedAt)
            let remainingActive = try await vehicle.relationships()
            let completeHistory = try await vehicle.relationships(
                includeEnded: true
            )
            
            #expect(endedRelationship.validUntil == endedAt)
            #expect(remainingActive.isEmpty)
            #expect(completeHistory.map(\.id) == [relationship.id])
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
