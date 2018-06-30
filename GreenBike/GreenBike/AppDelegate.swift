
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
   
   func application(_ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
      let _ = BikeStationController.shared
      
      UNUserNotificationCenter.current().delegate = self
      
      
      
      return true
   }
   
   func applicationDidBecomeActive(_ application: UIApplication) {
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(showSorry),
                                             name: ConstantNotificationNotices.apiNotWorking,
                                             object: nil)
   }
   
   func applicationDidEnterBackground(_ application: UIApplication) {
      NotificationCenter.default.removeObserver(self,
                                                name: ConstantNotificationNotices.apiNotWorking,
                                                object: nil)
   }
   
   
   
   // MARK: - Error Handling
   /// Show error
   @objc func showSorry() {
      DispatchQueue.main.async {
         guard UIApplication.shared.applicationState == .active else { return }
         guard let window = self.window else { return }
         
         let alert = UIAlertController(title: "Uh-oh", message: "Network error.\n\nThis is usually the result of a bad network signal or server issues.", preferredStyle: .alert)
         let action = UIAlertAction(title: "Darn", style: .default, handler: nil)
         alert.addAction(action)
         
         guard let tabBarVC = window.rootViewController else { return }
         
         if let _ =  tabBarVC.topMostViewController() as? UIAlertController {
            return
         } else {
            tabBarVC.topMostViewController().present(alert, animated: true, completion: nil)
         }
      }
   }
}

// MARK: - Notification Center Delegate Methods
extension AppDelegate: UNUserNotificationCenterDelegate {
   
   // run when the notification occurs and the app is in foreground
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([.alert, .sound]) 
   }
   
   // run when the notification occurs and the app is in the background
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo
      redirectToPage(userInfo: userInfo)
      
      if let alertIdentifer = userInfo[NotificationController.UserInfoDictionary.alertToTurnOff] as? String {
         if let alert = AlertController.shared.findAlertWith(identifier: alertIdentifer) {
            AlertController.shared.toggleAlert(alert: alert)
         }
      }
      
      completionHandler()
   }
   
   func redirectToPage(userInfo:[AnyHashable : Any]) {
      
      guard let pageType = userInfo[NotificationController.UserInfoDictionary.numberOfBikesKey] as? String else { print("Error grabbing alert info from local notification") ; return }
      
      switch pageType {
      // show table view controller
      case NotificationController.UserInfoDictionary.numberOfBikesValues.zero:
         if let tabBar = window?.rootViewController as? UITabBarController,
            let tabVC = tabBar.viewControllers,
            tabVC.count > 2 {
            tabBar.selectedViewController = tabVC[1]
            return
         }
      
      // show alert overlay view controller
      case NotificationController.UserInfoDictionary.numberOfBikesValues.some:
         
//         let delay = BikeStationController.shared.allBikeStations.isEmpty ? 1.5 : 0.5
         
         runBikeAnimationWith(userInfoDictionary: userInfo)
         
      default:
         print("Error. Enumeration above should be all inclusive.")
         return
      }
      
   }
   
   private func areMapsLoaded() -> Bool {
      return !BikeStationController.shared.allBikeStations.isEmpty
   }
   
   private func runBikeAnimationWith(userInfoDictionary: [AnyHashable : Any]) {
      if BikeStationController.shared.allBikeStations.isEmpty {
         // if the bikes haven't loaded yet, try again in half a second
         DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.runBikeAnimationWith(userInfoDictionary: userInfoDictionary)
         }
      } else {
         DispatchQueue.main.async {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let bikeStationOverlayVC = storyboard.instantiateViewController(withIdentifier: "ShowBikeStationInfo") as? BikeStationsNotificationOverlayViewController,
               let currentVC = self.window?.rootViewController?.topMostViewController() else  { return }
            
            let fromBikeStation = userInfoDictionary[NotificationController.UserInfoDictionary.fromBikeStationNameKey] as? String
            let toBikeStation = userInfoDictionary[NotificationController.UserInfoDictionary.toBikeStationNameKey] as? String
            
            bikeStationOverlayVC.fromBikeStationName = fromBikeStation
            bikeStationOverlayVC.toBikeStationName = toBikeStation
            
            bikeStationOverlayVC.modalPresentationStyle = .overCurrentContext
            currentVC.present(bikeStationOverlayVC, animated: false, completion: nil)
         }
      }
   }
   
}

// MARK: - Helper Methods
extension UIViewController {
   
   /// Find top most VC to present an error message on
   func topMostViewController() -> UIViewController {
      if self.presentedViewController == nil {
         return self
      }
      
      if let navigation = self.presentedViewController as? UINavigationController {
         return navigation.visibleViewController!.topMostViewController()
      }
      
      if let tab = self.presentedViewController as? UITabBarController {
         if let selectedTab = tab.selectedViewController {
            return selectedTab
         } else {
            return tab.topMostViewController()
         }
      }
      return self.presentedViewController!.topMostViewController()
   }
}

