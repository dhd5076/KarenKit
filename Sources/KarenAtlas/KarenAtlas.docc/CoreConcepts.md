# Core Concepts

Understand the storage primitives and their roles in Karen's world model.

## Entity

An ``Entity`` represents a durable, referenceable object:

- A person
- A vehicle
- A license plate
- A pantry
- A physical location

Every entity has:

- A UUID
- An `EntityType`
- A display name

The display name supports generic lists, search results, and graph views. Detailed
domain data belongs in attributes, relationships, or derived response types.

Events and observations may eventually be represented as specialized entities,
but that convention has not yet been finalized.

## Entity Type

`EntityType` is an extensible wrapper around a stored string:

```swift
let vehicle = EntityType(rawValue: "vehicle")
```

Known values are exposed as static members:

```swift
let vehicle: EntityType = .vehicle
```

This provides type safety without closing the system to runtime-defined types.
Atlas writes `rawValue` to the database.

## Attribute

An attribute associates an entity with a scalar value:

```text
vehicle --vin--> "1N6AD0EV..."
vehicle --color--> "black"
```

`AttributeKey` distinguishes attribute identifiers from entity and relationship
types:

```swift
try await vehicle.setAttribute(.vin, to: "1N6AD0EV...")
let vin = try await vehicle.attribute(.vin)
```

Attributes are currently stored as strings with a string `valueType` descriptor.
Atlas does not yet decode typed values or validate an entity's allowed attributes.
Domain services remain responsible for that behavior.

An entity can have at most one current value for a given attribute key.

## Relationship

A ``Relationship`` creates a directional connection between two entities:

```text
subject --relationship type--> object
```

For example:

```text
license plate --license_plate_assignment--> vehicle
vehicle --vehicle_make--> make
```

Relationships are appropriate when the value is another durable entity.
`RelationshipType` prevents relationship identifiers from being confused with
attribute keys.

Relationships can include optional start and end dates. Ending a relationship
preserves its history.

Query all matching relationships when the domain permits more than one result:

```swift
let models = try await Atlas.relationships(
    object: make.id,
    type: .modelMake
)
```

Query one relationship when the domain expects a single match:

```swift
let makeRelationship = try await Atlas.relationship(
    subject: vehicle.id,
    type: .vehicleMake
)
```

Both operations return active relationships by default. The singular operation
does not enforce uniqueness and does not define which result is returned when
multiple relationships match. Relationship cardinality remains a domain rule.

## Attributes Versus Relationships

Use an attribute when the value is scalar:

```text
VIN
color
model year
normalized plate number
```

Use a relationship when the value has independent identity:

```text
vehicle make
vehicle model
license plate assignment
ownership
location
```

Use a conventional domain record when the relationship is intrinsic to a
specialized workflow or needs behavior that does not fit the generic graph.
Atlas should not turn every database concept into a generic relationship.

## Entity Snapshots and Database Access

An `Entity` contains only its identity, type, and display name. It does not eagerly
load attributes or relationships.

Calls such as these currently query the database:

```swift
try await entity.attribute(.vin)
try await entity.attributes()
try await entity.relationships()
```

There is no entity cache or `populate()` behavior yet. Add optimization only after
real query patterns show it is necessary.
