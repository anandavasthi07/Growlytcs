//
//  Constants.swift
//  Growlytics
//
//  Created by Pradeep Singh on 04/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class Constants {
   
    // Db & Storage constants
    static let SHARED_PREF_STORAGE_TAG = "Growlytics"
    static let lastAppVersion = "VersionOfLastRun"
    static let deviceUdid = "DeviceUdid"

    // Event Info Constants
    static let SESSION_LENGTH_MINS = 15
    static let EVENT_APP_LAUNCHED = "GRW_SYSTEM_EVENT_APP_LAUNCH"
    static let EVENT_APP_INSTALLED = "GRW_SYSTEM_EVENT_APP_INSTALL"
    static let EVENT_IDENTIFY_CUSTOMER = "Identify Customer"

    // EVENT STORAGE EXPIRY TIME
    static let STORAGE_EVENT_EXPIRE_AFTER = 60 * 60 * 24 * 3

    // Manifest Constants
    static let MANIFEST_API_KEY             = "GROWLYTICS_API_KEY"
    static let MANIFEST_GLYTICS_TEST_MODE   = "GLYTICS_TEST_MODE"
    static let MANIFEST_DISABLED            = "GROWLYTICS_DISABLED"
    static let MANIFEST_DEBUG               = "GROWLYTICS_DEBUG"
    static let MANIFEST_HOST                = "GROWLYTICS_HOST"
    static let MANIFEST_NOTIFICATION_ICON   = "GROWLYTICS_NOTIFICATION_ICON"

    // Event validation constants
    static let MAX_KEY_LENGTH           = 120
    static let MAX_VALUE_LENGTH         = 512
    static let MAX_CUSTOMER_ID_LENGTH   = 40

    // Engagement Constants
    static let LABEL_FCM_SENDER_ID              = "FCM_SENDER_ID"

    // GrwNotification Constants
    static let NOTIFICATION_DEFAULT_TTL         = 1000 * 60 * 60 * 24 * 4
    static let NOTIFICATION_ACTION_BTNS         = "glytcs_btns"
    static let NOTIFICATION_PRIORITY_HIGH       = "high"
    static let NOTIFICATION_PRIORITY_MAX        = "max"
    static let NOTIFICATION_TTL                 = "wzrk_ttl"
    static let NOTIFICATION_CLICK_CAPTURED      = "glytcs_clk_done"
}

enum EventType : String {
    case appLaunch              = "AppLaunch"
    case customEvent            = "CustomEvent"
    case identifyCustomer       = "IdentifyCustomer"
    case newToken               = "NewToken"
    case appInstalled           = "AppInstalled"
    case notificationImpression = "NotificationImpression"
    case notificationClicked    = "NotificationClicked"
    case deviceRegistration     = "DeviceRegistration"
}
