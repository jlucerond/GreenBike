//
//  BikeStationsTableViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/13/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import CoreLocation

class BikeStationsTableViewController: UITableViewController {
   
   // MARK: - Variables
   var arrayOfFavoriteBikeStations: [BikeStation] = []
   var arrayOfBikeStationsSortedByProximity: [BikeStation] = []
   let myRefreshControl = UIRefreshControl()
   
   // MARK: - IBActions
   @IBAction func refreshBarButtonItemPressed(_ sender: UIBarButtonItem) {
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   // MARK: - Life Cycle Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.refreshControl = myRefreshControl
      myRefreshControl.addTarget(self, action: #selector(refreshControlWasPulled), for: .valueChanged)
      
      updateNearestBikeStations()
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateNearestBikeStations),
                                             name: NotificationNotices.bikeStationsUpdatedNotification,
                                             object: nil)
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateNearestBikeStations),
                                             name: NotificationNotices.locationUpdatedNotification,
                                             object: nil)
      
   }
   
   // MARK: - Orientation Methods
   override func viewWillTransition(to size: CGSize,
                                    with coordinator: UIViewControllerTransitionCoordinator) {
      tableView.reloadData()
   }

}

// Table View Data Source & Delegate Methods
extension BikeStationsTableViewController {
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return arrayOfBikeStationsSortedByProximity.count
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
      // get bike station
      let bikeStation = arrayOfBikeStationsSortedByProximity[indexPath.row]
      
      guard let cell = tableView.dequeueReusableCell(withIdentifier: "BikeStationCell", for: indexPath) as? BikeStationTableViewCell else { return UITableViewCell() }
      
      // use bike station in this method
      cell.bikeStation = bikeStation
      
      return cell
   }
   
   func refreshControlWasPulled() {
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
}

// MARK: - Helper Methods
extension BikeStationsTableViewController {
   
   // MARK: - Helper Methods
   func updateNearestBikeStations() {
      myRefreshControl.endRefreshing()
      guard let userLocation = BikeStationController.shared.locationManager.location else {
         arrayOfBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations
         return }
      
      arrayOfBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations.sorted(by: { (stationA, stationB) -> Bool in
         stationA.location.distance(from: userLocation) < stationB.location.distance(from: userLocation)
      })
      
      DispatchQueue.main.async {
         self.tableView.reloadData()
      }
   }
}
