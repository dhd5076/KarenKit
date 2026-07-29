//
//  EntityAttributeRecord.swift
//  KarenAtlas
//
//  Created by Dylan Dunn on 7/28/26.
//

import Foundation
import Fluent

final class AttributeRecord: Model, @unchecked Sendable {
    
    static let schema = "attributes"
    
    enum FieldKeys {
        static let entityID: FieldKey = "entity_id"
        static let attributeName: FieldKey = "attribute_name"
        static let value: FieldKey = "value"
        static let valueType: FieldKey = "value_type"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Parent(key: FieldKeys.entityID)
    var entity: EntityRecord
    
    @Field(key: FieldKeys.attributeName)
    var attributeName: String
    
    @Field(key: FieldKeys.value)
    var value: String
    
    @Field(key: FieldKeys.valueType)
    var valueType: String
}
