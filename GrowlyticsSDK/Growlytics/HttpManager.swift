//
//  HttpManager.swift
//  Growlytics
//
//  Created by Pradeep Singh on 12/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

typealias CompletionHandler = (_ data: Any?, _ isTimeOutError: Bool) -> Void

class HttpManager{
    
    private static var instance : HttpManager?
    private var config          : Config
    private var deviceInfo      : DeviceInfo
    
    //MARK: ****************** Start: Singleton Class Methods ********************
    
    init() {
        self.config     = Config.getInstance()
        self.deviceInfo = DeviceInfo.getInstance()
    }
    
    static func getInstance() -> HttpManager {
        if (instance == nil) {
            //Singleton instance. Initializing Config.
            instance =  HttpManager()
        }
        return instance!
    }
    
    //MARK: ****************** End: Singleton Class Methods ******************
    
    //MARK: Gererate a POST Request
    func sendOverHttp(eventData : EventModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Start: Url: " + location + "Payload: " + eventData.toString())
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(eventData: eventData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "EVENT", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "EVENT", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "EVENT", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network",  message: "Response: Success. " + location)
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Response: 401 Response. Event ignored. Disabling plugin. " + location)
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "Response: An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry. " + location)
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "Response: An exception occurred while sending the queue, will retry. " + location, error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "Response: An exception occurred while sending the queue, will not retry. " + location, error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getJSONResponse(data: Data?) -> Any{
        let json = try? JSONSerialization.jsonObject(with: data ?? Data(), options: .allowFragments)
        return json as Any
    }
    
    
    private func getPath(eventType : EventType)-> String{
        // Decide url based on event type
        switch eventType {
        case .appLaunch:
            return "/mcrs_appl"
        case .identifyCustomer:
            return "/msv_cs_id"
        case .newToken:
            return "/apnsToken" //"/fcmToken"
        case .appInstalled:
            return "/mapp_installed"
        case .notificationClicked:
            return "/mnotif_click"
        case .notificationImpression:
            return "/mnotif_viewed"
        default:
            return "/msv_cevt"
        }
    }
    
    private func getBody(eventData: EventModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(eventData.id, forKey: "id")
        data.setValue(eventData.sid, forKey: "sid")
        data.setValue(eventData.event, forKey: "event")
        data.setValue(eventData.session, forKey: "session")
        data.setValue(eventData.meta, forKey: "meta")
        data.setValue(eventData.device, forKey: "device")
        data.setValue(eventData.timestamp, forKey: "timestamp")
        data.setValue(eventData.eventTimestamp, forKey: "eventTimestamp")
        
        return data
    }
    
    //For device registration data
    func sendOverHttp(deviceData : DeviceInfoModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        Logger.instance.info(suffix: "Network", message: "Start: Send device data to network:" + deviceData.toString())
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Url: " + location)
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(deviceData: deviceData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "DEVICE_REGISTER", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "DEVICE_REGISTER", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "DEVICE_REGISTER", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network", message: "Network success response")
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Un-authorized response. Event ignored. Disabling plugin.")
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry.")
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will retry.", error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will not retry.", error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getBody(deviceData: DeviceInfoModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(deviceData.id, forKey: "id")
        data.setValue(deviceData.device, forKey: "device")
        data.setValue(deviceData.meta, forKey: "meta")
        data.setValue(deviceData.timestamp, forKey: "timestamp")
        data.setValue(deviceData.eventTimestamp, forKey: "eventTimestamp")
        return data
    }
    
    func sendOverHttp(newSessionData : NewSessionModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        Logger.instance.info(suffix: "Network", message: "Start: New Session data to network:" + newSessionData.toString())
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Url: " + location)
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(newSessionData: newSessionData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "NEW_SESSION", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "NEW_SESSION", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "NEW_SESSION", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network", message: "Network success response")
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Un-authorized response. Event ignored. Disabling plugin.")
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry.")
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will retry.", error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will not retry.", error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getBody(newSessionData: NewSessionModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(newSessionData.id, forKey: "id")
        data.setValue(newSessionData.sid, forKey: "sid")
        data.setValue(newSessionData.data, forKey: "data")
        data.setValue(newSessionData.session, forKey: "session")
        data.setValue(newSessionData.meta, forKey: "meta")
        data.setValue(newSessionData.device, forKey: "device")
        data.setValue(newSessionData.timestamp, forKey: "timestamp")
        data.setValue(newSessionData.eventTimestamp, forKey: "eventTimestamp")
        return data
    }
    
    func sendOverHttp(newLoginData : LoginModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        Logger.instance.info(suffix: "Network", message: "Start: Login data to network:" + newLoginData.toString())
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Url: " + location)
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(newLoginData: newLoginData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "LOGIN", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "LOGIN", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "LOGIN", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network", message: "Network success response")
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Un-authorized response. Event ignored. Disabling plugin.")
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry.")
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will retry.", error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will not retry.", error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getBody(newLoginData: LoginModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(newLoginData.id, forKey: "id")
        data.setValue(newLoginData.user, forKey: "user")
        data.setValue(newLoginData.session, forKey: "session")
        data.setValue(newLoginData.meta, forKey: "meta")
        data.setValue(newLoginData.device, forKey: "device")
        data.setValue(newLoginData.timestamp, forKey: "timestamp")
        data.setValue(newLoginData.eventTimestamp, forKey: "eventTimestamp")
        return data
    }
    
    func sendOverHttp(logoutData : LogoutModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        Logger.instance.info(suffix: "Network", message: "Start: Logout data to network:" + logoutData.toString())
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Url: " + location)
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(logoutData: logoutData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "LOGOUT", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "LOGOUT", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "LOGOUT", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network", message: "Network success response")
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Un-authorized response. Event ignored. Disabling plugin.")
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry.")
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will retry.", error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will not retry.", error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getBody(logoutData: LogoutModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(logoutData.id, forKey: "id")
        data.setValue(logoutData.sid, forKey: "sid")
        data.setValue(logoutData.session, forKey: "session")
        data.setValue(logoutData.meta, forKey: "meta")
        data.setValue(logoutData.device, forKey: "device")
        data.setValue(logoutData.timestamp, forKey: "timestamp")
        data.setValue(logoutData.eventTimestamp, forKey: "eventTimestamp")
        return data
    }
    
    func sendOverHttp(customerData : CustomerAttributesModel, endPoints: String, completionHandler: @escaping CompletionHandler){
        Logger.instance.info(suffix: "Network", message: "Start: Customer attributes data to network:" + customerData.toString())
        
        // Prepare Connection
        let location = self.config.getHost() + endPoints
        Logger.instance.debug(suffix: "Network", message: "Url: " + location)
        
        guard let URL = URL(string: location) else {
            let error = "Error: cannot create URL"
            debugPrint(error)
            return
        }
        
        var request = URLRequest(url: URL)
        request.timeoutInterval = 120
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue(self.config.getApiKey(), forHTTPHeaderField: "x-growlytics-key")
        request.addValue(self.config.getEnvironment(), forHTTPHeaderField: "glytics_env")
        
        let bodyParams = self.getBody(customerData: customerData)
        Logger.instance.debug(suffix: "Network", message: "Request: URL:" + location + " | Body: " + bodyParams.toString())
        
        do {
            let data = try JSONSerialization.data(withJSONObject: bodyParams, options: [])
            request.httpBody = data
        } catch {
            let error = "Error: cannot create Data from \(bodyParams)"
            debugPrint(error)
            return
        }
        
        // Setup the session
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { (data, response, error) -> Void in
            
            let json = self.getJSONResponse(data: data)
            
            Logger.instance.debug(suffix: "CUSTOMER_ATTRIBUTES", message: "Response: " + "\(response as Any)")
            Logger.instance.debug(suffix: "CUSTOMER_ATTRIBUTES", message: "Json: " + "\(json as Any)")
            Logger.instance.debug(suffix: "CUSTOMER_ATTRIBUTES", message: "Error: " + "\(error as Any)")
            
            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200{
                    Logger.instance.info(suffix: "Network", message: "Network success response")
                    completionHandler(json, false)
                }
                else if httpResponse.statusCode == 401{
                    // Disable plugin, and ignore all the current events.
                    self.config.setDisabled(true)
                    Logger.instance.info(suffix: "Network", message: "Un-authorized response. Event ignored. Disabling plugin.")
                    completionHandler(nil, false)
                }
                else {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue with Code \(httpResponse.statusCode), will not retry.")
                    completionHandler(json, false)
                }
            } else if let error = error as NSError?{
                if error.code == NSURLErrorTimedOut {
                    Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will retry.", error: error)
                    completionHandler(nil, true)
                }
            }else {
                Logger.instance.error(suffix: "Network", message: "An exception occurred while sending the queue, will not retry.", error: error)
                completionHandler(json, false)
            }
        }
        task.resume()
    }
    
    private func getBody(customerData: CustomerAttributesModel) -> NSDictionary{
        // Build request body
        let data = NSMutableDictionary()
        data.setValue(customerData.id, forKey: "id")
        data.setValue(customerData.sid, forKey: "sid")
        data.setValue(customerData.data, forKey: "data")
        data.setValue(customerData.session, forKey: "session")
        data.setValue(customerData.meta, forKey: "meta")
        data.setValue(customerData.device, forKey: "device")
        data.setValue(customerData.timestamp, forKey: "timestamp")
        data.setValue(customerData.eventTimestamp, forKey: "eventTimestamp")
        return data
    }
    
}
