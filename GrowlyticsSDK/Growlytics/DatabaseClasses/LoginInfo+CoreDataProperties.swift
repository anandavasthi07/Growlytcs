//
//  LoginInfo+CoreDataProperties.swift
//  Growlytics
//
//  Created by Ankit Singh  on 16/03/23.
//  Copyright © 2023 Growlytics Technologies Pvt Ltd. All rights reserved.
//
//

import Foundation
import CoreData


extension LoginInfo {

    fileprivate static let loginInfo = "LoginInfo"
    
    @nonobjc class func fetchLoginInfoCreatedAtRequest(timestampToCompare: Int) -> NSFetchRequest<LoginInfo> {
        let fetchRequest = NSFetchRequest<LoginInfo>(entityName: loginInfo)
        fetchRequest.predicate = NSPredicate(format: "created_at <= \(timestampToCompare)")
        return fetchRequest
    }
    
    @nonobjc class func fetchAnyQueuedLoginRequest() -> NSFetchRequest<LoginInfo> {
        let fetchRequest = NSFetchRequest<LoginInfo>(entityName: loginInfo)
        //fetchRequest.fetchLimit = 1
        return fetchRequest
    }
    
    @nonobjc class func fetchRemoveLoginRequest(loginId: String) -> NSFetchRequest<LoginInfo> {
        let fetchRequest = NSFetchRequest<LoginInfo>(entityName: loginInfo)
        fetchRequest.predicate = NSPredicate(format: "id = %@", loginId)
        fetchRequest.fetchLimit = 1
        return fetchRequest
    }

    @NSManaged public var created_at: Int64
    @NSManaged public var data: String?
    @NSManaged public var id: String?

}
