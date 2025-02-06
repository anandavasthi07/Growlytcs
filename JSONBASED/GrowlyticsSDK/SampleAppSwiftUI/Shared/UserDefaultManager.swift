//
//  UserDefaultManager.swift
//  SampleAppSwiftUI
//
//  Created by Apple on 06/02/25.
//  Copyright © 2025 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class UserDefaultsManager {
    
    enum Keys {
        
        static let signedIn = "Signed-In"
        static let userName = "User-Name"
    }
    
    static let shared = UserDefaultsManager()

    private let defaults = UserDefaults.standard

    // Private init to prevent creating multiple instances
    private init() {}

    // Set a generic value
    func set<T>(_ value: T, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    // Get a generic value
    func get<T>(forKey key: String) -> T? {
        return defaults.object(forKey: key) as? T
    }

    // Remove a value from UserDefaults
    func remove(forKey key: String) {
        defaults.removeObject(forKey: key)
    }

    // Clear all data stored in UserDefaults
    func clearAll() {
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }

    // Example: Save and get a specific data type like a String
    func setString(_ value: String, forKey key: String) {
        set(value, forKey: key)
    }

    func getString(forKey key: String) -> String? {
        return get(forKey: key)
    }
}

