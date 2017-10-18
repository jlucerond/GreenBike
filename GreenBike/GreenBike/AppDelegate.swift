
//
//  AppDelegate.swift
//  GreenBike
//
//  Created by Joe Lucero on 9/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

   var window: UIWindow?

   func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      let _ = BikeStationController.shared
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(showSorry),
                                             name: ConstantNotificationNotices.apiNotWorking,
                                             object: nil)
      
      // FIXME: - Move this to the alerts controller during "first time + was pushed"
      let center = UNUserNotificationCenter.current()
      center.requestAuthorization(options: [.alert, .sound]) { (success, error) in
         print("was successful: \(success)")
      }
      
      return true
   }
   
   @objc func showSorry() {
      guard let window = window else { return }
      
      let alert = UIAlertController(title: "Uh-oh", message: "It looks like some servers are having issues.\nWe'll try to fix this ASAP. Sorry :/", preferredStyle: .alert)
      let action = UIAlertAction(title: "Darn", style: .default, handler: nil)
      alert.addAction(action)
      
      DispatchQueue.main.async {
         guard let tabBarVC = window.rootViewController else { return }
         tabBarVC.topMostViewController().present(alert, animated: true, completion: nil)
      }
   }

}


extension UIViewController {
   func topMostViewController() -> UIViewController {
      if self.presentedViewController == nil {
         return self
      }
      if let navigation = self.presentedViewController as? UINavigationController {
         return navigation.visibleViewController!.topMostViewController()
      }
      if let tab = self.presentedViewController as? UITabBarController {
         if let selectedTab = tab.selectedViewController {
            return selectedTab.topMostViewController()
         }
         return tab.topMostViewController()
      }
      return self.presentedViewController!.topMostViewController()
   }
}

extension UIApplication {
   func topMostViewController() -> UIViewController? {
      return self.keyWindow?.rootViewController?.topMostViewController()
   }
}

