# KarenKit

KarenKit contains shared types and reusable infrastructure for the Karen personal
assistant project. It provides the contracts used between KarenServer and client
applications, a portable API client, and KarenAtlas, the server-side entity store.

KarenKit is an internal package under active development. Its APIs may change as
new Karen modules are migrated to Atlas.

## Products

| Product | Purpose | Intended consumers |
| --- | --- | --- |
| `KarenKit` | Portable DTOs, module metadata, and Atlas identifier types | Server and clients |
| `KarenAtlas` | Fluent-backed entity, attribute, and relationship persistence | Server only |
| `KarenClient` | Typed wrappers around KarenServer HTTP endpoints | iOS, macOS, and other Swift clients |
| `KarenShared` | Compatibility product that re-exports `KarenKit` | Existing code during migration |

The dependency direction is:

```text
KarenKit
├── KarenClient
├── KarenAtlas
└── KarenShared

KarenServer
├── KarenKit
└── KarenAtlas

Karen iOS
├── KarenKit / KarenShared
└── KarenClient
```

`KarenKit` does not depend on Fluent or Vapor. `KarenAtlas` owns the Fluent
integration, and KarenServer provides Vapor-specific conformances for shared DTOs.

## Adding the Package

Add the package using Swift Package Manager:

```swift
.package(
    url: "https://github.com/dhd5076/KarenKit.git",
    branch: "main"
)
```

Then add only the products the target needs:

```swift
.product(name: "KarenKit", package: "karenkit")
.product(name: "KarenAtlas", package: "karenkit")
.product(name: "KarenClient", package: "karenkit")
```

## KarenKit

Import `KarenKit` for shared request and response types, module metadata, and
typed Atlas identifiers:

```swift
import KarenKit

let request = VehicleRequest(
    displayName: "My truck",
    vehicleType: "truck",
    modelYear: 2019,
    makeId: nil,
    modelId: nil,
    trim: nil,
    color: "black",
    vin: nil
)

let type: EntityType = .vehicle
let key: AttributeKey = .vin
```

Module-specific Atlas identifiers are declared as extensions:

```swift
public extension EntityType {
    static let vehicle = EntityType(rawValue: "vehicle")
}

public extension AttributeKey {
    static let vin = AttributeKey(rawValue: "vin")
}
```

These are extensible value types rather than closed enums. Runtime-defined values
remain possible:

```swift
let customType = EntityType(rawValue: "solar_array")
```

## KarenAtlas

KarenAtlas provides a typed interface over three persistent concepts:

- An `Entity` is a durable object with an identity, type, and display name.
- An attribute associates an entity with a scalar string value.
- A `Relationship` associates one entity with another entity.

```swift
let truck = try await Atlas.createEntity(
    .vehicle,
    "2019 Nissan Frontier"
)

try await truck.setAttribute(.vin, to: "1N6AD0EV...")
let vin = try await truck.attribute(.vin)

let make = try await Atlas.createEntity(.vehicleMake, "Nissan")
try await truck.relate(to: make, as: .vehicleMake)
```

KarenAtlas is server-side infrastructure. Client applications should use
workflow-oriented HTTP endpoints through `KarenClient`, not manipulate Atlas
records directly.

See the `KarenAtlas.docc` catalog in Xcode for setup, core concepts, design rules,
and current limitations.

## KarenClient

Configure one client with the KarenServer base URL:

```swift
import KarenClient

let client = KarenClient(
    baseURL: URL(string: "https://api.example.com")!,
    applicationToken: ""
)

let vehicles = try await client.getVehicles()
```

An empty application token omits the authorization header. Authentication behavior
will be expanded when KarenServer introduces its application-token contract.

## Development

Run the package tests:

```bash
swift test
```

Build documentation in Xcode with **Product > Build Documentation**.

When developing KarenServer and KarenKit together, SwiftPM can use the local
checkout:

```bash
swift package edit karenkit --path ../KarenKit
```

Before committing KarenServer's resolved dependencies:

1. Commit and push KarenKit.
2. Run `swift package unedit karenkit` in KarenServer.
3. Run `swift package update karenkit`.
4. Commit the updated `Package.resolved`.

This prevents a local edit override from removing KarenKit's remote lockfile pin.

