//
//  NewSession+CoreDataProperties.swift
//  Growlytics
//
//  Created by Ankit Singh  on 13/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension NewSession {

    fileprivate static let newSessionData = "NewSession"
    
    @nonobjc class func fetchNewSessionCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<NewSession> {
        let fetchRequest = NSFetchRequest<NewSession>(entityName: newSessionData)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedNewSessionRequest() -> NSFetchRequest<NewSession> {
        let fetchRequest = NSFetchRequest<NewSession>(entityName: newSessionData)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveDeviceDataRequest(newSessionId: String) -> NSFetchRequest<NewSession> {
        let fetchRequest = NSFetchRequest<NewSession>(entityName: newSessionData)
        fetchRequest.predicate = NSPredicate(format: "id = %@", newSessionId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    @NSManaged public var created_at: Int64
    @NSManaged public var data: String?
    @NSManaged public var id: String?

}
