//
//  BikeStationPickerTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/10/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

protocol BikeStationPickerTableViewControllerDelegate {
   func didSelectBikeStation(_ controller: BikeStationPickerTableViewController, bikeStation: BikeStation, toOrFrom: ToOrFrom)
}

class BikeStationPickerTableViewController: UITableViewController {
   
   var allBikeStationsSortedByDistance: [BikeStation] = []
   var delegate: BikeStationPickerTableViewControllerDelegate?
   var toOrFrom: ToOrFrom!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      allBikeStationsSortedByDistance = BikeStationController.shared.allBikeStationsSortedByDistance ?? BikeStationController.shared.allBikeStations
   }
   
   // MARK: - Table view data source & delegate methods
   override func tableView(_ tableView: UITableView,
                           numberOfRowsInSection section: Int) -> Int {
      return allBikeStationsSortedByDistance.count
   }
   
   override func tableView(_ tableView: UITableView,
                           cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      let bikeStation = allBikeStationsSortedByDistance[indexPath.row]
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "BikeStations", for: indexPath)
      
      cell.textLabel?.text = bikeStation.name
      cell.detailTextLabel?.text = distanceFromUserToStation(bikeStation: bikeStation)
      
      return cell
   }
   
   override func tableView(_ tableView: UITableView,
                           didSelectRowAt indexPath: IndexPath) {
      let bikeStation = allBikeStationsSortedByDistance[indexPath.row]
      delegate?.didSelectBikeStation(self, bikeStation: bikeStation, toOrFrom: toOrFrom)
   }
   
}

// MARK: - Helper Methods
extension BikeStationPickerTableViewController {
   func distanceFromUserToStation(bikeStation: BikeStation) -> String? {
      guard let usersLocation = BikeStationController.shared.locationManager.location else { return nil }
      
      let distanceInMeters = Measurement(value: usersLocation.distance(from: bikeStation.location), unit: UnitLength.meters)
      
      let distanceInMiles = distanceInMeters.converted(to: .miles)
      let roundedDistanceInMiles = Double(round(distanceInMiles.value*10)/10)
      
      if distanceInMiles.value < 0.1 {
         return "↓0.1 mi away"
      } else {
         return "\(roundedDistanceInMiles) mi away"
      }
   }
}
