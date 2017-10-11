//
//  BikeStationController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation
import CoreLocation

class BikeStationController: NSObject {
   static let shared = BikeStationController()
   let locationManager = CLLocationManager()
   
   var allBikeStations: [BikeStation] = [] {
      didSet {
         NotificationCenter.default.post(name: ConstantNotificationNotices.bikeStationsUpdatedNotification, object: nil)
      }
   }
   
   var allBikeStationsSortedByDistance: [BikeStation]? {
      guard let userLocation = locationManager.location else { return nil }
      return BikeStationController.shared.allBikeStations.sorted(by: { (stationA, stationB) -> Bool in
         stationA.location.distance(from: userLocation) < stationB.location.distance(from: userLocation)
      })
   }
   
   func refreshBikeStationsStatuses() {
      NetworkController.shared.getBikeInfoFromWeb { (success, arrayOfStations) in
         if !success {
            print("did not get bike statuses")
            //FIXME: - Error Handling Needed
            NotificationCenter.default.post(name: ConstantNotificationNotices.apiNotWorking, object: nil)
            return
         }
         self.allBikeStations = arrayOfStations.flatMap{ BikeStation(dictionary: $0) }
      }
   }
   
   private override init() {
      super.init()
      refreshBikeStationsStatuses()
      locationManager.delegate = self
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
   }
}

extension BikeStationController: CLLocationManagerDelegate {
   
   func locationManager(_ manager: CLLocationManager,
                        didChangeAuthorization status: CLAuthorizationStatus) {
      if status == .authorizedAlways || status == .authorizedWhenInUse {
         BikeStationController.shared.locationManager.startUpdatingLocation()
      }
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      print("updated location")
      NotificationCenter.default.post(name: ConstantNotificationNotices.locationUpdatedNotification, object: nil)
   }
}
