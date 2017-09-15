//
//  BikeStation.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation
import CoreLocation
import MapKit

class BikeStation: NSObject {
   private let nameKey = "name"
   private let latitudeKey = "latitude"
   private let longitudeKey = "longitude"
   private let emptySlotsKey = "empty_slots"
   private let freeBikesKey = "free_bikes"
   private let extraKey = "extra"
   private let addressKey = "address"
   private let rentingKey = "renting"
   private let returningKey = "returning"
   
   let name: String
   let latitude: Double
   let longitude: Double
   let emptySlots: Int
   let freeBikes: Int
   let address: String
   let renting: Bool
   let returning: Bool
   
   init?(dictionary: [String:Any]) {
      guard let name = dictionary[nameKey] as? String,
         let latitude = dictionary[latitudeKey] as? Double,
         let longitude = dictionary[longitudeKey] as? Double,
         let emptySlots = dictionary[emptySlotsKey] as? Int,
         let freeBikes = dictionary[freeBikesKey] as? Int,
         let extra = dictionary[extraKey] as? [String : Any],
         let address = extra[addressKey] as? String,
         let renting = extra[rentingKey] as? Bool,
         let returning = extra[returningKey] as? Bool else { return nil }
      
      self.name = name.replacingOccurrences(of: "@", with: "\n@")
      self.latitude = latitude
      self.longitude = longitude
      self.emptySlots = emptySlots
      self.freeBikes = freeBikes
      self.address = address
      self.renting = renting
      self.returning = returning
   }
   
}

extension BikeStation: MKAnnotation {
   var coordinate: CLLocationCoordinate2D {
      return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
   }
   
   var location: CLLocation {
      return CLLocation(latitude: latitude, longitude: longitude)
   }
   
   var title: String? {
      return name
   }
   
   var subtitle: String? {
      return "\(freeBikes) out of \(freeBikes + emptySlots) available"
   }
}
