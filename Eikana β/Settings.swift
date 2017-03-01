//
//  Setting.swift
//  Eikana β
//
//  Created by 岩田将成 on 2017/03/02.
//  Copyright © 2017年 iMasanari. All rights reserved.
//

import Foundation

class Settings {
    static let defaults = UserDefaults.standard
    
    static func get<T>(_ forKey: String, defaultValue: T) -> T {
        if let value = defaults.object(forKey: forKey) as? T {
            return value
        }
        
        return defaultValue
    }
    
    static func set(_ forKey: String, value: Any) {
        defaults.set(value, forKey: forKey)
    }
    
    static func reset() {
        defaults.removePersistentDomain(forName: Bundle.main.bundleIdentifier!)
    }
}
