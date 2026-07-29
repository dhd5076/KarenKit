# ``KarenAtlas``

Store durable entities, scalar attributes, and cross-domain relationships through
a typed interface over Fluent.

## Overview

KarenAtlas is the persistence foundation for Karen's evolving world model. It
allows backend modules to define new entity, attribute, and relationship types
without introducing a Fluent model and migration for every domain object.

Atlas deliberately does not replace domain services. A service still validates
requests, enforces rules, coordinates integrations, and translates stored data
into user-story-oriented response types. Atlas only owns generic persistence
behavior.

```swift
let truck = try await Atlas.createEntity(
    .vehicle,
    "2019 Nissan Frontier"
)

try await truck.setAttribute(.vin, to: "1N6AD0EV...")

let make = try await Atlas.createEntity(.vehicleMake, "Nissan")
try await truck.relate(to: make, as: .vehicleMake)
```

KarenAtlas is intended for server-side use. Frontends should call focused
KarenServer endpoints through KarenClient rather than creating arbitrary Atlas
records.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:CoreConcepts>
- <doc:DesignRules>

### Persistence

- ``Atlas``
- ``Entity``
- ``Relationship``
- ``CreateAtlasTables``

### Errors

- ``AtlasError``
