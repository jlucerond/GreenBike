//
//  NotificationController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/15/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications

class NotificationController {
   static let shared = NotificationController()
   private let notificationCenter = UNUserNotificationCenter.current()
   
   func createNotification(for alert: Alert) {
      notificationCenter.getNotificationSettings { (settings) in
         if settings.authorizationStatus == .authorized {            
            let content = UNMutableNotificationContent()
            content.title = "Title"
            content.body = "Body"
            content.sound = UNNotificationSound.default()
            
            // FIXME: - chnage time interval to something else
            let calendar = Calendar(identifier: .gregorian)
            let dateComponents = calendar.dateComponents([.hour, .minute], from: alert.timeOfDay)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(alert.uuid)", content: content, trigger: trigger)
            
            self.notificationCenter.add(request)
            print("Scheduled: \(alert.uuid.description)")
            
         } else {
            print("not registered for notifications")
         }
      }
      
   }
   
   func deleteNotification(for alert: Alert) {
      notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(alert.uuid)"])
      print("Deleted alert: \(alert.uuid.description)")
   }
   
   private init() {
   }
}
