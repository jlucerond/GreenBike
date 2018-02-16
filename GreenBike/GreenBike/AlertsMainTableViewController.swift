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
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      tableView.reloadData()
   }
   
   // MARK: - Table view data source
   override func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
      return AlertController.shared.alerts.count
   }
   
   override func tableView(_ tableView: UITableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let alert = AlertController.shared.alerts[indexPath.row]
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "AlertCell", for: indexPath) as? AlertTableViewCell else { return AlertTableViewCell() }
      cell.alert = alert
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView,
                           commit editingStyle: UITableViewCellEditingStyle,
                           forRowAt indexPath: IndexPath) {
      
      if editingStyle == .delete {
         let alert = AlertController.shared.alerts[indexPath.row]
         AlertController.shared.deleteAlert(alert: alert)
         
         guard let cell = tableView.cellForRow(at: indexPath) as? AlertTableViewCell else { return }
         cell.alert = nil
         
         tableView.deleteRows(at: [indexPath], with: .automatic)
      }
   }
}

// MARK: - Navigation
extension AlertsMainTableViewController {
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "editAlert" {
         guard let navVC = segue.destination as? UINavigationController,
            let alertDetailVC = navVC.topViewController as? AlertDetailTableViewController,
            let indexPath = tableView.indexPathForSelectedRow else { return }
         
         alertDetailVC.alert = AlertController.shared.alerts[indexPath.row]
      }
   }
}
