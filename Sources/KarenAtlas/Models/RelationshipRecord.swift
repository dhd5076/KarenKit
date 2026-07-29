//
//  RelationshipRecord.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/24/26.
//

import Foundation
import Fluent

final class RelationshipRecord: Model, @unchecked Sendable {
    
    static let schema = "atlas_relationships"
    
    enum FieldKeys {
        static let subject: FieldKey = "subject"
        static let relationshipType: FieldKey = "relationship_type"
        static let object: FieldKey = "object"
        static let validFrom: FieldKey = "valid_from"
        static let validUntil: FieldKey = "valid_until"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: FieldKeys.subject)
    var subject: EntityRecord
    
    @Field(key: FieldKeys.relationshipType)
    var relationshipType: String
    
    @Parent(key: FieldKeys.object)
    var object: EntityRecord
    
    @OptionalField(key: FieldKeys.validFrom)
    var validFrom: Date?
    
    @OptionalField(key: FieldKeys.validUntil)
    var validUntil: Date?
    
    init() { }
    
    init(
        id: UUID? = nil,
        subject: UUID,
        relationshipType: String,
        object: UUID,
        validFrom: Date? = nil,
        validUntil: Date? = nil
    ) {
        self.id = id
        self.$subject.id = subject
        self.relationshipType = relationshipType
        self.$object.id = object
        self.validFrom = validFrom
        self.validUntil = validUntil
    }
}
