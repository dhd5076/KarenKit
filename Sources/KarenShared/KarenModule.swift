//
//  Module.swift
//  KarenShared
//
//  Created by Dylan Dunn on 6/11/26.
//

import Foundation

public protocol KarenModule {
    static var route: String { get }
    static var displayName: String { get }
    static var icon: String { get }
}

public extension KarenModule {
    static func path(_ resourcePath: String) -> String {
            "\(route)/\(resourcePath)"
        }
}
