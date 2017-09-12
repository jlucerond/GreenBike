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
      BikeStationController.shared.refreshBikeStationsStatuses()
      updateBikeStationsOnMap()
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
         showSelfAndNearestBikeStation()
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
      showAllBikeStations()
   }
   
   


}

// MARK: - User Interface Methods
extension MapViewController {
   
   func updateBikeStationsOnMap() {
      DispatchQueue.main.async {
         self.mapView.showAnnotations(BikeStationController.shared.allBikeStations, animated: false)
      }
   }
   
   func showAllBikeStations() {
      var latMin: Double = 10000
      var latMax: Double = -10000
      var longMin: Double = 10000
      var longMax: Double = -10000
      
      guard !BikeStationController.shared.allBikeStations.isEmpty else { return }
      
      for station in BikeStationController.shared.allBikeStations {
         if station.latitude <= latMin { latMin = station.latitude }
         if station.latitude >= latMax { latMax = station.latitude }
         if station.longitude <= longMin { longMin = station.longitude }
         if station.longitude >= longMax { longMax = station.longitude }
      }
      
      let latCenter = (latMin + latMax)/2
      let longCenter = (longMin + longMax)/2
      let center = CLLocationCoordinate2D(latitude: latCenter, longitude: longCenter)
      
      let topCenter = CLLocation(latitude: latMax, longitude: longCenter)
      let bottomCenter = CLLocation(latitude: latMin, longitude: longCenter)
      let latMeters = topCenter.distance(from: bottomCenter)
      
      let middleLeft = CLLocation(latitude: latCenter, longitude: longMin)
      let middleRight = CLLocation(latitude: latCenter, longitude: longMax)
      let longMeters = middleLeft.distance(from: middleRight)
      
      showMapWith(center, latMeters, longMeters, animated: true)
   }
   
   func showSelfAndNearestBikeStation() {
      //FIXME: - Here's your next job
      guard CLLocationManager.locationServicesEnabled(),
         let userLocation = locationManager?.location,
         var closestBikeStation = BikeStationController.shared.allBikeStations.first
            else { showAllBikeStations() ; return }
      
      for station in BikeStationController.shared.allBikeStations {
         if station.location.distance(from: userLocation) < closestBikeStation.location.distance(from: userLocation) {
            closestBikeStation = station
         }
      }
      
      let radiiForMap = latAndLongDistancesBetween(userLocation.coordinate, and: closestBikeStation.coordinate)
      
      showMapWith(userLocation.coordinate, radiiForMap.latMeters, radiiForMap.longMeters, animated: true)
      
   }
   
   func showMapWith(_ center: CLLocationCoordinate2D,
                    _ latMeters: CLLocationDistance,
                    _ longMeters: CLLocationDistance,
                    animated: Bool) {
      let regionToShow = MKCoordinateRegionMakeWithDistance(center, (5 * latMeters), (5 * longMeters))
      
      DispatchQueue.main.async {
         self.mapView.setRegion(regionToShow, animated: animated)
      }
   }
   
   func latAndLongDistancesBetween(_ pointA: CLLocationCoordinate2D, and pointB: CLLocationCoordinate2D) -> (latMeters: CLLocationDistance, longMeters: CLLocationDistance) {
      let pointALocation = CLLocation(latitude: pointA.latitude, longitude: pointA.longitude)
      let pointDueEastOrWest = CLLocation(latitude: pointA.latitude, longitude: pointB.longitude)
      let latMeters = pointALocation.distance(from: pointDueEastOrWest)
      
      let pointDueNorthOrSouth = CLLocation(latitude: pointB.latitude, longitude: pointA.longitude)
      let longMeters = pointALocation.distance(from: pointDueNorthOrSouth)
      
      return (latMeters, longMeters)
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
      
      annotationView?.pinTintColor = UIColor.purple
      annotationView?.canShowCallout = true
      annotationView?.animatesDrop = true
      
      return annotationView
   }
}

