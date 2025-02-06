//
//  LogoutInfo+CoreDataProperties.swift
//  Growlytics
//
//  Created by Ankit Singh  on 17/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension LogoutInfo {

    fileprivate static let logoutInfo = "LogoutInfo"
    
    @nonobjc class func fetchLogoutInfoCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<LogoutInfo> {
        let fetchRequest = NSFetchRequest<LogoutInfo>(entityName: logoutInfo)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedLogoutRequest() -> NSFetchRequest<LogoutInfo> {
        let fetchRequest = NSFetchRequest<LogoutInfo>(entityName: logoutInfo)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveLogoutRequest(logoutId: String) -> NSFetchRequest<LogoutInfo> {
        let fetchRequest = NSFetchRequest<LogoutInfo>(entityName: logoutInfo)
        fetchRequest.predicate = NSPredicate(format: "id = %@", logoutId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }

    @NSManaged public var created_at: Int64
    @NSManaged public var data: String?
    @NSManaged public var id: String?

}
