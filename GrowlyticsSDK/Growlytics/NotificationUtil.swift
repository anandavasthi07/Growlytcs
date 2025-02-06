//
//  NotificationUtil.swift
//  Growlytics
//
//  Created by Pradeep Singh on 26/03/20.
//  Copyright © 2020 Growlytics Technologies Pvt Ltd. All rights reserved.
//

import Foundation

class NotificationUtil {
    
    // Singleton instance
    private static var instance     : NotificationUtil?
    
    // Async background processing variables
    let serialQueue = DispatchQueue.init(label: "NotificationUtil")
    
    private init() {}
    
    public static func getInstance() -> NotificationUtil{
        if (instance == nil) {
            instance = NotificationUtil()
        }
        return instance!
    }
    
    public func renderNotification(_ notif : GrwNotification) {
        
        if (Config.getInstance().isDisable()) {
            Logger.instance.info(message: "Growlytics is disabled from config.")
            return
        }
        
        self.serialQueue.async {
            self._renderNotification(notif)
        }
    }
    
    private func _renderNotification(_ notif: GrwNotification) {
        
        // If not Growlytics Notification, return
        
        if  !notif.isFromGrowlytics() {
            Logger.instance.error(suffix: "Notification", message: "Ignored notification, not a valid notification.")
            return
        }
        /*
         // Check if dnr is present
         if (!notif.isDoRender()) {
         Logger.info("Notification", "DNR set to true, Notification will not be rendered.");
         return;
         }
         
         // check if channel required
         boolean requiresChannelId = Build.VERSION.SDK_INT >= Build.VERSION_CODES.O;
         if (requiresChannelId) {
         if (notif.getNotifiaticationChannel() == null || notif.getNotifiaticationChannel().isEmpty()) {
         Logger.error("Notification", "Unable to render notification, channelId is required but not provided in the notification payload: " + notif.getData().toString());
         return;
         } else if (!notif.isValidChannel(context, notif.getNotifiaticationChannel())) {
         Logger.error("Notification", "Unable to render notification, channelId: " + notif.getNotifiaticationChannel() + " not registered by the app.");
         return;
         }
         }
         
         // Build Pending Intent
         Intent launchIntent = new Intent(context, GrwPushNotificationReceiver.class);
         launchIntent.putExtras(notif.getData());
         launchIntent.removeExtra(Constants.NOTIFICATION_ACTION_BTNS);
         launchIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
         PendingIntent pIntent = PendingIntent.getBroadcast(context, (int) System.currentTimeMillis(),
         launchIntent, PendingIntent.FLAG_UPDATE_CURRENT);
         
         // Build Notification
         NotificationCompat.Builder nb;
         int notificationId = (int) (Math.random() * 100);
         if (requiresChannelId) {
         
         // Initialize notification builder with channel id
         nb = new NotificationCompat.Builder(context, notif.getNotifiaticationChannel());
         
         //Set default badge icon for now.
         nb.setBadgeIconType(NotificationCompat.BADGE_ICON_LARGE);
         
         // Set subtitle if given
         if (notif.getSubTitle() != null) {
         nb.setSubText(notif.getSubTitle());
         }
         } else {
         // noinspection all
         nb = new NotificationCompat.Builder(context);
         }
         
         // Set small icon color if specified
         if (notif.getSmallIconColor() != null) {
         int color = Color.parseColor(notif.getSmallIconColor());
         nb.setColor(color);
         nb.setColorized(true);
         }
         
         // Set notification image if provided
         NotificationCompat.Style style = new NotificationCompat.BigTextStyle().bigText(notif.getMessage());
         if (notif.getImageUrl() != null && notif.getImageUrl().startsWith("http")) {
         try {
         
         Bitmap bpMap = CommonUtil.getBitmapFromURL(notif.getImageUrl(), 5 * 60);
         
         if (bpMap == null)
         throw new Exception("Failed to fetch big picture!");
         
         if (notif.getSubTitle() != null) {
         style = new NotificationCompat.BigPictureStyle()
         .setSummaryText(notif.getMessage())
         .bigPicture(bpMap);
         } else {
         style = new NotificationCompat.BigPictureStyle()
         .setSummaryText(notif.getMessage())
         .bigPicture(bpMap);
         }
         } catch (Throwable t) {
         Logger.error("GrwNotification", "Failed to set bigger picture, will render notification without big picture.", t);
         }
         }
         
         
         // Set small icon
         int smallIcon;
         try {
         String iconPath = Config.getInstance(context).getNotificationIcon();
         if (iconPath == null) throw new IllegalArgumentException();
         smallIcon = context.getResources().getIdentifier(iconPath, "drawable", context.getPackageName());
         if (smallIcon == 0) throw new IllegalArgumentException();
         } catch (Throwable t) {
         smallIcon = DeviceInfo.getAppIconAsIntId(context);
         }
         
         // Add action buttons if provided.
         if (notif.getActionButtons() != null) {
         try {
         
         boolean isGrwIntentServiceAvailable = _isServiceAvailable(context, GrwNotificationIntentService.class);
         
         for (int i = 0; i < notif.getActionButtons().length(); i++) {
         
         // Read button info
         JSONObject action = notif.getActionButtons().getJSONObject(i);
         String label = action.optString("label");
         String dl = action.optString("deeplinkUrl");
         String ico = action.optString("ico");
         String id = action.optString("id");
         
         //Todo: Allow cient to specify auto cancel
         boolean autoCancel = action.optBoolean("ac", true);
         
         // If label not proper, ignore button
         if (label.isEmpty() || id.isEmpty()) {
         Logger.debug("Notification", "not adding push notification action: action label or id missing");
         continue;
         }
         
         // If icon not proper, ignore button
         int icon = 0;
         if (!ico.isEmpty()) {
         try {
         icon = context.getResources().getIdentifier(ico, "drawable", context.getPackageName());
         } catch (Throwable t) {
         Logger.debug("Notification", "Unable to add notification action icon: " + t.getLocalizedMessage());
         }
         }
         
         boolean sendToGrwIntentService = (autoCancel && isGrwIntentServiceAvailable);
         
         Intent actionLaunchIntent;
         if (sendToGrwIntentService) {
         actionLaunchIntent = new Intent(GrwNotificationIntentService.MAIN_ACTION);
         actionLaunchIntent.setPackage(context.getPackageName());
         actionLaunchIntent.putExtra("grw_notif", GrwNotificationIntentService.TYPE_BUTTON_CLICK);
         if (!dl.isEmpty()) {
         actionLaunchIntent.putExtra("dl", dl);
         }
         } else {
         if (!dl.isEmpty()) {
         actionLaunchIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(dl));
         } else {
         actionLaunchIntent = context.getPackageManager().getLaunchIntentForPackage(context.getPackageName());
         }
         }
         
         if (actionLaunchIntent != null) {
         actionLaunchIntent.putExtras(notif.getData());
         actionLaunchIntent.removeExtra(Constants.NOTIFICATION_ACTION_BTNS);
         actionLaunchIntent.putExtra("actionId", id);
         actionLaunchIntent.putExtra("ac", autoCancel);
         actionLaunchIntent.putExtra("notificationId", notificationId);
         //                        actionLaunchIntent.putExtra("wzrk_c2a", id);
         
         actionLaunchIntent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP);
         }
         
         PendingIntent actionIntent;
         int requestCode = ((int) System.currentTimeMillis()) + i;
         // Todo: build intent service to receive action button callbacks info.
         if (sendToGrwIntentService) {
         actionIntent = PendingIntent.getService(context, requestCode,
         actionLaunchIntent, PendingIntent.FLAG_UPDATE_CURRENT);
         } else {
         actionIntent = PendingIntent.getActivity(context, requestCode,
         actionLaunchIntent, PendingIntent.FLAG_UPDATE_CURRENT);
         }
         nb.addAction(icon, label, actionIntent);
         
         }
         } catch (Throwable t) {
         Logger.debug("Notification", "error parsing notification actions: " + t.getLocalizedMessage());
         }
         }
         
         // Set notification priority
         int priorityInt = NotificationCompat.PRIORITY_DEFAULT;
         String priority = notif.getPriority();
         if (priority != null) {
         if (priority.equals(Constants.NOTIFICATION_PRIORITY_HIGH)) {
         priorityInt = NotificationCompat.PRIORITY_HIGH;
         }
         if (priority.equals(Constants.NOTIFICATION_PRIORITY_MAX)) {
         priorityInt = NotificationCompat.PRIORITY_MAX;
         }
         }
         
         
         // Set Large Notification Icon
         //Todo: Allow user to specify large icon from dashboard and specify here
         nb.setLargeIcon(CommonUtil.getNotificationBitmap("ico", true, context));
         
         nb.setContentTitle(notif.getTitle())
         .setContentText(notif.getMessage())
         .setContentIntent(pIntent)
         .setAutoCancel(true)
         .setStyle(style)
         .setPriority(priorityInt)
         .setSmallIcon(smallIcon);
         
         
         Notification n = nb.build();
         NotificationManager notificationManager = (NotificationManager) context.getSystemService(NOTIFICATION_SERVICE);
         notificationManager.notify(notificationId, n);
         Logger.info("Notification", "Rendered notification: " + n.toString());
         
         return;
         */
    }
}
