//
//  SqliteHelper.swift
//  Growlytics
//
//  Created by Pradeep Singh on 06/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class JSONHelper: NSObject {
    
    // Singleton
    private static var instance: JSONHelper? = nil
    
    // JSONDatabase for each model type with "growSDK" prefix
    private let sessionInfoDb: JSONDatabase<SessionInfoModel>
    private let eventDb: JSONDatabase<EventModel>
    private let deviceDataDb: JSONDatabase<DeviceInfoModel>
    private let newSessionDb: JSONDatabase<NewSessionModel>
    private let loginDb: JSONDatabase<LoginModel>
    private let logoutDb: JSONDatabase<LogoutModel>
    private let customerAttributesDb: JSONDatabase<CustomerAttributesModel>
    
    private override init() {
        // Initialize all databases with the "growSDK" prefix in filenames
        self.sessionInfoDb = JSONDatabase(fileName: "growSDK_sessionInfoModel.json")
        self.eventDb = JSONDatabase(fileName: "growSDK_eventModel.json")
        self.deviceDataDb = JSONDatabase(fileName: "growSDK_deviceInfoModel.json")
        self.newSessionDb = JSONDatabase(fileName: "growSDK_newSessionModel.json")
        self.loginDb = JSONDatabase(fileName: "growSDK_loginModel.json")
        self.logoutDb = JSONDatabase(fileName: "growSDK_logoutModel.json")
        self.customerAttributesDb = JSONDatabase(fileName: "growSDK_customerAttributesModel.json")
    }
    
    static func getInstance() -> JSONHelper {
        if instance == nil {
            instance = JSONHelper()
            Logger.instance.info(suffix: "SqliteHelper", message: "Instance initialized.")
        }
        return instance!
    }
    
    // Session Info Management
    func getSessionInfo() -> SessionInfoModel? {
        guard let sessionInfo = sessionInfoDb.readAll().last else { return nil }
        return SessionInfoModel.fromDictionary(dict: sessionInfo)
    }
    
    func saveSessionInfo(_ sessionInfoModel: SessionInfoModel?) {
        guard let sessionInfo = sessionInfoModel else { return }
        sessionInfoDb.write(item: sessionInfo)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Session info stored in JSON.")
    }
    
    // Event Queue Management
    func queueEventToDb(_ event: EventModel) {
        eventDb.write(item: event)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Event stored in JSON.")
    }
    
    func getAnyQueuedEvent() -> [EventModel] {
        var arrayEvents: [EventModel] = []
        for eventDict in  eventDb.readAll() {
            arrayEvents.append(EventModel.fromDictionary(dictionary: eventDict))
        }
        return arrayEvents
    }
    
    func removeEventFromDb(_ eventId: String) {
        eventDb.delete(byID: eventId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Event removed from JSON.")
    }
    
    //    func removeExpiredEventsFromDb() {
    //        let timestampToCompare = Int(Date.currentTimeMillis / 1000) - Constants.STORAGE_EVENT_EXPIRE_AFTER
    //        var arrayEvents: [EventModel] = []
    //        for eventDict in  eventDb.readAll() {
    //            arrayEvents.append(EventModel.fromDictionary(dictionary: eventDict))
    //        }
    //        arrayEvents.filter{$0.}
    //        let expiredEvents = arrayEvents.filter { $0.createdAt < timestampToCompare }
    //        expiredEvents.forEach { eventDb.delete(byID: $0.id) }
    //        Logger.instance.debug(suffix: "SqliteHelper", message: "Expired events removed from JSON.")
    //    }
    
    
    func removeExpiredEventsFromDb() {
        self.synchronized(self){
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing expired events from db.")
            let timestampToCompare = Int((Date.currentTimeMillis / 1000)) - Constants.STORAGE_EVENT_EXPIRE_AFTER
            let results = EventModel.fetchEventCreatedAt(timestampToCompare: timestampToCompare, events: getAnyQueuedEvent())
            for obj in results {
                removeEventFromDb(obj.id ?? "0")
            }
            // Save Database
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removed expired events from db.")
        }
    }
    // Device Data Management
    func queueDeviceDataToDb(_ deviceInfo: DeviceInfoModel) {
        deviceDataDb.write(item: deviceInfo)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Device data stored in JSON.")
    }
    
    func getAnyQueuedDeviceData() -> [DeviceInfoModel] {
        var arrayDeviceInfo: [DeviceInfoModel] = []
        for deviceDict in  deviceDataDb.readAll() {
            arrayDeviceInfo.append(DeviceInfoModel.fromDictionary(dict: deviceDict))
        }
        
        return arrayDeviceInfo
    }
    
    func removeDeviceDataFromDb(_ deviceId: String) {
        deviceDataDb.delete(byID: deviceId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Device data removed from JSON.")
    }
    
    // New Session Management
    func queueNewSessionDataToDb(_ newSession: NewSessionModel) {
        newSessionDb.write(item: newSession)
        Logger.instance.debug(suffix: "SqliteHelper", message: "New session data stored in JSON.")
    }
    
    func getAnyQueuedNewSession() -> [NewSessionModel] {
        var array: [NewSessionModel] = []
        for deviceDict in  newSessionDb.readAll() {
            array.append(NewSessionModel.fromDictonary(dict: deviceDict))
        }
        return array
    }
    
    func removeNewSessionFromDb(_ newSessionId: String) {
        newSessionDb.delete(byID: newSessionId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "New session removed from JSON.")
    }
    
    // Login Data Management
    func queueLoginDataToDb(_ loginInfo: LoginModel) {
        loginDb.write(item: loginInfo)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Login data stored in JSON.")
    }
    
    func getAnyQueuedLoginData() -> [LoginModel] {
        var array: [LoginModel] = []
        for deviceDict in  loginDb.readAll() {
            array.append(LoginModel.fromDictionary(dict: deviceDict))
        }
        return array
    }
    
    func removeLoginDataFromDb(_ loginId: String) {
        loginDb.delete(byID: loginId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Login data removed from JSON.")
    }
    
    // Logout Data Management
    func queueLogoutDataToDb(_ logoutInfo: LogoutModel) {
        logoutDb.write(item: logoutInfo)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Logout data stored in JSON.")
    }
    
    func getAnyQueuedLogoutData() -> [LogoutModel] {
        var array: [LogoutModel] = []
        for deviceDict in  logoutDb.readAll() {
            array.append(LogoutModel.fromDictionary(dict: deviceDict))
        }
        return array
    }
    
    func removeLogoutDataFromDb(_ logoutId: String) {
        logoutDb.delete(byID: logoutId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Logout data removed from JSON.")
    }
    
    // Customer Attributes Data Management
    func queueCustomerAttributesDataToDb(_ customerAttributesInfo: CustomerAttributesModel) {
        customerAttributesDb.write(item: customerAttributesInfo)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Customer attributes data stored in JSON.")
    }
    
    func getAnyQueuedCustomerAttributeData() -> [CustomerAttributesModel] {
        var array: [CustomerAttributesModel] = []
        for deviceDict in  customerAttributesDb.readAll() {
            array.append(CustomerAttributesModel.fromDictionary(dict: deviceDict))
        }
        return array
    }
    
    func removeCustomerAttributesDataFromDb(_ customerAttributesId: String) {
        customerAttributesDb.delete(byID: customerAttributesId)
        Logger.instance.debug(suffix: "SqliteHelper", message: "Customer attributes data removed from JSON.")
    }
}
