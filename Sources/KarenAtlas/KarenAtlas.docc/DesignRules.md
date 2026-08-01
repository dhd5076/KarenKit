# Design Rules and Limitations

Use Atlas consistently without moving domain behavior into generic storage code.

## Keep Domain Logic in Services

Atlas should know how to:

- Create and fetch entities
- Read and write attributes
- Create, query, and end relationships
- Run operations in a database transaction

A domain service should know how to:

- Validate user input
- Decide which attributes are required
- Enforce relationship cardinality
- Normalize values such as VINs and plate numbers
- Coordinate external integrations
- Translate entities into shared response DTOs

For example, Atlas can store a `.vin` attribute. VehicleService decides whether
the VIN is valid and unique.

## Prefer Workflow-Oriented HTTP APIs

KarenServer controllers should expose operations such as:

```text
Create vehicle
Assign license plate
Turn on light
Record fuel purchase
```

Focused endpoints preserve validation and allow clients to remain independent of
storage decisions. They should remain the normal interface for domain workflows.

KarenServer may also expose a controlled Atlas API for administrative tools,
world-model exploration, and runtime-defined data. That API should apply its own
validation and should not expose destructive persistence operations by default.
It does not replace domain services.

## Keep Atlas Out of Frontends

Karen iOS and future clients should use KarenClient and portable KarenKit types.
They should not import KarenAtlas or understand Fluent records. A generic Atlas
frontend should still access Atlas through KarenServer's controlled API.

This preserves the intended boundary:

```text
View -> ViewModel -> KarenClient -> KarenServer -> Service -> KarenAtlas
```

## Define Stable Identifiers in KarenKit

Put known module identifiers in KarenKit:

```swift
public extension AttributeKey {
    static let vin = AttributeKey(rawValue: "vin")
}
```

Do not scatter raw strings through services. A raw value is persistent data and
should be treated like a database column name: changing it requires migration.

Runtime-defined identifiers remain possible through `init(rawValue:)`, but code
should reuse established constants whenever one exists.

## Current Limitations

KarenAtlas is intentionally an MVP:

- Attribute values are string-backed.
- Attribute `valueType` is descriptive and is not validated.
- Attribute history is not preserved.
- Relationship cardinality is not enforced by Atlas.
- Singular relationship queries do not define ordering when multiple rows match.
- Most domain uniqueness rules are service-level and can be vulnerable to races.
- Entity lists can cause N+1 queries when each entity's attributes are loaded.
- There is no cache or population API.
- There is no generic schema definition for required or optional attributes.
- Hard deletion behavior is not exposed through the public API.

These limitations should be addressed in response to real module requirements,
not by prebuilding a complete schema language.

## When Not to Use Atlas

Prefer conventional tables or specialized records when:

- The data is high-volume time-series information.
- Database-level constraints are essential.
- Complex aggregate queries dominate the workflow.
- A record has a strong, fixed domain meaning and does not need generic graph
  behavior.
- A direct foreign key expresses the relationship more accurately.

Atlas is a world-model foundation, not a requirement that every row in Karen use
EAV storage.
