//  Entity.swift
//  KarenServer
//
//  Created by Dylan Dunn on 7/24/26.
//

import Foundation
import Fluent

final class EntityRecord: Model, @unchecked Sendable {
    
    static let schema = "atlas_entities"
    
    enum FieldKeys {
        static let type: FieldKey = "type"
        static let displayName: FieldKey = "display_name"
    }
    
    @ID(key: .id)
    var id: UUID?
    
    @Field(key: FieldKeys.type)
    var type: String
    
    @Field(key: FieldKeys.displayName)
    var displayName: String
}
