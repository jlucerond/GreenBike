//
//  SaveController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/12/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

// do save stuff here

class SaveController {
   static let shared = SaveController()
   
   private func documentsDirectory() -> URL {
      let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
      return paths[0]
   }
   
   private func dataFilePath() -> URL {
      return documentsDirectory().appendingPathComponent("Alerts.plist")
   }

   func saveAlertsToDisk(_ alerts: [Alert]) {
      let encoder = PropertyListEncoder()
      do {
         let data = try encoder.encode(alerts)
         try data.write(to: dataFilePath(), options: .atomic)
      } catch  {
         print("Error: \(error.localizedDescription)")
      }
   }
   
   func loadAlertsFromDisk() -> [Alert] {
      do {
         let decoder = PropertyListDecoder()
         let url = dataFilePath()
         let data = try Data(contentsOf: url)
         let alerts = try decoder.decode([Alert].self, from: data)
         return alerts
      } catch  {
         print("Error: \(error.localizedDescription)")
      }
      
      return []
   }
   
   private init() {
      
   }
}


