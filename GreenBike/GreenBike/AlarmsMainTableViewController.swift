//
//  AlarmsMainTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

class AlarmsMainTableViewController: UITableViewController {
   // FIXME: - Change this when figuring out loading/persisting data
   var alarms: [Alarm] = []
   
   override func viewDidLoad() {
      super.viewDidLoad()
      useFakeData()
      tableView.reloadData()
   }
   
   // MARK: - Table view data source
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      // #warning Incomplete implementation, return the number of rows
      return alarms.count
   }
   
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "AlarmCell", for: indexPath)
    
    // Configure the cell...
    
    return cell
    }
   
}

// MARK: - Helper Methods
extension AlarmsMainTableViewController {
   func useFakeData() {
      let alarm1 = Alarm(isOn: true, timeOfDay: Date(), fromBikeStation: nil, toBikeStation: nil, weeklySchedule: AlarmWeek())
      let alarm2 = alarm1
      
      alarms = [alarm1, alarm2]
   }
}
