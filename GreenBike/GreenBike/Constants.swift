//
//  Constants.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import Foundation
import UIKit

class ConstantNotificationNotices {
   // Notifications
   static let bikeStationsUpdatedNotification = Notification.Name("bikeStationsUpdated")
   static let locationUpdatedNotification = Notification.Name("userLocationUpdated")
}

class ConstantKeys {
   // Keys
   static let setOfAllFavoriteBikeStations = "favoriteBikeStations"

}

extension UIColor {
   static var primaryAppColor: UIColor {
      return UIColor(red: 12.0/255.0, green: 39.0/255.0, blue: 89.0/255.0, alpha: 1.0)
   }
   
   static var secondaryAppColor: UIColor {
      return UIColor(red: 236.0/255.0, green: 165.0/255.0, blue: 65.0/255.0, alpha: 1.0)
   }
   
   static var tertiaryAppColor: UIColor {
      return UIColor(red: 28.0/255.0, green: 68.0/255.0, blue: 32.0/255.0, alpha: 1.0)
   }
}
