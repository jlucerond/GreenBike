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
   
   // Variables
   fileprivate let bikeStationIdentifier = "BikeStationPinIdentifier"
   //   var locationManager: CLLocationManager?
   var arrayOfBikeStations: [BikeStation] = [] {
      willSet {
         DispatchQueue.main.async {
            let allAnnotations = self.mapView.annotations
            self.mapView.removeAnnotations(allAnnotations)
         }
      } didSet {
         DispatchQueue.main.async {
            self.mapView.addAnnotations(self.arrayOfBikeStations)
         }
      }
   }
   
   // IBActions
   @IBAction func refreshButtonPushed(_ sender: UIBarButtonItem) {
      self.mapView.removeAnnotations(self.arrayOfBikeStations)
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   @IBAction func locateUserButtonPressed(_ sender: UIButton) {
      BikeStationController.shared.locationManager.requestWhenInUseAuthorization()
      
      // if we have a user location, then center on the user. else, center on all bike shares
      if CLLocationManager.locationServicesEnabled() && (CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
         mapShouldShowUserAndThreeNearestStations()
      } else {
         mapShouldShowAllStations()
      }
      
   }
   
   // Life Cycle Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      mapView.delegate = self
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(bikeStationControllerWasReloaded),
                                             name: ConstantNotificationNotices.bikeStationsUpdatedNotification,
                                             object: nil)
      
      loadMapForFirstTime()
   }
   
}

// MARK: - User Interface Methods
extension MapViewController {
   
   func loadMapForFirstTime() {
      // FIXME: - Need to screenshot this and use as the loading screen
      let slcCenter = CLLocationCoordinate2D(latitude: 40.76593214888245, longitude: -111.89142500000003)
      let slcLatMeters = 2500.0
      let slcLongMeters = 4000.0
      
      let slcRegion = MKCoordinateRegionMakeWithDistance(slcCenter, slcLatMeters, slcLongMeters)
      mapView.setRegion(slcRegion, animated: true)
      
   }
   
   @objc func bikeStationControllerWasReloaded() {
      arrayOfBikeStations = BikeStationController.shared.allBikeStations
   }
   
   func mapShouldShowAllStations() {
      mapView.showAnnotations(arrayOfBikeStations, animated: true)
   }
   
   func mapShouldShowUserAndThreeNearestStations() {
      guard let usersUnwrappedLocation = BikeStationController.shared.locationManager.location else { return }
      
      let allBikeStationsInOrder = arrayOfBikeStations.sorted { (stationA, stationB) -> Bool in
         return stationA.location.distance(from: usersUnwrappedLocation) < stationB.location.distance(from: usersUnwrappedLocation)
      }
      
      guard allBikeStationsInOrder.count >= 2 else { return }
      var allItemsToShow: [MKAnnotation] = [mapView.userLocation]
      
      for station in allBikeStationsInOrder[0...2] {
         let stationAsAnnotation = station as MKAnnotation
         allItemsToShow.append(stationAsAnnotation)
      }
      
      
      mapView.showAnnotations(allItemsToShow, animated: true)
   }
}

// MARK: - Core Location Methods
extension MapViewController: CLLocationManagerDelegate {
   
}

// MARK: - Mapview Delegate Methods
extension MapViewController: MKMapViewDelegate {
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      
      if (annotation is MKUserLocation) {
         return nil
      }
      
      var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: bikeStationIdentifier) as? MKPinAnnotationView
      
      if annotationView == nil {
         annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: bikeStationIdentifier)
      } else {
         annotationView?.annotation = annotation
      }
      
      annotationView?.pinTintColor = UIColor.tertiaryAppColor
      annotationView?.canShowCallout = true
      annotationView?.animatesDrop = true
      
      return annotationView
   }
}

