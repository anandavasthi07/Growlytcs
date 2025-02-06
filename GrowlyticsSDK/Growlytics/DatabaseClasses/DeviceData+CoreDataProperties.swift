//
//  DeviceData+CoreDataProperties.swift
//  Growlytics
//
//  Created by Ankit Singh  on 10/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension DeviceData {

    fileprivate static let deviceData = "DeviceData"
    
    @nonobjc class func fetchDeviceCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<DeviceData> {
        let fetchRequest = NSFetchRequest<DeviceData>(entityName: deviceData)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedEventRequest() -> NSFetchRequest<DeviceData> {
        let fetchRequest = NSFetchRequest<DeviceData>(entityName: deviceData)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveDeviceDataRequest(deviceId: String) -> NSFetchRequest<DeviceData> {
        let fetchRequest = NSFetchRequest<DeviceData>(entityName: deviceData)
        fetchRequest.predicate = NSPredicate(format: "id = %@", deviceId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }

    @NSManaged public var id: String?
    @NSManaged public var data: String?
    @NSManaged public var created_at: Int64

}
