# Getting Started with KarenAtlas

Configure Atlas and create a small entity graph.

## Add the Products

A server target needs both KarenKit and KarenAtlas:

```swift
.product(name: "KarenKit", package: "karenkit"),
.product(name: "KarenAtlas", package: "karenkit")
```

KarenKit provides portable identifier types. KarenAtlas provides Fluent-backed
persistence.

## Register the Migration

Register ``CreateAtlasTables`` with the Vapor application before running
migrations:

```swift
import KarenAtlas

app.migrations.add(CreateAtlasTables())
try await app.autoMigrate()
```

The migration creates the entity, attribute, and relationship tables. Register it
once alongside the application's other migrations.

## Configure Atlas

Configure Atlas after the application database is available:

```swift
await Atlas.configure(database: app.db)
```

Calls made before configuration throw ``AtlasError/notConfigured``.

The current configuration is process-wide. Tests should configure Atlas with the
test application's database before exercising an Atlas-backed service.

## Define Module Identifiers

Add known identifiers in KarenKit as module-owned extensions:

```swift
public extension EntityType {
    static let vehicle = EntityType(rawValue: "vehicle")
}

public extension AttributeKey {
    static let vin = AttributeKey(rawValue: "vin")
}

public extension RelationshipType {
    static let vehicleMake = RelationshipType(rawValue: "vehicle_make")
}
```

Use stable raw values. Changing a raw value changes the stored identifier and
requires an explicit data migration.

## Create and Query an Entity

```swift
let truck = try await Atlas.createEntity(
    .vehicle,
    "2019 Nissan Frontier"
)

try await truck.setAttribute(.vin, to: "1N6AD0EV...")

let fetchedTruck = try await Atlas.entity(id: truck.id)
let vin = try await fetchedTruck.attribute(.vin)
let vinWithType = try await fetchedTruck.attributeValue(.vin)
let vehicles = try await Atlas.entities(ofType: .vehicle)
```

Entity values are lightweight snapshots. Attribute methods query the database on
each call in the current implementation.

## Find One Entity

Use the singular type query when the domain only needs one matching entity:

```swift
let vehicle = try await Atlas.entity(ofType: .vehicle)
```

The result is optional because no matching entity may exist. When several
entities match, Atlas returns one without defining their order. Use this form
only when any match is sufficient or when the domain enforces uniqueness.

Add an attribute and exact value to perform a filtered lookup:

```swift
let vehicle = try await Atlas.entity(
    ofType: .vehicle,
    where: .vin,
    equals: "1N6AD0EV..."
)
```

The entity type is optional when the attribute identifies entities across the
entire world model:

```swift
let matchingEntity = try await Atlas.entity(
    where: .vin,
    equals: "1N6AD0EV..."
)
```

The `where` and `equals` arguments are provided together. Attribute matching is
exact and uses the value as it is stored, so domain services remain responsible
for normalization such as uppercasing a VIN before querying.

## Create a Relationship

```swift
let make = try await Atlas.createEntity(.vehicleMake, "Nissan")

let relationship = try await truck.relate(
    to: make,
    as: .vehicleMake
)
```

Relationships are directional:

```text
truck --vehicle_make--> Nissan
```

Query that outgoing relationship without loading every matching row:

```swift
let makeRelationship = try await Atlas.relationship(
    subject: truck.id,
    type: .vehicleMake
)

let makeId = makeRelationship?.object
```

When the relationship identifier is already known, fetch it directly:

```swift
let relationship = try await Atlas.relationship(id: relationshipId)
```

Use ``Atlas/relationships(subject:object:type:includeEnded:)`` when all matching
relationships are needed. Use
``Atlas/relationship(subject:object:type:includeEnded:)`` when the domain expects
one match. Atlas does not itself enforce that only one matching relationship
exists.

End a relationship without deleting its history:

```swift
try await relationship.end()
```

Active relationships are returned by default. Pass `includeEnded: true` when
historical records are required.

## Use a Transaction

Use ``Atlas/transaction(_:)`` when several writes must succeed or fail together:

```swift
let vehicle = try await Atlas.transaction {
    let vehicle = try await Atlas.createEntity(.vehicle, "My truck")
    try await vehicle.setAttribute(.color, to: "black")
    return vehicle
}
```

Atlas entity and relationship methods called inside the closure automatically use
the transaction-scoped database.
