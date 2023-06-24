//
//  NotificationManager.swift
//  IA3V2
//
//  Created by James Nunn on 10/6/2023.
//

import Foundation
import UserNotifications

struct Notify {
    static func setup() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert,.sound,.badge]) { granted, error in
            if granted {
                setupNotificationCategories()
            }
        }
    }
    
    static func send(message:String, isImportant: Bool, delay:Double = 0) {
        let content = UNMutableNotificationContent()
        content.title = "PA Announcement"
        if isImportant{
            content.subtitle = "IMPORTANT"
        }
        content.body = message
        content.categoryIdentifier = "JobCategoryID"
        
        var trigger: UNNotificationTrigger?
        
        if delay > 0 {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: delay, repeats: false)
        }
        
        let request = UNNotificationRequest(identifier: "JobCategoryID", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        print("notif sent")
    }
    
    static func setupNotificationCategories() {
        
        let acceptAction = UNNotificationAction(identifier: "ACCEPT",
                                                title: "Thanks for the Heads up", options: [.foreground])
        
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION",
                                                 title: "Ignoring, don't care",
                                                 options: [.destructive])
        let newJobCategory =
        UNNotificationCategory(identifier: "JobCategoryID",
                               actions: [acceptAction, declineAction],
                               intentIdentifiers: [],
                               hiddenPreviewsBodyPlaceholder: "",
                               options: .customDismissAction)
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([newJobCategory])
    }
}
