//
//  NotificationController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/15/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import UserNotifications

class NotificationController {
   static let shared = NotificationController()
   private let notificationCenter = UNUserNotificationCenter.current()
   
   enum UserInfoDictionary {
      static let numberOfBikesKey = "NumberOfBikes"
      enum numberOfBikesValues {
         static let zero = "Zero"
         static let some = "Some"
      }
      
      static let fromBikeStationNameKey = "FromBikeStation"
      static let toBikeStationNameKey = "ToBikeStation"
      
      static let alertToTurnOff = "AlertToTurnOff"
   }
   
   func requestAuthorizationForAlerts() {
      notificationCenter.requestAuthorization(options: [.alert, .sound, .badge]) { (success, error) in
         print("Allowed to send alerts to user: \(success)")
      }
   }
   
   
   /// Create a new local notification for an alert. When the user opens the notification, a new view controller will be presented that shows the status of the bike stations that are being alerted. If both the to and from station are nil, it will open the screen and show the table view controller.
   ///
   /// - Parameter alert: The alert that the user would like to create
   func createNotifications(for alert: Alert) {
      
      notificationCenter.getNotificationSettings { (settings) in
         guard settings.authorizationStatus == .authorized else {
            self.requestAuthorizationForAlerts()
            return
         }
         
         self.deleteNotifications(for: alert)
         
         var userInfoDictionary:[AnyHashable : Any] = [:]
         if alert.fromBikeStation == nil && alert.toBikeStation == nil {
            
            userInfoDictionary[NotificationController.UserInfoDictionary.numberOfBikesKey] = NotificationController.UserInfoDictionary.numberOfBikesValues.zero
            
         } else {
            userInfoDictionary[NotificationController.UserInfoDictionary.numberOfBikesKey] = NotificationController.UserInfoDictionary.numberOfBikesValues.some
            
            if let fromBikeStation = alert.fromBikeStation {
               userInfoDictionary[NotificationController.UserInfoDictionary.fromBikeStationNameKey] = fromBikeStation.name
            }
            if let toBikeStation = alert.toBikeStation {
               userInfoDictionary[NotificationController.UserInfoDictionary.toBikeStationNameKey] = toBikeStation.name
            }
            
         }
         
         if !alert.shouldRepeat {
            userInfoDictionary[NotificationController.UserInfoDictionary.alertToTurnOff] = alert.uuid.uuidString
         }
         
         
         let content = UNMutableNotificationContent()
         content.title = "💚🚲"
         content.sound = UNNotificationSound.default()
         content.userInfo = userInfoDictionary
         
         
         if alert.shouldRepeat {
            for day in alert.weeklySchedule.daysThatAlertShouldRepeat {
               
               let date = self.createDateForAlert(weekday: day.value, hour: alert.timeOfDay.hour, minute: alert.timeOfDay.minute)
               
               let dateComponents = Calendar(identifier: .gregorian).dateComponents([.weekday, .hour, .minute], from: date)
               
               let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
               
               let request = UNNotificationRequest(identifier: "\(alert.uuid)+\(day.value)", content: content, trigger: trigger)
               
               print("Should go off at: \(String(describing: trigger.nextTriggerDate()))")
               
               self.notificationCenter.add(request)
            }
            
         } else {
            
            let date = self.createDateForAlert(weekday: 1, hour: alert.timeOfDay.hour, minute: alert.timeOfDay.minute)
            
            let dateComponents = Calendar(identifier: .gregorian).dateComponents([.hour, .minute], from: date)
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let request = UNNotificationRequest(identifier: "\(alert.uuid)+0", content: content, trigger: trigger)
            
            print("Should go off at: \(String(describing: trigger.nextTriggerDate()))")
            
            self.notificationCenter.add(request)
         }
         
      }
      
   }
   
   func deleteNotifications(for alert: Alert) {
      for suffix in 0...7 {
         notificationCenter.removePendingNotificationRequests(withIdentifiers: ["\(alert.uuid)+\(suffix)"])
         print("Deleted alert: \(alert.uuid)+\(suffix)")
      }
      
      notificationCenter.getPendingNotificationRequests { (requests) in
         for request in requests {
            print("Requests still pending: \(request.identifier)")
         }
      }
   }
   
   private func createDateForAlert(weekday: Int, hour: Int, minute: Int) -> Date {
      var components = DateComponents()
      components.hour = hour
      components.minute = minute
      components.year = 2018
      components.weekday = weekday
      components.weekdayOrdinal = 1
      components.timeZone = .autoupdatingCurrent
      
      let calendar = Calendar(identifier: .gregorian)
      return calendar.date(from: components)!
   }
   
   private init() { }
   
}
