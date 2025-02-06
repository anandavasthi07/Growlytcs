//
//  Event+CoreDataProperties.swift
//  Growlytics
//
//  Created by Pradeep Singh on 07/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension Event {
    fileprivate static let event = "Event"
    
    @nonobjc class func fetchEventCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<Event> {
        let fetchRequest = NSFetchRequest<Event>(entityName: event)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedEventRequest() -> NSFetchRequest<Event> {
        let fetchRequest = NSFetchRequest<Event>(entityName: event)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveEventRequest(eventId: String) -> NSFetchRequest<Event> {
        let fetchRequest = NSFetchRequest<Event>(entityName: event)
        fetchRequest.predicate = NSPredicate(format: "id = %@", eventId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    

    @NSManaged public var id: String?
    @NSManaged public var data: String?
    @NSManaged public var created_at: Int64

}
