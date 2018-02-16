//
//  BikeStationsNotificationOverlayViewController.swift
//  GreenBike
//
//  Created by Joe Lucero on 2/11/18.
//  Copyright © 2018 Joe Lucero. All rights reserved.
//

import UIKit

class BikeStationsNotificationOverlayViewController: UIViewController {
   
   @IBOutlet weak var bikeWheel: UIImageView!
   @IBOutlet weak var bikeAndNumberView: UIView!
   @IBOutlet weak var stationAndNumberView: UIView!
   @IBOutlet weak var bikeNumberLabel: UILabel!
   @IBOutlet weak var bikeStationNumberLabel: UILabel!
   
   @IBOutlet weak var bikeAndStationInfoView: UIView!
   @IBOutlet weak var fromStationNameLabel: UILabel!
   @IBOutlet weak var fromStationInfoLabel: UILabel!
   @IBOutlet weak var toStationNameLabel: UILabel!
   @IBOutlet weak var toStationInfoLabel: UILabel!
   
   var animationLength: Double = 0
   var fromBikeStationName: String?
   var toBikeStationName: String?
   var fromBikeStation: BikeStation?
   var toBikeStation: BikeStation?

   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      moveIconsOffScreenAndHide()
      let duration = 3.0
      runLoadingAnimation(duration: duration) { (success) in
         if success {
            // update bikes
            self.updateBikeStationInformation()
            
            // run 3 animations
            self.runDockAnimation(duration: 1.0) { _ in
               self.runBikeAnimation(duration: 1.0) { _ in
                  self.runInfoAnimation(duration: 1.0)
               }
            }
            
         }
      }
   }
   
   @IBAction func closeTapped() {
      dismiss(animated: false, completion: nil)
   }
   
   func moveIconsOffScreenAndHide() {
      bikeAndNumberView.center.x -= self.view.frame.width
      bikeAndNumberView.alpha = 0.0
      stationAndNumberView.alpha = 0.0
      bikeAndStationInfoView.alpha = 0.0
   }
   
   func updateBikeStationInformation() {
      for station in BikeStationController.shared.allBikeStations {
         
         if station.name == fromBikeStationName {
            fromBikeStation = station
         }
         
         if station.name == toBikeStationName {
            toBikeStation = station
         }
      }
      
      if let fromBikeStation = fromBikeStation {
         bikeNumberLabel.text = String(fromBikeStation.freeBikes)
         fromStationNameLabel.text = fromBikeStation.name
         fromStationInfoLabel.text = "    \(fromBikeStation.freeBikes) bikes (\(fromBikeStation.emptySlots) empty stations)"
      } else {
         fromStationNameLabel.removeFromSuperview()
         fromStationInfoLabel.removeFromSuperview()
      }
      
      if let toBikeStation = toBikeStation {
         bikeStationNumberLabel.text = String(toBikeStation.emptySlots)
         toStationNameLabel.text = toBikeStation.name
         toStationInfoLabel.text = "    \(toBikeStation.emptySlots) empty stations (\(toBikeStation.freeBikes) bikes)"
      } else {
         toStationNameLabel.removeFromSuperview()
         toStationInfoLabel.removeFromSuperview()
      }
   }
}

// Animations
extension BikeStationsNotificationOverlayViewController {
   func runLoadingAnimation(duration: Double, completion: @escaping ((_ success: Bool) -> Void)) {
      
      UIView.animate(withDuration: duration, animations: {
         self.animationLength += duration
         self.bikeWheel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * -1))
         self.bikeWheel.alpha = 0.0
         
         if self.animationLength >= 10 {
            // FIXME: - show error
            print("too long! cancel out of this")
            completion(false)
         } else if BikeStationController.shared.allBikeStations.count == 0 {
            self.runLoadingAnimation(duration: duration, completion: completion)
         }
      }) {(success) in
         completion(success)
      }
   }
   
   func runDockAnimation(duration: Double, completion: @escaping ((Bool) -> Void)) {
      
      if toBikeStation != nil {
         UIView.animate(withDuration: duration,
                        delay: 0,
                        options: [],
                        animations: {
                           self.stationAndNumberView.alpha = 1.0 },
                        completion: completion)
      } else {
         completion(false)
      }
      

      

      
   }
   
   func runBikeAnimation(duration: Double, completion: @escaping ((Bool) -> Void)) {
      
      if fromBikeStation != nil {
         UIView.animate(withDuration: duration,
                        delay: 0,
                        options: [UIViewAnimationOptions.curveEaseInOut],
                        animations: {
                           self.bikeAndNumberView.alpha = 1.0
                           self.bikeAndNumberView.center.x += self.view.frame.width },
                        completion: completion)
      } else {
         completion(false)
      }
   }
   
   func runInfoAnimation(duration: Double) {
      UIView.animate(withDuration: duration,
                     delay: 0,
                     options: [],
                     animations: {
                        self.bikeAndStationInfoView.alpha = 1.0 },
                     completion: nil)
   }
   
}
















