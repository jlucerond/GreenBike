//
//  BikeStationTableViewCell.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/13/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import CoreLocation

class BikeStationTableViewCell: UITableViewCell {

   @IBOutlet weak var nameLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var numberOfBikesLabel: UILabel!
   @IBOutlet weak var numberOfDocksLabel: UILabel!
   @IBOutlet weak var distanceFromUserLabel: UILabel!
   @IBOutlet weak var widthOfBikeBar: NSLayoutConstraint!
   @IBOutlet weak var widthOfDistanceBar: NSLayoutConstraint!
   
   var bikeStation: BikeStation? {
      didSet {
         guard let bikeStation = bikeStation else { return }
         updateViewsForCell(bikeStation: bikeStation)
      }
   }

   func updateViewsForCell(bikeStation: BikeStation) {
      updateBikeStationLabels(bikeStation: bikeStation)
      updateDistanceAndDirectionLabels(stationsLocation: bikeStation.location)
      updateCustomConstraints(bikeStation: bikeStation)
   }
   
   private func updateBikeStationLabels(bikeStation: BikeStation) {
      self.nameLabel.text = bikeStation.name
      self.addressLabel.text = bikeStation.address
      self.numberOfBikesLabel.text = "\(bikeStation.freeBikes)"
      self.numberOfDocksLabel.text = "\(bikeStation.emptySlots)"
   }
   
   fileprivate func updateDistanceAndDirectionLabels(stationsLocation: CLLocation) {
      if CLLocationManager.authorizationStatus() == .authorizedAlways
         || CLLocationManager.authorizationStatus() == .authorizedWhenInUse,
         let usersLocation = BikeStationController.shared.locationManager.location {
         
         let distanceInMeters = usersLocation.distance(from: stationsLocation)
         let distanceInMiles = distanceInMeters / 1609.34
         let roundedDistanceInMiles = Double(round(distanceInMiles*10)/10)
         
         let directionString = cardinalDirectionFrom(usersLocation, to: stationsLocation)
         
         DispatchQueue.main.async {
            if roundedDistanceInMiles < 0.1 {
               self.distanceFromUserLabel.text = "↓0.1 mi \n \(directionString)"
            } else {
               self.distanceFromUserLabel.text = "\(roundedDistanceInMiles) mi \n \(directionString)"
            }
         }
         
      } else {
         distanceFromUserLabel.text = ""
      }
   }
   
   private func updateCustomConstraints(bikeStation: BikeStation) {
      let widthOfFrame = self.frame.width
      let percentageOfBikesTakenOut = CGFloat(bikeStation.freeBikes) / CGFloat(bikeStation.freeBikes + bikeStation.emptySlots)
      widthOfBikeBar.constant = widthOfFrame * percentageOfBikesTakenOut
      widthOfDistanceBar.isActive = ((CLLocationManager.authorizationStatus() == .authorizedAlways
         || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) && BikeStationController.shared.locationManager.location != nil)
   }
   
   private func cardinalDirectionFrom(_ usersLocation: CLLocation, to stationsLocation: CLLocation) -> String {
      let xValue = stationsLocation.coordinate.longitude - usersLocation.coordinate.longitude
      let yValue = stationsLocation.coordinate.latitude - usersLocation.coordinate.latitude
      let xCoordinate = xValue >= 0
      let yCoordinate = yValue >= 0
      
      guard yValue != 0 else {
         if xCoordinate { return "E" } else { return "W" }
      }
      
      switch (xCoordinate, yCoordinate) {
      // quadrant I
      case (true, true):
         if (xValue/yValue) >= 2 {
            return "E"
         } else if (xValue/yValue) <= 0.5 {
            return "N"
         } else {
            return "NE"
         }
      // quadrant II
      case (false, true):
         if abs(xValue/yValue) >= 2 {
            return "W"
         } else if abs(xValue/yValue) <= 0.5 {
            return "N"
         } else {
            return "NW"
         }
      // quadrant III
      case (false, false):
         if abs(xValue/yValue) >= 2 {
            return "W"
         } else if abs(xValue/yValue) <= 0.5 {
            return "S"
         } else {
            return "SW"
         }
      // quadrant IV
      case (true, false):
         if abs(xValue/yValue) >= 2 {
            return "E"
         } else if abs(xValue/yValue) <= 0.5 {
            return "S"
         } else {
            return "SE"
         }
      }
   }
}
