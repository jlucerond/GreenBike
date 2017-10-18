//
//  AlertDetailTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/10/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

protocol AlertDetailTableViewControllerDelegate: class {
   func didCancel(_ controller: AlertDetailTableViewController)
   func didAddNewAlert(_ controller: AlertDetailTableViewController, alert: Alert)
   func didEditAlert(_ controller: AlertDetailTableViewController, alert: Alert)
}

class AlertDetailTableViewController: UITableViewController {
   
   @IBOutlet weak var timePicker: UIDatePicker!
   
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?
   var weeklySchedule = AlertWeek()
   
   var alert: Alert?
   weak var delegate: AlertDetailTableViewControllerDelegate?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      if let alert = alert {
         self.timePicker.date = alert.timeOfDay
         self.fromBikeStation = alert.fromBikeStation
         self.toBikeStation = alert.toBikeStation
         self.weeklySchedule = alert.weeklySchedule
         setUpLabels()
      }
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setUpViews()
   }
   
   @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
      if let alert = alert {
         // edit alert
         AlertController.shared.updateAlert(alert: alert,
                                            newIsOn: alert.isOn
                                            newTimeOfDay: timePicker.date,
                                            newFromBikeStation: fromBikeStation,
                                            newToBikeStation: toBikeStation,
                                            newWeeklySchedule: weeklySchedule)
//         alert.timeOfDay = timePicker.date
//         alert.fromBikeStation = fromBikeStation
//         alert.toBikeStation = toBikeStation
//         alert.weeklySchedule = weeklySchedule
//         delegate?.didEditAlert(self, alert: alert)
      } else {
         // add new alert
         AlertController.shared.newAlert(isOn: true,
                                         timeOfDay: timePicker.date,
                                         fromBikeStation: fromBikeStation,
                                         toBikeStation: toBikeStation,
                                         weeklySchedule: weeklySchedule)
//         let alert = Alert(isOn: true,
//                           timeOfDay: timePicker.date,
//                           fromBikeStation: fromBikeStation,
//                           toBikeStation: toBikeStation,
//                           weeklySchedule: weeklySchedule)
//         delegate?.didAddNewAlert(self, alert: alert)
      }
      
   }
   
   @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
      delegate?.didCancel(self)
   }
   
}

// MARK: - Navigation
extension AlertDetailTableViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "fromSegue" {
         guard let pickerVC = segue.destination as? BikeStationPickerTableViewController else { return }
         
         pickerVC.delegate = self
         pickerVC.toOrFrom = ToOrFrom.from
         pickerVC.title = "From Station"
         
      } else if segue.identifier == "toSegue" {
         guard let pickerVC = segue.destination as? BikeStationPickerTableViewController else { return }
         
         pickerVC.delegate = self
         pickerVC.toOrFrom = ToOrFrom.to
         pickerVC.title = "To Station"
         
      } else if segue.identifier == "repeatSegue" {
         guard let daysVC = segue.destination as? DaysTableViewController else { return }
         daysVC.delegate = self
         daysVC.weeklySchedule = self.weeklySchedule
      }
   }
}

// MARK: - BikeStationPickerTableViewControllerDelegate Method
extension AlertDetailTableViewController: BikeStationPickerTableViewControllerDelegate {
   func didSelectBikeStation(_ controller: BikeStationPickerTableViewController,
                             bikeStation: BikeStation,
                             toOrFrom: ToOrFrom) {
      if toOrFrom == ToOrFrom.from {
         self.fromBikeStation = bikeStation
         let indexPathForFromCell = IndexPath(row: 1, section: 0)
         tableView.cellForRow(at: indexPathForFromCell)?.detailTextLabel?.text = bikeStation.name
         navigationController?.popViewController(animated: true)
      } else if toOrFrom == ToOrFrom.to {
         self.toBikeStation = bikeStation
         let indexPathForToCell = IndexPath(row: 2, section: 0)
         tableView.cellForRow(at: indexPathForToCell)?.detailTextLabel?.text = bikeStation.name
         navigationController?.popViewController(animated: true)
      }
   }
}

// MARK: - DaysTableViewControllerDelegate Method
extension AlertDetailTableViewController: DaysTableViewControllerDelegate {
   func didSelectDay(day: AlertDay) {
      for eachDay in weeklySchedule.allDays {
         if eachDay.name == day.name {
            eachDay.toggle()
            tableView.reloadData()
         }
      }
   }
}

// MARK: - Helper Methods
extension AlertDetailTableViewController {
   func setUpViews() {
      timePicker.setValue(UIColor.secondaryAppColor, forKey: "textColor")
      setUpLabels()
   }
   
   func setUpLabels() {
      guard let fromCell = tableView.cellForRow(at: IndexPath(row: 1, section: 0)),
         let toCell = tableView.cellForRow(at: IndexPath(row: 2, section: 0)),
         let repeatCell = tableView.cellForRow(at: IndexPath(row: 3, section: 0)) else { return }
      fromCell.detailTextLabel?.text = fromBikeStation?.name ?? ""
      toCell.detailTextLabel?.text = toBikeStation?.name ?? ""
      repeatCell.detailTextLabel?.text = weeklySchedule.stringOfDaysThatAlertShouldRepeat
   }
}
