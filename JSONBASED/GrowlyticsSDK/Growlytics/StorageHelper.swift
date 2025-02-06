//
//  StorageHelper.swift
//  Growlytics
//
//  Created by Pradeep Singh on 08/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

final class StorageHelper {
    
    private static let DEVICE_ID = "device_id"
    
    static var getDeviceId: String? {
        get {
            return  UserDefaults.standard.string(forKey: DEVICE_ID)
        }
        set(newValue){
            UserDefaults.standard.set(newValue, forKey: DEVICE_ID)
            UserDefaults.standard.synchronize()
        }
    }
}
