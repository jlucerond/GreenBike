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
            
            // FIXME: - I think this might just be getting the current status of the bikes and not at the desired time
            print("\(alert.toBikeStation)")
            print("\(alert.fromBikeStation)")
            
            BikeStationController.shared.requestStatusOf(alert.toBikeStation, alert.fromBikeStation, completion: { (success, station1, station2) in
               
               let content = UNMutableNotificationContent()
               content.title = "\(station1?.name)"
               content.subtitle = "\(station2?.name)"
               content.body = "Body"
               content.sound = UNNotificationSound.default()
               
               // FIXME: - right now does not repeat alerts
               // FIXME: - right now does not turn off after alert goes off
               let calendar = Calendar.autoupdatingCurrent
               let dateComponents = calendar.dateComponents([.hour, .minute], from: alert.timeOfDay)
               dateComponents.day
               
               // FIXME: - create up to 7 alerts that include .weekday, .hour, .minute and have it repeat?
               
               let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: alert.shouldRepeat)
               
               let request = UNNotificationRequest(identifier: "\(alert.uuid)", content: content, trigger: trigger)
               
               self.notificationCenter.add(request)
               print("Scheduled: \(alert.uuid)")
            })
            
            
         } else {
            print("not registered for notifications")
         }
      }
      
   }
   
   func deleteNotification(for alert: Alert) {
      notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(alert.uuid)"])
      print("Deleted alert: \(alert.uuid)")

      notificationCenter.getPendingNotificationRequests { (requests) in
         for request in requests {
            print("old request: \(request.identifier)")
         }
      }
   }
   
   private init() {
   }
}
