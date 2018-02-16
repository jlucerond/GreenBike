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
   
   func createNewAlert(timeFrom date: Date,
                       fromBikeStation: BikeStation?,
                       toBikeStation: BikeStation?,
                       weeklySchedule: AlertWeek) {
      
      let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date)
      let timeOfDay = AlertTime(hour: dateComponents.hour!, minute: dateComponents.minute!)
      
      let alert = Alert(isOn: true,
                        timeOfDay: timeOfDay,
                        fromBikeStation: fromBikeStation,
                        toBikeStation: toBikeStation,
                        weeklySchedule: weeklySchedule)
      
      alerts.append(alert)
      alert.scheduleAlert()
      sortThenSaveAlerts()
   }
   
   func updateAlert(alert: Alert,
                    newIsOn: Bool,
                    newTimeFrom date: Date,
                    newFromBikeStation: BikeStation?,
                    newToBikeStation: BikeStation?,
                    newWeeklySchedule: AlertWeek) {
      
      let dateComponents = Calendar.autoupdatingCurrent.dateComponents([.hour, .minute], from: date)
      let newTimeOfDay = AlertTime(hour: dateComponents.hour!, minute: dateComponents.minute!)

      alert.isOn = newIsOn
      alert.timeOfDay = newTimeOfDay
      alert.fromBikeStation = newFromBikeStation
      alert.toBikeStation = newToBikeStation
      alert.weeklySchedule = newWeeklySchedule
      
      alert.scheduleAlert()
      sortThenSaveAlerts()
   }
   
   func toggleAlert(alert: Alert) {
      alert.isOn = !alert.isOn
      alert.scheduleAlert()
      sortThenSaveAlerts()
   }
   
   func deleteAlert(alert: Alert) {
      alert.isOn = false
      alert.scheduleAlert()
      guard let index = alerts.index(of: alert) else { return }
      alerts.remove(at: index)
   }
   
   private func sortThenSaveAlerts() {
      alerts.sort { (alert1, alert2) -> Bool in
         return alert1.timeOfDay < alert2.timeOfDay
      }
      SaveController.shared.saveAlertsToDisk(alerts)
   }
}
