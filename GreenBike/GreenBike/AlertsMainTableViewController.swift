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
   var alerts: [Alert] = [] {
      didSet {
         // FIXME: - call save function from elsewhere
         SaveController.shared.saveAlertsToDisk(alerts)
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.alerts = SaveController.shared.loadAlertsFromDisk()
   }
   
   // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return alerts.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let alert = alerts[indexPath.row]
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as? AlertTableViewCell else { return UITableViewCell() }
      cell.alert = alert
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView,
                           commit editingStyle: UITableViewCellEditingStyle,
                           forRowAt indexPath: IndexPath) {
      
      if editingStyle == .delete {
         alerts.remove(at: indexPath.row)
         tableView.reloadData()
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
      self.alerts.append(alert)
      self.tableView.reloadData()
      dismiss(animated: true, completion: nil)
   }
   
   func didEditAlert(_ controller: AlertDetailTableViewController, alert: Alert) {
      for eachAlert in alerts {
         if alert == eachAlert {
            let index = alerts.index(of: eachAlert)!
            // found myself
            alerts[index] = alert
         }
      }
      tableView.reloadData()
      dismiss(animated: true, completion: nil)
   }
}