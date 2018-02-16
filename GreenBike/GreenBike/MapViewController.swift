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
   private var isFirstTimeLoadingMap = true
   
   // Variables
   fileprivate let bikeStationIdentifier = "BikeStationPinIdentifier"
   
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
   }
   
   @objc func updateAnnotations() {
      DispatchQueue.main.sync {
         let oldAnnotations = self.mapView.annotations
         self.mapView.addAnnotations(BikeStationController.shared.allBikeStations)
         self.mapView.removeAnnotations(oldAnnotations)
      }
      isFirstTimeLoadingMap = false
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
   // FIXME: - this is where I'll need to add custom image for bike stations
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
      annotationView?.animatesDrop = isFirstTimeLoadingMap

      return annotationView
   }
}

