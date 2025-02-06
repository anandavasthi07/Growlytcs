//
//  JSONDatabase.swift
//  Growlytics
//
//  Created by Apple on 13/12/24.
//  Copyright © 2024 Growlytics Technologies Pvt Ltd. All rights reserved.
//
import Foundation

// Define a generic JSONDatabase class
class JSONDatabase<T: Identifiable> {
    private let fileName: String
    
    private var fileURL: URL {
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentDirectory.appendingPathComponent(fileName)
    }

    // Initialize the JSON file if it doesn't exist
    init(fileName: String) {
        self.fileName = fileName
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                let initialData: [[String: Any]] = []
                let data = try JSONSerialization.data(withJSONObject: initialData, options: [])
                try data.write(to: fileURL)
                print("Database created at: \(fileURL.path)")
            } catch {
                print("Failed to create database: \(error.localizedDescription)")
            }
        }
    }

    // Convert a model to a dictionary
    func toDictionary(item: T) -> [String: Any] {
        var dict: [String: Any] = [:]
        let mirror = Mirror(reflecting: item)
        for case let (label?, value) in mirror.children {
            dict[label] = value
        }
        return dict
    }

    // Convert a dictionary back to the model (this assumes the model can be initialized with a dictionary)
    func fromDictionary(dict: [String: Any]) -> T? {
        // This is a simple way to convert the dictionary back to a model, but it will depend on how your model is designed
        // and how to convert individual fields. You may need custom initialization logic here.
        return nil // Placeholder
    }

    // Write data to the JSON file
    func write(item: T) {
        do {
            var currentData = readAll()
            let dict = toDictionary(item: item)
            currentData.append(dict)
            let data = try JSONSerialization.data(withJSONObject: currentData, options: [])
            try data.write(to: fileURL)
            print("Item added successfully.")
        } catch {
            print("Failed to write to database: \(error.localizedDescription)")
        }
    }

    // Read all data from the JSON file
    func readAll() -> [[String: Any]] {
        do {
            let data = try Data(contentsOf: fileURL)
            let items = try JSONSerialization.jsonObject(with: data, options: []) as? [[String: Any]] ?? []
            return items
        } catch {
            print("Failed to read database: \(error.localizedDescription)")
            return []
        }
    }

    // Read a specific item by ID
    func read(byID id: T.ID) -> T? {
        let items = readAll()
        // Here you'd need to map the dictionary back to the model, which could be done based on your model's initialization logic
        return items.compactMap { fromDictionary(dict: $0) }.first { $0.id == id }
    }

    // Update an item by ID
    func update(item: T) {
        do {
            var currentData = readAll()
            let dict = toDictionary(item: item)
            if let index = currentData.firstIndex(where: { $0["id"] as? String == item.id as? String }) {
                currentData[index] = dict
                let data = try JSONSerialization.data(withJSONObject: currentData, options: [])
                try data.write(to: fileURL)
                print("Item updated successfully.")
            } else {
                print("Item with ID \(item.id) not found.")
            }
        } catch {
            print("Failed to update database: \(error.localizedDescription)")
        }
    }

    // Delete an item by ID
    func delete(byID id: T.ID) {
        do {
            var currentData = readAll()
            currentData.removeAll { $0["id"] as? String == id as? String }
            let data = try JSONSerialization.data(withJSONObject: currentData, options: [])
            try data.write(to: fileURL)
            print("Item deleted successfully.")
        } catch {
            print("Failed to delete from database: \(error.localizedDescription)")
        }
    }
}
