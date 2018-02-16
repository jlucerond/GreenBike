//
//  Alert.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

fileprivate enum KeysForSaving {
   static let alertDictionaryKey = "alertDictionaryKey"
   static let isOn = "isOn"
   static let timeOfDay = "timeOfDay"
   static let fromBikeStation = "fromBikeStation"
   static let toBikeStation = "toBikeStation"
   static let weeklySchedule = "weeklySchedule"
   static let uuid = "uuid"
}

class Alert: NSObject, Codable {
   var isOn: Bool
   var timeOfDay: AlertTime
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?
   var weeklySchedule: AlertWeek
   let uuid: UUID
   var shouldRepeat: Bool {
      return !weeklySchedule.daysThatAlertShouldRepeat.isEmpty
   }
   override var description: String {
      return "Alert from: \(fromBikeStation?.name ?? "no from station")\nto: \(toBikeStation?.name ?? "no to station")\non\(weeklySchedule.stringOfDaysThatAlertShouldRepeat)"
   }
   
   init(isOn: Bool,
        timeOfDay: AlertTime,
        fromBikeStation: BikeStation?,
        toBikeStation: BikeStation?,
        weeklySchedule: AlertWeek) {
      self.isOn = isOn
      self.timeOfDay = timeOfDay
      self.fromBikeStation = fromBikeStation
      self.toBikeStation = toBikeStation
      self.weeklySchedule = weeklySchedule
      self.uuid = UUID()
      
      super.init()
   }
   
   deinit {
      NotificationController.shared.deleteNotifications(for: self)
      print("Deinit: \(uuid)")
   }
   
   func scheduleAlert() {
      if isOn {
         NotificationController.shared.createNotifications(for: self)
      } else {
         NotificationController.shared.deleteNotifications(for: self)
      }
   }
   
   static func ==(lhs: Alert, rhs: Alert) -> Bool {
      return lhs.uuid == rhs.uuid
   }
   
   
}

class AlertTime: NSObject, Codable, Comparable {
   let hour: Int
   let minute: Int
   
   init(hour: Int, minute: Int) {
      self.hour = hour
      self.minute = minute
   }
   
   static func ==(lhs: AlertTime, rhs: AlertTime) -> Bool {
      return lhs.hour == rhs.hour && lhs.minute == rhs.minute
   }
   
   static func <(lhs: AlertTime, rhs: AlertTime) -> Bool {
      if lhs.hour != rhs.hour {
         return lhs.hour < rhs.hour
      } else {
         return lhs.minute < rhs.minute
      }
   }
}

class AlertDay: NSObject, Codable {
   let name: String
   let value: Int
   private(set) var isOn: Bool
   
   func toggle() {
      isOn = !isOn
   }
   
   init(name: String, value: Int) {
      self.name = name
      self.value = value
      self.isOn = false
   }
}

class AlertWeek: NSObject, Codable {
   let allDays: [AlertDay]
   var daysThatAlertShouldRepeat: [AlertDay] {
      return allDays.filter{$0.isOn}
   }
   
   var stringOfDaysThatAlertShouldRepeat: String {
      var detailText = ""
      for day in daysThatAlertShouldRepeat {
         detailText.append("\(day.name.first!), ")
      }
      
      if detailText.count >= 2 {
         detailText.removeLast()
         detailText.removeLast()
      }
      
      return detailText
   }
   
   
   override init() {
      let sunday = AlertDay(name: "Sunday", value: 1)
      let monday = AlertDay(name: "Monday", value: 2)
      let tuesday = AlertDay(name: "Tuesday", value: 3)
      let wednesday = AlertDay(name: "Wednesday", value: 4)
      let thursday = AlertDay(name: "Thursday", value: 5)
      let friday = AlertDay(name: "Friday", value: 6)
      let saturday = AlertDay(name: "Saturday", value: 7)
      
      allDays = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
   }
}
