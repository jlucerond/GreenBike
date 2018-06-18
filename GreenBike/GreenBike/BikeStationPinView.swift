//
//  BikeStationPinView.swift
//  GreenBike
//
//  Created by Joe Lucero on 3/24/18.
//  Copyright © 2018 Joe Lucero. All rights reserved.
//

import UIKit
import MapKit

class BikeStationPinView: MKAnnotationView {
   
   static let basicPinViewImage: UIImage = {
      let oversizedPinImage = UIImage(named: "LocationPin")!
      let resizedImage = resizePinImage(image: oversizedPinImage, newWidth: 45.0)!.tinted(fillWith: .primaryAppColor)!
      
      return resizedImage
   }()
   
   private func updateView() {
      let basicPinOutline = BikeStationPinView.basicPinViewImage.copy() as! UIImage
      let imageWithBikeNumber = self.addTextLabelTo(image: basicPinOutline)
      self.image = imageWithBikeNumber
   }
   
   required init(bikeStation: BikeStation, reuseIdentifier: String) {
      super.init(annotation: bikeStation, reuseIdentifier: reuseIdentifier)
      
      self.layer.shadowColor = UIColor.secondaryAppColor.cgColor
      self.layer.shadowRadius = 1
      self.layer.shadowOffset = CGSize(width: 2, height: -2)
      self.layer.shadowOpacity = 1

      updateView()
   }
   
   /// do not save annotations. will crash the app
   required init?(coder aDecoder: NSCoder) {
      fatalError("Should not be able to save annotation views")
   }
   
   private static func resizePinImage(image: UIImage?, newWidth: CGFloat) -> UIImage? {
      
      guard let image = image else { return nil }
      
      let scale = newWidth / image.size.width
      let newHeight = image.size.height * scale
      let newSize = CGSize(width: newWidth, height: newHeight)
      UIGraphicsBeginImageContext(newSize)
      let newCGRect = CGRect(x: 0, y: 0, width: newWidth, height: newHeight)
      image.draw(in: newCGRect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
   }
   
   private func addTextLabelTo(image: UIImage?) -> UIImage? {
      
      guard let unwrappedImage = image else { return nil }
      
      let size = unwrappedImage.size
      UIGraphicsBeginImageContext(size)
      
      let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      unwrappedImage.draw(in: areaSize, blendMode: CGBlendMode.overlay, alpha: 1.0)
      
      guard let bikeStation = annotation as? BikeStation else { return nil }

      let label = UILabel()
      
      let numberToShow = BikeStationController.shared.isMapShowingBikeNumbers ? bikeStation.freeBikes : bikeStation.emptySlots
      label.text = "\(numberToShow)"
      label.font = UIFont(name: "STHeitiSC-Medium", size: 20.0)
      label.textColor = UIColor.secondaryAppColor
      label.sizeToFit()

      let xValue = (areaSize.width - label.bounds.width) / 2
      let yValue = (areaSize.height - label.bounds.height) / 3
      let origin = CGPoint(x: xValue, y: yValue)
      let labelSize = CGRect(origin: origin, size: label.frame.size)

      label.drawText(in: labelSize)
      
      let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
   }

}

extension UIImage {
   func tinted(fillWith color: UIColor) -> UIImage? {
      defer { UIGraphicsEndImageContext() }
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      color.set()
      
      withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
      return UIGraphicsGetImageFromCurrentImageContext()
   }
   

}
