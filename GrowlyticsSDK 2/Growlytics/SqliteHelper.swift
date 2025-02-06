//
//  SqliteHelper.swift
//  Growlytics
//
//  Created by Pradeep Singh on 06/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class SqliteHelper: NSObject {
    
    private static var instance : SqliteHelper? = nil
    
    //MARK: ****************** Start: Singleton Class Methods ********************
    
    private override init() {
    }
    
    static func getInstance() -> SqliteHelper{
        if (instance != nil) {
            Logger.instance.info(suffix: "SqliteHelper", message: "Instance is already initialized.")
            return instance!
        }
        
        // Initialize instance.
        instance = SqliteHelper()
        return instance!
    }
    
    //MARK: ****************** End: Singleton Class Methods **********************
    
    //MARK: *********************** Start: SessionInfo Mgt ***********************
    
    func getSessionInfo() -> SessionInfoModel? {
        do {
            //We need to create a context from this container
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            //Prepare the request of type NSFetchRequest for the entity
            let result = try viewContext.fetch(CommonInfo.fetchSessionInfoRequest())
            
            return SessionInfoModel.fromJson(result.last?.value ?? "")
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read session info.", error: error)
            return nil
        }
    }
    
    func saveSessionInfo(_ sessionInfoModel : SessionInfoModel?) {
        self.synchronized(self){
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing session info in db.")
            
            //check for memory overflow
            
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = CommonInfo.fetchSessionInfoRequest()
            
            do{
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                
                let commonInfo = CommonInfo(entity: CommonInfo.entity(), insertInto: viewContext)
                commonInfo.label = "session_info"
                commonInfo.value = sessionInfoModel?.toString()
                commonInfo.created_at = Date.currentTimeMillis
                
                // Insert new session info
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Session stored in db.")
            }catch {
                debugPrint(error)
                Logger.instance.info(suffix: "SqliteHelper", message: "Error adding data to event table " + (fetchRequest.entityName ?? "No Entity Here") + " Recreating DB")
            }
        }
    }
    //MARK: ************************** End: SessionInfo Mgt ***************************
    
    //MARK: ************************ Start: Event Queue Mgt ***************************
    
    func queueEventToDb(_ event:EventModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing event in db. " + event.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = Event(entity: Event.entity(), insertInto: viewContext)
            entity.data = event.toString()
            entity.id = event.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "Event stored in db.")
        }
    }
    
    func getAnyQueuedEvent() -> [EventModel] {
        var arrEventModel = [EventModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = Event.fetchAnyQueuedEventRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrEventModel.append(EventModel.fromJson(eventData: item.data!)!)
            }
            return arrEventModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read event list.", error: error)
            return arrEventModel
        }
    }
    
    func removeEventFromDb(_ eventId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing event from db. id:" + eventId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = Event.fetchRemoveEventRequest(eventId: eventId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Event removed from db. id: " + eventId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove event from db. Recreating DB")
            }
        }
    }
    
    func removeExpiredEventsFromDb() {
        self.synchronized(self){
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing expired events from db.")
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let timestampToCompare = Int((Date.currentTimeMillis / 1000)) - Constants.STORAGE_EVENT_EXPIRE_AFTER
                let fetchRequest = Event.fetchEventCreatedAtRequest(timestampToCompare: timestampToCompare)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Removed expired events from db.")
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove expired events from db. Recreating DB", error: error)
            }
        }
    }
    //MARK: ************************** End: Event Queue Mgt *******************************
    
    func queueDeviceDataToDb(_ deviceInfo: DeviceInfoModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing event in db. " + deviceInfo.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = DeviceData(entity: DeviceData.entity(), insertInto: viewContext)
            entity.data = deviceInfo.toString()
            entity.id = deviceInfo.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "Device Data stored in db.")
        }
    }
    
    func getAnyQueuedDeviceData() -> [DeviceInfoModel] {
        var arrDeviceInfoModel = [DeviceInfoModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = DeviceData.fetchAnyQueuedEventRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrDeviceInfoModel.append(DeviceInfoModel.fromJson(deviceData: item.data!)!)
            }
            return arrDeviceInfoModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read device data list.", error: error)
            return arrDeviceInfoModel
        }
    }
    
    func removeDeviceDataFromDb(_ deviceId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing device data from db. id:" + deviceId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = DeviceData.fetchRemoveDeviceDataRequest(deviceId: deviceId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Device data removed from db. id: " + deviceId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove device data from db. Recreating DB")
            }
        }
    }
    
    func queueNewSessionDataToDb(_ newSession: NewSessionModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing new session data in db. " + newSession.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = NewSession(entity: NewSession.entity(), insertInto: viewContext)
            entity.data = newSession.toString()
            entity.id = newSession.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "New Session Data stored in db.")
        }
    }
    
    func getAnyQueuedNewSession() -> [NewSessionModel] {
        var arrNewSessionModel = [NewSessionModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = NewSession.fetchAnyQueuedNewSessionRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrNewSessionModel.append(NewSessionModel.fromJson(deviceData: item.data!)!)
            }
            return arrNewSessionModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read New Session list.", error: error)
            return arrNewSessionModel
        }
    }
    
    func removeNewSessionFromDb(_ newSessionId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing new session from db. id:" + newSessionId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = NewSession.fetchRemoveDeviceDataRequest(newSessionId: newSessionId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "New Session removed from db. id: " + newSessionId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove new session from db. Recreating DB")
            }
        }
    }
    
    func queueLoginDataToDb(_ loginInfo: LoginModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing login event in db. " + loginInfo.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = LoginInfo(entity: LoginInfo.entity(), insertInto: viewContext)
            entity.data = loginInfo.toString()
            entity.id = loginInfo.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "Login Data stored in db.")
        }
    }
    
    func getAnyQueuedLoginData() -> [LoginModel] {
        var arrLoginInfoModel = [LoginModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = LoginInfo.fetchAnyQueuedLoginRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrLoginInfoModel.append(LoginModel.fromJson(loginData: item.data!)!)
            }
            return arrLoginInfoModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read login data list.", error: error)
            return arrLoginInfoModel
        }
    }
    
    func removeLoginDataFromDb(_ loginId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing login data from db. id:" + loginId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = LoginInfo.fetchRemoveLoginRequest(loginId: loginId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Login data removed from db. id: " + loginId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove device data from db. Recreating DB")
            }
        }
    }
    
    func queueLogoutDataToDb(_ logoutInfo: LogoutModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing logout event in db." + logoutInfo.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = LogoutInfo(entity: LogoutInfo.entity(), insertInto: viewContext)
            entity.data = logoutInfo.toString()
            entity.id = logoutInfo.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "Logout Data stored in db.")
        }
    }
    
    func getAnyQueuedLogoutData() -> [LogoutModel] {
        var arrLogoutInfoModel = [LogoutModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = LogoutInfo.fetchAnyQueuedLogoutRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrLogoutInfoModel.append(LogoutModel.fromJson(logoutData: item.data!)!)
            }
            return arrLogoutInfoModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read logout data list.", error: error)
            return arrLogoutInfoModel
        }
    }
    
    func removeLogoutDataFromDb(_ logoutId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing logout data from db. id:" + logoutId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = LogoutInfo.fetchRemoveLogoutRequest(logoutId: logoutId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Logout data removed from db. id: " + logoutId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove logout data from db. Recreating DB")
            }
        }
    }
    
    func queueCustomerAttributesDataToDb(_ customerAttributesInfo: CustomerAttributesModel) {
        
        self.synchronized (self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Storing customer attributes in db. " + customerAttributesInfo.toString())
            
            //check for memory overflow
            if (!self.coreDataStack.belowMemThreshold()) {
                Logger.instance.warn(message: "There is not enough space left on the device to store data, data discarded")
                return
            }
            
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let entity = CustomerAttributes(entity: CustomerAttributes.entity(), insertInto: viewContext)
            entity.data = customerAttributesInfo.toString()
            entity.id = customerAttributesInfo.id
            entity.created_at = Date.currentTimeMillis
            // Save in Database
            self.coreDataStack.saveContext()
            Logger.instance.debug(suffix: "SqliteHelper", message: "Customer AttributesInfo Data stored in db.")
        }
    }
    
    func getAnyQueuedCustomerAttributeData() -> [CustomerAttributesModel] {
        var arrCustomerAttributesModel = [CustomerAttributesModel]()
        do {
            let viewContext = self.coreDataStack.persistentContainer.viewContext
            let fetchRequest = CustomerAttributes.fetchAnyQueuedCustomerAttributesRequest()
            let results = try viewContext.fetch(fetchRequest)
            
            
            for item in results {
                arrCustomerAttributesModel.append(CustomerAttributesModel.fromJson(customerAttributesData: item.data!)!)
            }
            return arrCustomerAttributesModel
        } catch let error {
            Logger.instance.info(suffix: "SqliteHelper", message: "Failed to read Customer Attributes data list.", error: error)
            return arrCustomerAttributesModel
        }
    }
    
    func removeCustomerAttributesDataFromDb(_ customerAttributesId :String ) {
        synchronized(self) {
            Logger.instance.debug(suffix: "SqliteHelper", message: "Removing customer Attributes data from db. id:" + customerAttributesId)
            do {
                let viewContext = self.coreDataStack.persistentContainer.viewContext
                let fetchRequest = CustomerAttributes.fetchRemoveCustomerAttributesRequest(customerAttributesId: customerAttributesId)
                let results = try viewContext.fetch(fetchRequest)
                for obj in results {
                    viewContext.delete(obj)
                }
                // Save Database
                self.coreDataStack.saveContext()
                Logger.instance.debug(suffix: "SqliteHelper", message: "Customer Attributes data removed from db. id: " + customerAttributesId)
            } catch {
                Logger.instance.error(suffix: "SqliteHelper", message: "Failed to remove Customer Attributes data from db. Recreating DB")
            }
        }
    }
    
}
