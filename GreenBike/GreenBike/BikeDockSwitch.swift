//
//  BikeDockSwitch.swift
//  GreenBike
//
//  Created by Joe Lucero on 6/15/18.
//  Copyright © 2018 Joe Lucero. All rights reserved.
//

import UIKit

@IBDesignable
class BikeDockSwitch: UIView {

   @IBInspectable var isOn: Bool = true
   @IBInspectable let customBGColor: UIColor = UIColor.clear
   
   let bikeOrDockSwitch = UISwitch()
   let bikeOrDockImageView = UIImageView()
   var xConstraint: NSLayoutConstraint!
   
   override init(frame: CGRect) {
      super.init(frame: .zero)
      setUp()
   }
   
   required init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
      setUp()
   }
   
   override func prepareForInterfaceBuilder() {
      super.prepareForInterfaceBuilder()
      
      backgroundColor = customBGColor
      
      bikeOrDockSwitch.onTintColor = UIColor.secondaryAppColor
      addSubview(bikeOrDockSwitch)
      
      bikeOrDockImageView.image = UIImage(named: "BikeIcon")
      bikeOrDockImageView.bounds = CGRect(x: 0, y: 0, width: 20, height: 20)
      addSubview(bikeOrDockImageView)
   }
   
   func setUp() {
      backgroundColor = customBGColor
      
      bikeOrDockSwitch.onTintColor = UIColor.primaryAppColor
      bikeOrDockSwitch.thumbTintColor = UIColor.secondaryAppColor
      bikeOrDockSwitch.isOn = BikeStationController.shared.isMapShowingBikeNumbers
      bikeOrDockSwitch.addTarget(self, action: #selector(switchTapped), for: .valueChanged)
      addSubview(bikeOrDockSwitch)
      
      bikeOrDockImageView.image = BikeStationController.shared.isMapShowingBikeNumbers ? UIImage(named: "BikeIcon") : UIImage(named: "BikeDockIcon")
      addSubview(bikeOrDockImageView)
      
      bikeOrDockImageView.translatesAutoresizingMaskIntoConstraints = false
      NSLayoutConstraint(item: bikeOrDockImageView,
                         attribute: NSLayoutAttribute.width,
                         relatedBy: .equal,
                         toItem: nil,
                         attribute: .notAnAttribute,
                         multiplier: 1,
                         constant: 20).isActive = true
      NSLayoutConstraint(item: bikeOrDockImageView,
                         attribute: .height,
                         relatedBy: .equal,
                         toItem: nil,
                         attribute: .notAnAttribute,
                         multiplier: 1,
                         constant: 20).isActive = true
      NSLayoutConstraint(item: bikeOrDockImageView,
                         attribute: .centerY,
                         relatedBy: .equal,
                         toItem: self,
                         attribute: .centerY,
                         multiplier: 1,
                         constant: 0).isActive = true
      
      let constant: CGFloat = BikeStationController.shared.isMapShowingBikeNumbers ? 10 : -10
      xConstraint = NSLayoutConstraint(item: bikeOrDockImageView,
                                       attribute: .centerX,
                                       relatedBy: .equal,
                                       toItem: self,
                                       attribute: .centerX,
                                       multiplier: 1,
                                       constant: constant)
      xConstraint.isActive = true
   }
   
   @objc func switchTapped() {
      let switchIsOn = bikeOrDockSwitch.isOn
      BikeStationController.shared.isMapShowingBikeNumbers = switchIsOn
      NotificationCenter.default.post(name: ConstantNotificationNotices.bikeStationsUpdatedNotification, object: nil)
      
      UIView.animate(withDuration: 0.14,
                     delay: 0,
                     options: .curveLinear,
                     animations: {
                        self.xConstraint.constant = switchIsOn ? 10 : -10
                        self.bikeOrDockImageView.alpha = 0
                        self.layoutIfNeeded()
      }) { _ in
         self.bikeOrDockImageView.image = BikeStationController.shared.isMapShowingBikeNumbers ? UIImage(named: "BikeIcon") : UIImage(named: "BikeDockIcon")
         self.bikeOrDockImageView.alpha = 1
      }

   }
   
   
}
