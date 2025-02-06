//
//  CommonInfo+CoreDataProperties.swift
//  Growlytics
//
//  Created by Pradeep Singh on 07/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData

extension CommonInfo {

    @nonobjc class func fetchSessionInfoRequest() -> NSFetchRequest<CommonInfo> {
        let fetchRequest = NSFetchRequest<CommonInfo>(entityName: "CommonInfo")
        //fetchRequest.fetchLimit = 1
        fetchRequest.predicate = NSPredicate(format: "label = %@", "session_info")
        return fetchRequest
    }

    @NSManaged public var created_at: Int64
    @NSManaged public var id: Int64
    @NSManaged public var label: String?
    @NSManaged public var value: String?

}
