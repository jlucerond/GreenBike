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
            NotificationCenter.default.post(name: ConstantNotificationNotices.apiNotWorking, object: nil)
            return
         }
         self.allBikeStations = arrayOfStations.flatMap{ BikeStation(dictionary: $0) }
      }
   }
   
   func requestStatusOf(_ fromBikeStation: BikeStation?,
                        _ toBikeStation: BikeStation?,
                        completion: @escaping (_ success: Bool, _ fromBikeStation: BikeStation?, _ toBikeStation: BikeStation?) -> Void) {
      NetworkController.shared.getBikeInfoFromWeb { (success, arrayOfStations) in
         if !success {
            print("did not get bike info from Web")
            completion(false, nil, nil)
         } else {
            var returnFromBikeStation: BikeStation?
            var returnToBikeStation: BikeStation?
            
            let allBikeStations = arrayOfStations.flatMap{ BikeStation(dictionary: $0) }
            
            if let fromBikeStation = fromBikeStation {
               for station in allBikeStations {
                  if station == fromBikeStation { returnFromBikeStation = station }
               }
            }
            
            if let toBikeStation = toBikeStation {
               for station in allBikeStations {
                  if station == toBikeStation { returnToBikeStation = station  }
               }
            }
            
            // FIXME: - this might need to get called when the user pulls the app back up
            
            completion(true, returnToBikeStation, returnFromBikeStation)
            print("I just returned: \(returnFromBikeStation?.name) & \(returnToBikeStation?.name)")
         }
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
      NotificationCenter.default.post(name: ConstantNotificationNotices.locationUpdatedNotification, object: nil)
   }
}
