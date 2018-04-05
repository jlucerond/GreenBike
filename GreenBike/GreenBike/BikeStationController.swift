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
   var isDownloadingBikeStationInfo = false
   
   var allBikeStations: [BikeStation] = [] {
      didSet {
         NotificationCenter.default.post(name: ConstantNotificationNotices.bikeStationsUpdatedNotification, object: nil)
      }
   }
   
   /// Does not contain the most recent info on bike stations, but sorts allBikeStations by user location. If needed, call 'refreshBikeStationsStatuses' and listen for 'ConstantNotificationNotices.bikeStationsUpdatedNotification' to get the most current info on bike stations locations. Will return nil if location services are not enabled
   var allBikeStationsSortedByDistance: [BikeStation]? {
      guard let userLocation = locationManager.location else { return nil }
      return BikeStationController.shared.allBikeStations.sorted(by: { (stationA, stationB) -> Bool in
         stationA.location.distance(from: userLocation) < stationB.location.distance(from: userLocation)
      })
   }
   
   /// Will update the user's location and then send a network call out for the status of all bike stations. Once finished, this will either result in call to NotificationCenter of .apiNotWorking or .bikeStationsUpdatedNotification
   func refreshBikeStationsStatuses() {
      locationManager.requestLocation()
      if !isDownloadingBikeStationInfo {
         isDownloadingBikeStationInfo = true
         NetworkController.shared.getBikeInfoFromWeb { (success, arrayOfStations) in
            if !success {
               print("I am not getting the bike info from the web")
               NotificationCenter.default.post(name: ConstantNotificationNotices.apiNotWorking, object: nil)
               self.isDownloadingBikeStationInfo = false
               
               return
            }
            
            print("I got bike info from web")
            self.allBikeStations = arrayOfStations.compactMap{ BikeStation(dictionary: $0) }
            self.isDownloadingBikeStationInfo = false
         }
      }
   }
   
   private override init() {
      super.init()
      locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
      locationManager.distanceFilter = 161
      locationManager.delegate = self
      refreshBikeStationsStatuses()
   }
}

extension BikeStationController: CLLocationManagerDelegate {
   
   func locationManager(_ manager: CLLocationManager,
                        didChangeAuthorization status: CLAuthorizationStatus) {
      if (status == .authorizedAlways || status == .authorizedWhenInUse) {
         locationManager.startUpdatingLocation()
      }
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      refreshBikeStationsStatuses()
   }
   
   func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
      
      if let error = error as NSError? {
         print("Error getting location. Domain: \(error.domain). Code: \(error.code)")
      }
      print("location manager did fail")
   }
}
