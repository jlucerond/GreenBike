//
//  AlertController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/18/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class AlertController {

   static let shared = AlertController()
   var alerts: [Alert] = []
   
   private init() {
      alerts = SaveController.shared.loadAlertsFromDisk()
   }
   
   func newAlert(isOn: Bool,
                 timeOfDay: Date,
                 fromBikeStation: BikeStation?,
                 toBikeStation: BikeStation?,
                 weeklySchedule: AlertWeek) {
      let alert = Alert(isOn: isOn,
                        timeOfDay: timeOfDay,
                        fromBikeStation: fromBikeStation,
                        toBikeStation: toBikeStation,
                        weeklySchedule: weeklySchedule)
      
      alerts.append(alert)
      alert.scheduleAlert()
      sortAlerts()
      SaveController.shared.saveAlertsToDisk(alerts)

   }
   
   func updateAlert(alert: Alert,
                    newIsOn: Bool?,
                    newTimeOfDay: Date?,
                    newFromBikeStation: BikeStation?,
                    newToBikeStation: BikeStation?,
                    newWeeklySchedule: AlertWeek?) {
      
      guard let index = alerts.index(of: alert) else { return }

      if let newIsOn = newIsOn {
         alert.isOn = newIsOn
      }
      
      if let newTimeOfDay = newTimeOfDay {
         alert.timeOfDay = newTimeOfDay
      }
      
      if let newFromBikeStation = newFromBikeStation {
         alert.fromBikeStation = newFromBikeStation
      }
      
      if let newToBikeStation = newToBikeStation {
         alert.toBikeStation = newToBikeStation
      }
      
      if let newWeeklySchedule = newWeeklySchedule {
         alert.weeklySchedule = newWeeklySchedule
      }
      
      alert.scheduleAlert()
      alerts[index] = alert
      sortAlerts()
      SaveController.shared.saveAlertsToDisk(alerts)
   }
   
   func toggleAlert(alert: Alert) {
      alert.isOn = !alert.isOn
      alert.scheduleAlert()
      
      SaveController.shared.saveAlertsToDisk(alerts)
   }
   
   func deleteAlert(alert: Alert) {
      guard let index = alerts.index(of: alert) else { return }
      alerts.remove(at: index)
      sortAlerts()
      SaveController.shared.saveAlertsToDisk(alerts)
   }
   
   private func sortAlerts() {
      alerts.sort { (alarm1, alarm2) -> Bool in
         return alarm1.timeOfDay < alarm2.timeOfDay
      }
   }
}
