
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
      scheduleLocalNotification()
      
      NotificationCenter.default.addObserver(self,
                                             selector: #selector(showSorry),
                                             name: ConstantNotificationNotices.apiNotWorking,
                                             object: nil)

      return true
   }
   
   
   
   // MARK: - Error Handling
   /// Show error
   @objc func showSorry() {
      guard let window = window else { return }
      
      let alert = UIAlertController(title: "Uh-oh", message: "Network error.\n\nThis is usually the result of a bad network signal or server issues.", preferredStyle: .alert)
      let action = UIAlertAction(title: "Darn", style: .default, handler: nil)
      alert.addAction(action)
      
      DispatchQueue.main.async {
         guard let tabBarVC = window.rootViewController else { return }
         tabBarVC.topMostViewController().present(alert, animated: true, completion: nil)
      }
   }
}

// MARK: - Notification Practice (move elsewhere once fixed)
extension AppDelegate: UNUserNotificationCenterDelegate {
   
   // run when the notification occurs and app is in foreground
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler([UNNotificationPresentationOptions.alert, UNNotificationPresentationOptions.sound])
   }
   
   // run when the notification occurs an the app is in the background
   func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
      let userInfo = response.notification.request.content.userInfo
      redirectToPage(userInfo: userInfo)
      completionHandler()
   }
   
   // FIXME: - Refactor this later
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
         let storyboard = UIStoryboard(name: "Main", bundle: nil)
         guard let bikeStationOverlayVC = storyboard.instantiateViewController(withIdentifier: "ShowOneBikeStationInfo") as? BikeStationsNotificationOverlayViewController,
            let currentVC = self.window?.rootViewController?.topMostViewController() else  { return }
         
         let fromBikeStation = userInfo[NotificationController.UserInfoDictionary.fromBikeStationNameKey] as? String
         let toBikeStation = userInfo[NotificationController.UserInfoDictionary.toBikeStationNameKey] as? String
         
         bikeStationOverlayVC.fromBikeStationName = fromBikeStation
         bikeStationOverlayVC.toBikeStationName = toBikeStation

         bikeStationOverlayVC.modalPresentationStyle = .overFullScreen
         currentVC.present(bikeStationOverlayVC, animated: false, completion: nil)
         
      default:
         print("Error. Enumeration above should be all inclusive.")
         return
      }
      
   }
   
   // FIXME: - I should eventually change this to take an alert parameter and take out the bikestation names inside
   func scheduleLocalNotification(){
      let fakeAlert = Alert(isOn: true, timeOfDay: AlertTime(hour: 7, minute: 30), fromBikeStation: nil, toBikeStation: nil, weeklySchedule: AlertWeek())
      
      var userInfoDictionary = [NotificationController.UserInfoDictionary.numberOfBikesKey : NotificationController.UserInfoDictionary.numberOfBikesValues.some]
      
      if let fromBikeStation = fakeAlert.fromBikeStation {
         userInfoDictionary[NotificationController.UserInfoDictionary.fromBikeStationNameKey] = fromBikeStation.name
      }
      if let toBikeStation = fakeAlert.toBikeStation {
         userInfoDictionary[NotificationController.UserInfoDictionary.toBikeStationNameKey] = toBikeStation.name
      }
      
      // FIXME: - Take this out later. Only used for testing purposes.
      userInfoDictionary[NotificationController.UserInfoDictionary.fromBikeStationNameKey] = "Key Bank Station"
      
      userInfoDictionary[NotificationController.UserInfoDictionary.toBikeStationNameKey] = "Rocky Mountain Power Station "
      
      // FIXME: - End of comment
      
      let content = UNMutableNotificationContent()
      content.title = "Title"
      content.userInfo = userInfoDictionary
      
      let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
      let request = UNNotificationRequest(identifier: "test", content: content, trigger: trigger)
      UNUserNotificationCenter.current().add(request) { (error) in
         print("notification scheduled for 5 seconds from now")
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
            return selectedTab.topMostViewController()
         }
         return tab.topMostViewController()
      }
      return self.presentedViewController!.topMostViewController()
   }
}

