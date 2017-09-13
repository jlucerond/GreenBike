//
//  BikeStationController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation

class BikeStationController {
   static let shared = BikeStationController()
   var allBikeStations: [BikeStation] = [] {
      didSet {
         NotificationCenter.default.post(name: NotificationNotices.bikeStationsUpdatedNotification, object: nil)
      }
   }
   
   func refreshBikeStationsStatuses() {
      NetworkController.shared.getBikeInfoFromWeb { (success, arrayOfStations) in
         if !success {
            print("did not get bike statuses")
            //FIXME: - Error Handling Needed
            return
         }
         self.allBikeStations = arrayOfStations.flatMap{ BikeStation(dictionary: $0) }
      }
   }
   
   private init() {
      refreshBikeStationsStatuses()
   }
}
