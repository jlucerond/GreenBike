//
//  DaysTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

protocol DaysTableViewControllerDelegate: class {
   func didSelectDay(day: AlertDay)
}

class DaysTableViewController: UITableViewController {
   
   var weeklySchedule: AlertWeek!
   weak var delegate: DaysTableViewControllerDelegate?
   
   // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return weeklySchedule.allDays.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let dayOfWeek = weeklySchedule.allDays[indexPath.row]
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "dayCell", for: indexPath)
      cell.textLabel?.text = dayOfWeek.name
      cell.accessoryType = dayOfWeek.isOn ? .checkmark : .none
      return cell
   }
   
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      cellWasTapped(at: indexPath)
      tableView.deselectRow(at: indexPath, animated: true)
   }
   
}

// MARK: - Helper Methods
extension DaysTableViewController {
   func cellWasTapped(at indexPath: IndexPath){
      let dayTapped = weeklySchedule.allDays[indexPath.row]
      delegate?.didSelectDay(day: dayTapped)
      
      guard let cell = tableView.cellForRow(at: indexPath) else { return }
      cell.accessoryType = (cell.accessoryType == .none) ? .checkmark : .none
   }
}
