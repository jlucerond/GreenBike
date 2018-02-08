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
   var arrayOfFavoriteBikeStationNames: [String] = []
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
      
      self.tableView.sectionHeaderHeight = UITableViewAutomaticDimension
      self.tableView.estimatedSectionHeaderHeight = 80;
      
      tableView.refreshControl = myRefreshControl
      longPress.minimumPressDuration = 1.0
      longPress.addTarget(self, action: #selector(userDidLongPress))
      tableView.addGestureRecognizer(longPress)
      
      myRefreshControl.addTarget(self, action: #selector(refreshControlWasPulled), for: .valueChanged)
      
      if let arrayOfSavedBikeStationNames = UserDefaults.standard.array(forKey: ConstantKeys.setOfAllFavoriteBikeStations) as? [String] {
         arrayOfFavoriteBikeStationNames = arrayOfSavedBikeStationNames
      }
      
      updateNearestBikeStations()
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateNearestBikeStations),
                                             name: ConstantNotificationNotices.bikeStationsUpdatedNotification,
                                             object: nil)
      
   }
   
   // MARK: - Orientation Methods
   override func viewWillTransition(to size: CGSize,
                                    with coordinator: UIViewControllerTransitionCoordinator) {
      tableView.reloadData()
   }

}

// MARK: - Table View Data Source & Delegate Methods
extension BikeStationsTableViewController {
   // Header Methods
   override func numberOfSections(in tableView: UITableView) -> Int {
      guard !arrayOfAllBikeStationsSortedByProximity.isEmpty else { return 0 }
      
      return arrayOfFavoriteBikeStations.isEmpty ? 1 : 2
   }
   
   
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 40.666666667
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
      titleLabel.font = UIFont(name: "Copperplate", size: 40.0)
      titleLabel.textColor = UIColor.primaryAppColor
      titleLabel.sizeToFit()
      
      let frameForHeader = CGRect()
      let viewForHeader = UIView(frame: frameForHeader)
      viewForHeader.backgroundColor = UIColor.secondaryAppColor
      viewForHeader.addSubview(titleLabel)
      viewForHeader.alpha = 1.0
      
      return viewForHeader
   }
   
   // Rows & Cells Methods
   override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      if arrayOfFavoriteBikeStations.isEmpty {
         return arrayOfAllBikeStationsSortedByProximity.count
      } else {
         return section == 0 ? arrayOfFavoriteBikeStations.count : arrayOfAllBikeStationsSortedByProximity.count
      }
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
   
   override func tableView(_ tableView: UITableView,
                           canEditRowAt indexPath: IndexPath) -> Bool {
      if tableView.numberOfSections == 2 && (indexPath.section == 0) {
         return true
      } else {
         return false
      }
   }
   
   override func tableView(_ tableView: UITableView,
                           commit editingStyle: UITableViewCellEditingStyle,
                           forRowAt indexPath: IndexPath) {
      if indexPath.section == 0
      && tableView.numberOfSections == 2
      && editingStyle == .delete {
         let stationToRemove = arrayOfFavoriteBikeStations[indexPath.row]
         removeStationFromFavorites(stationToRemove)
      }
   }
   
}

// MARK: - Helper Methods
extension BikeStationsTableViewController {
   
   @objc func updateNearestBikeStations() {
      // FIXME: - I need to add something else in this code on the main thread
      DispatchQueue.main.async {
         self.myRefreshControl.beginRefreshing()
      }
      
      guard let userLocation = BikeStationController.shared.locationManager.location else {
         arrayOfAllBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations
         myRefreshControl.endRefreshing()
         return }
      
      arrayOfAllBikeStationsSortedByProximity = BikeStationController.shared.allBikeStations.sorted(by: { (stationA, stationB) -> Bool in
         stationA.location.distance(from: userLocation) < stationB.location.distance(from: userLocation)
      })
      
      DispatchQueue.main.async {
         self.tableView.reloadData()
         self.myRefreshControl.endRefreshing()
      }
   }
   
   @objc func refreshControlWasPulled() {
      updateNearestBikeStations()
   }
   
   @objc func userDidLongPress() {
      let pointSelected = longPress.location(in: tableView)
      guard let indexPath = tableView.indexPathForRow(at: pointSelected),
         let cell = tableView.cellForRow(at: indexPath) as? BikeStationTableViewCell,
         let bikeStationSelected = cell.bikeStation,
         !arrayOfFavoriteBikeStationNames.contains(bikeStationSelected.name),
         longPress.state == .began else { return }
      
      askUserIfTheyWantToFavoriteStation(bikeStationSelected)
   }
   
   func askUserIfTheyWantToFavoriteStation(_ station: BikeStation) {

      let alert = UIAlertController(title: "Add To Favorites?", message: "\(station.name)", preferredStyle: .alert)
      
      let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
         self.arrayOfFavoriteBikeStationNames.append(station.name)
         self.saveToUserDefaults()
         self.updateFavoriteBikeStationsArray()
      }
      alert.addAction(yesAction)
      
      let noAction = UIAlertAction(title: "No", style: .default)
      alert.addAction(noAction)
      
      self.present(alert, animated: true)
   }
   
   func removeStationFromFavorites(_ station: BikeStation) {
      for name in arrayOfFavoriteBikeStationNames where name == station.name {
         guard let indexRowToDelete = arrayOfFavoriteBikeStationNames.index(of: name) else { return }
         arrayOfFavoriteBikeStationNames.remove(at: indexRowToDelete)
      }
      saveToUserDefaults()
      updateFavoriteBikeStationsArray()
   }
   
   func updateFavoriteBikeStationsArray() {
      arrayOfFavoriteBikeStations = []
      for stationName in arrayOfFavoriteBikeStationNames {
         for station in arrayOfAllBikeStationsSortedByProximity {
            if stationName == station.name {
               arrayOfFavoriteBikeStations.append(station)
            }
         }
      }
      DispatchQueue.main.async {
         self.tableView.reloadData()
      }
   }
   
   func saveToUserDefaults() {
      UserDefaults.standard.set(self.arrayOfFavoriteBikeStationNames, forKey: ConstantKeys.setOfAllFavoriteBikeStations)
   }
}
