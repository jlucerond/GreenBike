//
//  MapViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
   
   // IBOutlets
   @IBOutlet weak var mapView: MKMapView!
   @IBOutlet weak var locationFinderButton: UIButton!
   
   // IBActions
   @IBAction func refreshButtonPushed(_ sender: UIBarButtonItem) {
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   @IBAction func locateUserButtonPressed(_ sender: UIButton) {
      BikeStationController.shared.locationManager.requestWhenInUseAuthorization()
      mapShowUserAndThreeNearestStations()
   }
   
   // Life Cycle Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      loadMapForFirstTime()
      mapView.delegate = self
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateAnnotations),
                                             name: ConstantNotificationNotices.bikeStationsUpdatedNotification,
                                             object: nil)
      
      if #available(iOS 11.0, *) {
         let attributes = [
            NSAttributedStringKey.foregroundColor : UIColor.secondaryAppColor
         ]
         navigationController?.navigationBar.largeTitleTextAttributes = attributes
      }
      
      let tintedImage = UIImage(named: "LocationIcon")?.tinted(fillWith: .secondaryAppColor)
      locationFinderButton.setBackgroundImage(tintedImage, for: .normal)
   }
   
}

// MARK: - User Interface Methods
extension MapViewController {
   
   func loadMapForFirstTime() {
      // FIXME: - Take screenshots on different phone sizes and use as the loading screen
      let slcCenter = CLLocationCoordinate2D(latitude: 40.76593214888245, longitude: -111.89142500000003)
      let slcLatMeters = 2500.0
      let slcLongMeters = 4000.0
      
      let slcRegion = MKCoordinateRegionMakeWithDistance(slcCenter, slcLatMeters, slcLongMeters)
      mapView.setRegion(slcRegion, animated: true)
      
      if mapView.annotations.count <= 1 {
         updateAnnotations()
      }
   }
   
   @objc func updateAnnotations() {
      
      DispatchQueue.main.async {
         let oldAnnotations = self.mapView.annotations
         self.mapView.addAnnotations(BikeStationController.shared.allBikeStations)
         self.mapView.removeAnnotations(oldAnnotations)
      }
   }
   
   func mapShowAllStations() {
      mapView.showAnnotations(BikeStationController.shared.allBikeStations, animated: true)
   }
   
   func mapShowUserAndThreeNearestStations() {
      
      guard let allBikeStationsInOrder = BikeStationController.shared.allBikeStationsSortedByDistance, allBikeStationsInOrder.count >= 2 else {
         mapShowAllStations()
         return
      }
      
      var allItemsToShow: [MKAnnotation] = [mapView.userLocation]
      
      for station in allBikeStationsInOrder[0...2] {
         let stationAsAnnotation = station as MKAnnotation
         allItemsToShow.append(stationAsAnnotation)
      }
      
      mapView.showAnnotations(allItemsToShow, animated: true)
   }
}

// MARK: - Mapview Delegate Methods
extension MapViewController: MKMapViewDelegate {

   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      // use the default view for MKUserLocation
      if (annotation is MKUserLocation) {
         return nil
      }
      
      // for all other annotations, there should be a bike station associated with that view
      guard let bikeStation = annotation as? BikeStation else { return nil }
      
      let bikeStationPinView = BikeStationPinView(bikeStation: bikeStation, reuseIdentifier: "BikeStationPinIdentifer")
      bikeStationPinView.canShowCallout = true

      return bikeStationPinView
   }
   
}

