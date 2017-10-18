//
//  AlertsMainTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

class AlertsMainTableViewController: UITableViewController {
   // FIXME: - Change this when figuring out loading/persisting data
   var alerts: [Alert] = []
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.alerts = AlertController.shared.alerts
   }
   
   // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return alerts.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let alert = alerts[indexPath.row]
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as? AlertTableViewCell else { return UITableViewCell() }
      cell.alert = alert
      cell.delegate = self
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView,
                           commit editingStyle: UITableViewCellEditingStyle,
                           forRowAt indexPath: IndexPath) {
      
      if editingStyle == .delete {
         guard let cell = tableView.cellForRow(at: indexPath) as? AlertTableViewCell,
         let alert = cell.alert else { return }
         AlertController.shared.deleteAlert(alert: alert)
   //         cell.alert = nil
         updateAlerts()
      }
   }
}

// MARK: - Navigation
extension AlertsMainTableViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "newAlert" {
         
         guard let navVC = segue.destination as? UINavigationController,
            let alertDetailVC = navVC.topViewController as? AlertDetailTableViewController else { return }
         
         alertDetailVC.delegate = self
         alertDetailVC.title = "Add Alert"
      } else if segue.identifier == "editAlert" {
         guard let navVC = segue.destination as? UINavigationController,
            let alertDetailVC = navVC.topViewController as? AlertDetailTableViewController,
            let indexPath = tableView.indexPathForSelectedRow else { return }
         
         alertDetailVC.delegate = self
         alertDetailVC.title = "Edit Alert"
         alertDetailVC.alert = alerts[indexPath.row]
      }
   }
}

// MARK: - AlertDetailTableViewControllerDelegate Methods
extension AlertsMainTableViewController: AlertDetailTableViewControllerDelegate {
   func didCancel(_ controller: AlertDetailTableViewController) {
      dismiss(animated: true, completion: nil)
   }
   
   func didAddNewAlert(_ controller: AlertDetailTableViewController, alert: Alert) {
//      alerts.append(alert)
//      alert.scheduleAlert()
//      tableView.reloadData()
      updateAlerts()
      dismiss(animated: true, completion: nil)
   }
   
   func didEditAlert(_ controller: AlertDetailTableViewController, alert: Alert) {
//      updateAlert(alert)
//      tableView.reloadData()
      updateAlerts()
      dismiss(animated: true, completion: nil)
   }
}

// MARK: - AlertTableViewCellDelegate Methods
extension AlertsMainTableViewController: AlertTableViewCellDelegate {   
   func didToggleOnOffSwitch() {
      updateAlerts()
   }

}

// MARK: - Helper Methods
extension AlertsMainTableViewController {
   func updateAlerts() {
      alerts = AlertController.shared.alerts
      tableView.reloadData()
   }
}
