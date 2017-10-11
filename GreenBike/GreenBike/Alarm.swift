//
//  Alarm.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class Alarm {
   var isOn: Bool
   var timeOfDay: Date
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?
   var weeklySchedule: AlarmWeek
   var shouldRepeat: Bool {
      return !weeklySchedule.daysThatAlarmShouldRepeat.isEmpty
   }
   
   init(isOn: Bool,
        timeOfDay: Date,
        fromBikeStation: BikeStation?,
        toBikeStation: BikeStation?,
        weeklySchedule: AlarmWeek) {
      self.isOn = isOn
      self.timeOfDay = timeOfDay
      self.fromBikeStation = fromBikeStation
      self.toBikeStation = toBikeStation
      self.weeklySchedule = weeklySchedule
   }
}

class AlarmDay {
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

class AlarmWeek {
   let allDays: [AlarmDay]
   var daysThatAlarmShouldRepeat: [AlarmDay] {
      return allDays.filter{$0.isOn}
   }
   
   init() {
      let sunday = AlarmDay(name: "Sunday")
      let monday = AlarmDay(name: "Monday")
      let tuesday = AlarmDay(name: "Tuesday", isOn: true)
      let wednesday = AlarmDay(name: "Wednesday")
      let thursday = AlarmDay(name: "Thursday", isOn: true)
      let friday = AlarmDay(name: "Friday")
      let saturday = AlarmDay(name: "Saturday")
      
      allDays = [sunday, monday, tuesday, wednesday, thursday, friday, saturday]
   }
}
