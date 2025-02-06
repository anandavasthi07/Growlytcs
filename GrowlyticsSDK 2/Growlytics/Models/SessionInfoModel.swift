//
//  SessionInfoModel.swift
//  Growlytics
//
//  Created by Pradeep Singh on 07/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class SessionInfoModel {
    
    private var sessionId           : String
    private var lastBackgroundTime  : Int
    private var createdAt           : Int
    
    init(_ sessionId: String, _ createdAt: Int, _ lastBackgroundTime: Int){
        self.sessionId = sessionId
        self.createdAt = createdAt
        self.lastBackgroundTime = lastBackgroundTime
    }
    
    func getSessionId() -> String {
        return self.sessionId
    }
    
    func getCreatedAt() -> Int {
        return self.createdAt
    }
    
    func getLastBackgroundTime() -> Int{
        return self.lastBackgroundTime
    }
    
    func setSessionId(sessionId : String) {
        self.sessionId = sessionId
    }
    
    func setCreatedAt(createdAt : Int) {
        self.createdAt = createdAt
    }
    
    func setLastBackgroundTime(_ lastBackgroundTime : Int) {
        self.lastBackgroundTime = lastBackgroundTime
    }
    
    public func toString() -> String{
        
        let dictionary = NSMutableDictionary()
        dictionary.setValue(self.sessionId, forKey: "sessionId")
        dictionary.setValue(self.createdAt, forKey: "createdAt")
        dictionary.setValue(self.lastBackgroundTime, forKey: "lastBackgroundTime")
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: dictionary, options: [])
            let jsonString = String(data: jsonData, encoding: .utf8)
            debugPrint("SessionInfoModel dictionary: ", jsonString as Any)
            return jsonString!
        } catch let error {
            Logger.instance.info(suffix: "SessionInfo-Stringify",
                                 message: "Failed to stringify SessionInfo.",
                                 error: error)
            // Ignore
            return ""
        }
    }
    
    static func fromJson(_ sessionInfoJson: String) -> SessionInfoModel? {
        do {
            let jsonData = sessionInfoJson.data(using: .utf8)
            let dictionary = try JSONSerialization.jsonObject(with: jsonData!, options: .mutableLeaves)
            debugPrint("SessionInfo sessionInfoJson: ", dictionary as Any)
            
            if let dict = dictionary as? [String: Any] {
                let sessionId = dict["sessionId"] as! String
                let createdAt = dict["createdAt"] as! Int
                let lastBackgroundTime = dict["lastBackgroundTime"] as! Int
                let sessionInfo = SessionInfoModel(sessionId,
                                                   createdAt,
                                                   lastBackgroundTime)
                return sessionInfo
            }
        } catch let error {
            Logger.instance.info(suffix: "SessionInfo Parse",
                                 message: "Failed to parse SessionInfo.",
                                 error: error)
            
        }
        return nil
    }
}

