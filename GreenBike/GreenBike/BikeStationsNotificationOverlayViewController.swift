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
   var animationLength: Int = 0
   var fromBikeStationName: String?
   var toBikeStationName: String?
   
   override func viewDidLoad() {
      super.viewDidLoad()
      // Do any additional setup after loading the view.
   }
   
   override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
      print(fromBikeStationName?.description ?? "No From station")
      print(toBikeStationName?.description ?? "No To station")
      runAnimation()
   }
   
   @IBAction func closeTapped() {
      dismiss(animated: false, completion: nil)
   }
   
   func runAnimation() {
      UIView.animate(withDuration: 3) {
         self.bikeWheel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi * 0.25))
         self.bikeWheel.alpha = 0.0
         
         if BikeStationController.shared.allBikeStations.count == 0 {
            
         }
      }
   }
   
}

