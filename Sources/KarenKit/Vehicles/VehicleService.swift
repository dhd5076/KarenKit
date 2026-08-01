//
//  VehicleService.swift
//  KarenClient
//
//  Created by Dylan Dunn on 8/1/26.
//

import Foundation
import KarenKit

public struct VehicleService: Sendable {
    private let transport: ClientTransport

    init(transport: ClientTransport) {
        self.transport = transport
    }

    public func getAll() async throws -> [Vehicle] {
        try await transport.get([VehicleModule.route])
    }

    public func get(id: UUID) async throws -> Vehicle {
        try await transport.get([VehicleModule.route, id.uuidString])
    }

    public func create(_ request: VehicleRequest) async throws -> Vehicle {
        try await transport.send(
            method: "POST",
            path: [VehicleModule.route],
            body: request
        )
    }

    public func update(
        id: UUID,
        request: VehicleRequest
    ) async throws -> Vehicle {
        try await transport.send(
            method: "PUT",
            path: [VehicleModule.route, id.uuidString],
            body: request
        )
    }

    public func getMakes() async throws -> [VehicleMake] {
        try await transport.get([VehicleModule.route, "makes"])
    }

    public func createMake(displayName: String) async throws -> VehicleMake {
        try await transport.send(
            method: "POST",
            path: [VehicleModule.route, "makes"],
            body: VehicleNameRequest(displayName: displayName)
        )
    }

    public func getModels(makeId: UUID) async throws -> [VehicleModel] {
        try await transport.get([
            VehicleModule.route,
            "makes",
            makeId.uuidString,
            "models"
        ])
    }

    public func createModel(
        makeId: UUID,
        displayName: String
    ) async throws -> VehicleModel {
        try await transport.send(
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
    ) async throws -> [VehicleLicensePlateAssignment] {
        try await transport.get([
            VehicleModule.route,
            vehicleId.uuidString,
            "license-plates"
        ])
    }

    public func createAndAssignLicensePlate(
        vehicleId: UUID,
        request: LicensePlateRequest
    ) async throws -> VehicleLicensePlateAssignment {
        try await transport.send(
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
    ) async throws -> VehicleLicensePlateAssignment {
        try await transport.send(
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
    ) async throws -> VehicleLicensePlateAssignment {
        try await transport.send(
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
}
