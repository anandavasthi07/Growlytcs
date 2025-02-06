//
//  GrwNotification.swift
//  Growlytics
//
//  Created by Pradeep Singh on 26/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation
final class GrwNotification {

    private var fromGrowlytics          : Bool?
    private var doRender                : Bool?
    private var data                    : [String: AnyObject]?
    private var trackingId              : String?
    private var notifiaticationChannel  : String = ""
    private var priority                : String?
    private var actionButtons           : NSArray?
    private var ttl                     : String?
    private var title                   : String?
    private var message                 : String?
    private var imageUrl                : String?
    private var subTitle                : String?
    private var smallIconColor          : String?
    private var deepLink                : String?
    
    /*
    public GrwNotification(RemoteMessage message) {

        try {
//            JSONArray dd = new JSONArray();
//            try {
//                for (int i = 0; i < 3; i++) {
//                    JSONObject di = new JSONObject();
//
//                    di.put("l", "Button" + (i + 1));
//                    di.put("dl", "http://www.growlytics.com/ravi");
//                    di.put("ico", "");
//                    di.put("id", String.valueOf(i));
//                    di.put("ac", "");
//                    dd.put(di);
//
//                }
//            } catch (Throwable t) {
//
//            }
//
//            // Prepare dummy data
//            Bundle data = new Bundle();
//            data.putString("glytcs_pnf", "");
////        data.putString("glytcs_dnr", "");
//            data.putString("glytcs_tl", "My title");
//            data.putString("glytcs_msg", "My Message");
//            data.putString("glytcs_img", "https://images.unsplash.com/photo-1558981806-ec527fa84c39");
//            data.putString("glytcs_sbt", "Subtitle here");
//            data.putString("glytcs_pr", "high");
//            data.putString("channel", "ravi");
//            data.putString("glytcs_clr", "#5c32a8");
//            data.putString("glytcs_dl", "");
//            data.putString(Constants.NOTIFICATION_ACTION_BTNS, dd.toString());
//            self.data = data;
            Bundle data = new Bundle();
            for (Map.Entry<String, String> entry : message.getData().entrySet()) {
                data.putString(entry.getKey(), entry.getValue());
            }
            self.data = data;
            _init();
        } catch (Throwable t) {
            // Ignore
        }
    }

    GrwNotification(Bundle data) {
        self.data = data;
        _init();
    }
    */
     init( _ remoteInfo: [String: AnyObject]) {
        self.data = remoteInfo
        
            self.fromGrowlytics = remoteInfo.keys.contains("glytcs_pnf")
            self.doRender = !remoteInfo.keys.contains("doRender")
            

//            self.title = self.data.getString("glytcs_tl");
//            self.message = self.data.getString("glytcs_msg");
//            self.imageUrl = self.data.getString("glytcs_img");
//            self.subTitle = self.data.getString("glytcs_sbt");
//            self.priority = self.data.getString("glytcs_pr");
//            self.trackingId = self.data.getString("glytcs_id");
//
//            self.notifiaticationChannel = self.data.getString("glytcs_chnl");
//            self.smallIconColor = self.data.getString("glytcs_clr");
//            self.deepLink = self.data.getString("glytcs_dl");
//
//            String defaultTTL = (System.currentTimeMillis() + Constants.NOTIFICATION_DEFAULT_TTL) / 1000 + "";
//            self.ttl = self.getData().getString(Constants.NOTIFICATION_TTL, defaultTTL);
//
//            String buttons = self.data.getString(Constants.NOTIFICATION_ACTION_BTNS);
//            if (buttons != null && !buttons.trim().isEmpty()) {
//                try {
//                    self.actionButtons = new JSONArray(buttons);
//                } catch (Throwable t) {
//                    // Ignore
//                    Logger.error("Notification", "Failed to parse action buttons.", t);
//                }
//            }

    }

//    func isValidChannel(Context context, String channelName) -> Bool {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
//            NotificationManager notificationManager = (NotificationManager) context.getSystemService(NOTIFICATION_SERVICE);
//            if (notificationManager == nil)
//                return false
//            if (channelName.isEmpty()) {
//                return false
//            } else if (notificationManager.getNotificationChannel(channelName) == nil) {
//                return false
//            }
//            return true
//        } else {
//            return true
//        }
//    }


    func isFromGrowlytics() -> Bool {
        return fromGrowlytics!
    }

    func getTrackingId() -> String {
        return trackingId!
    }

    func getDeepLink() -> String {
        return deepLink!
    }

    func getTtl() -> String {
        return ttl!
    }

    func isDoRender() -> Bool {
        return doRender!
    }

    func getActionButtons() -> NSArray {
        return actionButtons!
    }

    func getSmallIconColor() -> String {
        return smallIconColor!
    }

    func getPriority() -> String {
        return priority!
    }

    func getData() -> [String: AnyObject] {
        return data!
    }

    func getNotifiaticationChannel() -> String {
        return self.notifiaticationChannel
    }

    func getTitle() -> String {
        return title!
    }

    func getSubTitle() -> String {
        return subTitle!
    }

    func getMessage() -> String {
        return message!
    }

    func getImageUrl() -> String {
        return imageUrl!
    }
}
