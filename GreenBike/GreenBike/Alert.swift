//
//  Alert.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class Alert {
   private(set) var isOn: Bool
   var timeOfDay: Date
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?
   var weeklySchedule: AlertWeek
   private let uuid: UUID
   var shouldRepeat: Bool {
      return !weeklySchedule.daysThatAlertShouldRepeat.isEmpty
   }
   
   init(isOn: Bool,
        timeOfDay: Date,
        fromBikeStation: BikeStation?,
        toBikeStation: BikeStation?,
        weeklySchedule: AlertWeek) {
      self.isOn = isOn
      self.timeOfDay = timeOfDay
      self.fromBikeStation = fromBikeStation
      self.toBikeStation = toBikeStation
      self.weeklySchedule = weeklySchedule
      self.uuid = UUID()
   }
   
   func toggleOnOff() {
      isOn = !isOn
   }
   
   static func ==(lhs: Alert, rhs: Alert) -> Bool {
      return lhs.uuid == rhs.uuid
   }
}

class AlertDay {
   let name: String
   private(set) var isOn: Bool
   
   func toggle() {
      isOn = !isOn
   }
   
   init(name: String, isOn: Bool = false) {
      self.name = name
      self.isOn = isOn
   }
}

class AlertWeek {
   let allDays: [AlertDay]
   var daysThatAlertShouldRepeat: [AlertDay] {
      return allDays.filter{$0.isOn}
   }
   
   var stringOfDaysThatAlertShouldRepeat: String {
      var detailText = ""
      for day in daysThatAlertShouldRepeat {
         detailText.append("\(day.name.characters.first!), ")
      }
      
      if detailText.characters.count >= 2 {
         detailText.removeLast()
         detailText.removeLast()
      }
      
      return detailText
   }
   
   
   init() {
      let sunday = AlertDay(name: "Sunday")
      let monday = AlertDay(name: "Monday")
      let tuesday = AlertDay(name: "Tuesday")
      let wednesday = AlertDay(name: "Wednesday")
      let thursday = AlertDay(name: "Thursday")
      let friday = AlertDay(name: "Friday")
      let saturday = AlertDay(name: "Saturday")
      
      allDays = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
   }
}
