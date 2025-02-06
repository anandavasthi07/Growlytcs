//
//  CustomerAttributes+CoreDataProperties.swift
//  Growlytics
//
//  Created by Ankit Singh  on 18/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension CustomerAttributes {

    fileprivate static let customerAttributes = "CustomerAttributes"
    
    @nonobjc class func fetchCustomerAttributesCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<CustomerAttributes> {
        let fetchRequest = NSFetchRequest<CustomerAttributes>(entityName: customerAttributes)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedCustomerAttributesRequest() -> NSFetchRequest<CustomerAttributes> {
        let fetchRequest = NSFetchRequest<CustomerAttributes>(entityName: customerAttributes)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveCustomerAttributesRequest(customerAttributesId: String) -> NSFetchRequest<CustomerAttributes> {
        let fetchRequest = NSFetchRequest<CustomerAttributes>(entityName: customerAttributes)
        fetchRequest.predicate = NSPredicate(format: "id = %@", customerAttributesId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }


    @NSManaged public var created_at: Int64
    @NSManaged public var data: String?
    @NSManaged public var id: String?

}
