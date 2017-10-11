//
//  AlarmDetailTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/10/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

class AlarmDetailTableViewController: UITableViewController {
   
   @IBOutlet weak var timePicker: UIDatePicker!
   
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?
   var weeklySchedule = AlarmWeek()
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      setUpViews()
   }
   
   @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
      
      dismiss(animated: true, completion: nil)
   }
   @IBAction func cancelButtonPressed(_ sender: UIBarButtonItem) {
      dismiss(animated: true, completion: nil)
   }
   
}

// MARK: - Navigation
extension AlarmDetailTableViewController {
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
extension AlarmDetailTableViewController: BikeStationPickerTableViewControllerDelegate {
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
extension AlarmDetailTableViewController: DaysTableViewControllerDelegate {
   func didSelectDay(day: AlarmDay) {
      for eachDay in weeklySchedule.allDays {
         if eachDay.name == day.name {
            eachDay.toggle()
            tableView.reloadData()
         }
      }
   }
}

// MARK: - Helper Methods
extension AlarmDetailTableViewController {
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
      
      var detailText = ""
      for day in weeklySchedule.daysThatAlarmShouldRepeat {
         detailText.append("\(day.name.characters.first!), ")
      }
      
      if detailText.characters.count >= 2 {
         detailText.removeLast()
         detailText.removeLast()
      }
      
      repeatCell.detailTextLabel?.text = detailText
   }
}
