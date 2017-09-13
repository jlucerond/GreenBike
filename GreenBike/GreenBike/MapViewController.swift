//
//  MapViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

   // IBOutlets
   @IBOutlet weak var mapView: MKMapView!
   
   // Variables
   fileprivate let bikeStationIdentifier = "BikeStation"
   var locationManager: CLLocationManager?
   
   // IBActions
   @IBAction func refreshButtonPushed(_ sender: UIBarButtonItem) {
      self.mapView.removeAnnotations(BikeStationController.shared.allBikeStations)
      BikeStationController.shared.refreshBikeStationsStatuses()
   }
   
   @IBAction func locateUserButtonPressed(_ sender: UIButton) {
      if locationManager == nil {
         locationManager = CLLocationManager()
         locationManager?.requestWhenInUseAuthorization()
         locationManager?.desiredAccuracy = kCLLocationAccuracyBest
         locationManager?.delegate = self
      }
      
      // if we have a user location, then center on the user. else, center on all bike shares
      if CLLocationManager.locationServicesEnabled() {
         showSelfAndNearestThreeBikeStations()
      } else {
         showAllBikeStations()
      }
      
   }

   // Life Cycle Methods
   override func viewDidLoad() {
      super.viewDidLoad()
      mapView.delegate = self
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(updateBikeStationsOnMap),
                                             name: NotificationNotices.bikeStationsUpdatedNotification,
                                             object: nil)
      
      loadMapForFirstTime()
   }
   
   // delete this
   override func didRotate(from fromInterfaceOrientation: UIInterfaceOrientation) {
      let slcCenter = CLLocationCoordinate2D(latitude: 40.76593214888245, longitude: -111.89142500000003)
      let slcLatMeters = 2500.0
      let slcLongMeters = 4000.0
      
      let slcRegion = MKCoordinateRegionMakeWithDistance(slcCenter, slcLatMeters, slcLongMeters)
      mapView.setRegion(slcRegion, animated: true)
   }


}

// MARK: - User Interface Methods
extension MapViewController {
   
   func loadMapForFirstTime() {
      // FIXME: - Need to screenshot this and use as the loading screen
      
      BikeStationController.shared.refreshBikeStationsStatuses()

      let slcCenter = CLLocationCoordinate2D(latitude: 40.76593214888245, longitude: -111.89142500000003)
      let slcLatMeters = 2500.0
      let slcLongMeters = 4000.0
      
      let slcRegion = MKCoordinateRegionMakeWithDistance(slcCenter, slcLatMeters, slcLongMeters)
      mapView.setRegion(slcRegion, animated: true)
      
   }
   
   func updateBikeStationsOnMap() {
      
      DispatchQueue.main.async {
         self.mapView.addAnnotations(BikeStationController.shared.allBikeStations)
      }
   }
   
   func showAllBikeStations() {
      mapView.showAnnotations(BikeStationController.shared.allBikeStations, animated: true)
   }
   
   func showSelfAndNearestThreeBikeStations() {
      let userLocation = mapView.userLocation
      guard let usersUnwrappedLocation = userLocation.location else { return }
      
      let allBikeStationsInOrder = BikeStationController.shared.allBikeStations.sorted { (stationA, stationB) -> Bool in
         return stationA.location.distance(from: usersUnwrappedLocation) < stationB.location.distance(from: usersUnwrappedLocation)
      }
      
      guard allBikeStationsInOrder.count >= 2 else { return }
      var allItemsToShow: [MKAnnotation] = [userLocation]
      
      for station in allBikeStationsInOrder[0...2] {
         let stationAsAnnotation = station as MKAnnotation
         allItemsToShow.append(stationAsAnnotation)
      }
      

      mapView.showAnnotations(allItemsToShow, animated: true)
   }
}

// MARK: - Core Location Methods
extension MapViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager,
                        didChangeAuthorization status: CLAuthorizationStatus) {
      if status == .authorizedAlways || status == .authorizedWhenInUse {
         locationManager?.startUpdatingLocation()
      }
   }
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

