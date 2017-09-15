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
   var setOfFavoriteBikeStationNames: Set<String> = []
   var arrayOfFavoriteBikeStations: [BikeStation] = []
   var arrayOfAllBikeStationsSortedByProximity: [BikeStation] = [] {
      didSet {
         updateFavoriteBikeStationsArray()
      }
   }
   let myRefreshControl = UIRefreshControl()
   let longPress = UILongPressGestureRecognizer()
   
   // MARK: - IBActions
   @IBAction func refreshBarButtonItemPressed(_ sender: UIBarButtonItem) {
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   // MARK: - Life Cycle Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      tableView.refreshControl = myRefreshControl
      longPress.minimumPressDuration = 1.0
      longPress.addTarget(self, action: #selector(userDidLongPress))
      tableView.addGestureRecognizer(longPress)
      
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
      print("resized")
      tableView.reloadData()
   }

}

// Table View Data Source & Delegate Methods
extension BikeStationsTableViewController {
   override func numberOfSections(in tableView: UITableView) -> Int {
      guard !arrayOfAllBikeStationsSortedByProximity.isEmpty else { return 0 }
      
      return arrayOfFavoriteBikeStations.isEmpty ? 1 : 2
   }
   
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if arrayOfFavoriteBikeStations.isEmpty {
         return arrayOfAllBikeStationsSortedByProximity.count
      } else {
         return section == 0 ? arrayOfFavoriteBikeStations.count : arrayOfAllBikeStationsSortedByProximity.count
      }
   }
   
   override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
      return "Help this"
   }
   
   override func tableView(_ tableView: UITableView,
                           viewForHeaderInSection section: Int) -> UIView? {
      
      var titleForHeader: String
      if !arrayOfFavoriteBikeStations.isEmpty && section == 0 {
         titleForHeader = "Favorites"
      } else {
         titleForHeader = "Nearest Stations"
      }
      
      let frameForTitleLabel = CGRect(x: 10, y: 0, width: 50, height: 50)
      let titleLabel = UILabel(frame: frameForTitleLabel)
      titleLabel.text = titleForHeader
      titleLabel.font = UIFont(name: "Copperplate", size: 25.0)
      titleLabel.textColor = UIColor.secondaryAppColor
      titleLabel.sizeToFit()

      let frameForHeader = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 0)
      let viewForHeader = UIView(frame: frameForHeader)
      viewForHeader.backgroundColor = UIColor.primaryAppColor
      viewForHeader.addSubview(titleLabel)

      
      return viewForHeader
   }
   
   override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

      if !arrayOfFavoriteBikeStations.isEmpty && indexPath.section == 0 {
         // Display All Favorite Stations
         let bikeStation = arrayOfFavoriteBikeStations[indexPath.row]
         
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "BikeStationCell", for: indexPath) as? BikeStationTableViewCell else { return UITableViewCell() }
         
         cell.firstTimeOnScreen = true
         cell.bikeStation = bikeStation
         
         return cell
         
      } else {
         // Display All Nearest Stations In Order
         let bikeStation = arrayOfAllBikeStationsSortedByProximity[indexPath.row]
         
         guard let cell = tableView.dequeueReusableCell(withIdentifier: "BikeStationCell", for: indexPath) as? BikeStationTableViewCell else { return UITableViewCell() }
         
         cell.firstTimeOnScreen = true
         cell.bikeStation = bikeStation
         
         return cell
      }
   }
   
}

// MARK: - Helper Methods
extension BikeStationsTableViewController {
   
   func updateNearestBikeStations() {
      myRefreshControl.endRefreshing()
      guard let userLocation = BikeStationController.shared.locationManager.location else {
         arrayOfAllBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations
         return }
      
      arrayOfAllBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations.sorted(by: { (stationA, stationB) -> Bool in
         stationA.location.distance(from: userLocation) < stationB.location.distance(from: userLocation)
      })
      
      DispatchQueue.main.async {
         self.tableView.reloadData()
      }
   }
   
   func refreshControlWasPulled() {
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   func userDidLongPress() {
      let pointSelected = longPress.location(in: tableView)
      guard let indexPath = tableView.indexPathForRow(at: pointSelected),
         let cell = tableView.cellForRow(at: indexPath) as? BikeStationTableViewCell,
         let bikeStationSelected = cell.bikeStation,
         !setOfFavoriteBikeStationNames.contains(bikeStationSelected.name)  else { return }
      
      askUserIfTheyWantToFavoriteStation(bikeStationSelected)
   }
   
   func askUserIfTheyWantToFavoriteStation(_ station: BikeStation) {
      let alert = UIAlertController(title: "Add To Favorites?", message: "\(station.name)", preferredStyle: .alert)
      
      let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
         self.setOfFavoriteBikeStationNames.insert(station.name)
         self.updateFavoriteBikeStationsArray()
      }
      alert.addAction(yesAction)
      
      let noAction = UIAlertAction(title: "No", style: .default)
      alert.addAction(noAction)
      
      self.present(alert, animated: true)
   }
   
   func updateFavoriteBikeStationsArray() {
      arrayOfFavoriteBikeStations = []
      for stationName in setOfFavoriteBikeStationNames {
         for station in arrayOfAllBikeStationsSortedByProximity {
            if stationName == station.name {
               arrayOfFavoriteBikeStations.append(station)
            }
         }
      }
   }
}
