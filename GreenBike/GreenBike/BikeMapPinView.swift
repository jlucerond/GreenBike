//
//  BikeMapPinView.swift
//  GreenBike
//
//  Created by Joe Lucero on 3/24/18.
//  Copyright © 2018 Joe Lucero. All rights reserved.
//

import UIKit
import MapKit

class BikeMapPinView: MKAnnotationView {
   
   override var annotation: MKAnnotation? {
      didSet {
         updateView()
      }
   }
   
//   override func prepareForReuse() {
//      self.image = nil
//   }
   
//   override func prepareForDisplay() {
//      self.image = nil
//   }
   
   func updateView() {
      guard let _ = annotation as? BikeStation else { return }
      
      let oversizedPinImage = UIImage(named: "LocationPin")
      let backgroundImage = resizePinImage(image: oversizedPinImage, newWidth: 45.0)?.tinted(fillWith: .secondaryAppColor)
      let resizedImage = resizePinImage(image: oversizedPinImage, newWidth: 40.0)
      let shadedImage = resizedImage?.tinted(fillWith: .primaryAppColor)
      let imageWithBikeNumber = addTextLabelTo(image: shadedImage)
      let combinedImages = overlapImages(backgroundImage: backgroundImage, foregroundImage: imageWithBikeNumber)
      self.image = combinedImages
   }
   
   required init(bikeStation: BikeStation, reuseIdentifier: String) {
      super.init(annotation: bikeStation, reuseIdentifier: reuseIdentifier)
      updateView()
   }
   
   /// do not save annotations. will crash the app
   required init?(coder aDecoder: NSCoder) {
      fatalError("Should not be able to save annotation views")
   }
   
   private func resizePinImage(image: UIImage?, newWidth: CGFloat) -> UIImage? {
      
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
      unwrappedImage.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: 1.0)
      
      guard let bikeStation = annotation as? BikeStation else { return nil }

      let label = UILabel()
      label.text = "\(bikeStation.freeBikes)"
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

   private func overlapImages(backgroundImage: UIImage?, foregroundImage: UIImage?) -> UIImage? {
      
      guard let backgroundImage = backgroundImage, let foregroundImage = foregroundImage else { return nil }
      
      let size = backgroundImage.size
      UIGraphicsBeginImageContext(size)
      
      let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      backgroundImage.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: 1.0)
      
      let xValue = (areaSize.width - foregroundImage.size.width) / 2
      let yValue = ((areaSize.height - foregroundImage.size.height) / 2) - 1
      let origin = CGPoint(x: xValue, y: yValue)
      let foregroundRect = CGRect(origin: origin, size: foregroundImage.size)
      
      foregroundImage.draw(in: foregroundRect)
      
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
