//
//  APNSMessagingService.swift
//  Growlytics
//
//  Created by Pradeep Singh on 25/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import UIKit

public class APNSMessagingService: NSObject{
    
    public static let shared = APNSMessagingService()
    
    public func setupAPNSMessagingWith(_ deviceToken: String){
        self.updateAPNSToken(token: deviceToken)
    }
    
    //MARK: *********************** Update APNS Token **********************
    private func updateAPNSToken(token : String) {
        
        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        
        Logger.instance.info(suffix: "APNS", message: "New Token event received. => " + token)
        AppLaunchedHandler.getInstance().updateAPNSToken(token)
    }
}
/*
extension APNSMessagingService: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        // 1
        let userInfo = response.notification.request.content.userInfo
        
        // 2
        if let aps = userInfo["aps"] as? [String: AnyObject]{
            debugPrint("aps:", aps)
        }
        
        completionHandler()
    }
    
    private func onMessageReceived(message : [String: AnyObject] ) {

        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }

        Logger.instance.debug(suffix: "GrwNotification", message: "New GrwNotification received.")

        // If Growlytics tag not found return.
        let notif  = GrwNotification(message)

        // If no data available, abort.
        if notif.getData().count == 0{
            return
        }

        if notif.isFromGrowlytics() && notif.isDoRender(){
            NotificationUtil.getInstance().renderNotification(notif)
            EventProcessor.getInstance().trackNotificationViewed(notif.getTrackingId())
        } else {
            Logger.instance.debug(suffix: "GrwNotification", message: "Notification Ignored. Not-Growlytics notification or do not render flag is present.")
        }
    }
}
*/
