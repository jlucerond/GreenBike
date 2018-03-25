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

   var bikeStation: BikeStation?
   
   required init(bikeStation: BikeStation, reuseIdentifier: String) {
      self.bikeStation = bikeStation
      super.init(annotation: bikeStation, reuseIdentifier: reuseIdentifier)
      let oversizedPinImage = UIImage(named: "LocationPin")
      let resizedImage = resizePinImage(image: oversizedPinImage, newWidth: 40.0)
      let firstTint = resizedImage?.tinted(with: UIColor.primaryAppColor)
      // fill
      let imageWithBikeNumber = addTextLabelTo(image: firstTint)
      self.image = imageWithBikeNumber
      
      
      // add another image on top of this
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
   
//   private func addBikeNumber(to image: UIImage?) -> UIImage? {
//      guard let unwrappedImage = image,
//         let numberOfBikes = bikeStation?.freeBikes else { return image }
//
//      let imageView = UIImageView(image: unwrappedImage)
//      let pinImage = unwrappedImage
//
//      let cgRect = CGRect()
//      let textLabel = UILabel(frame: cgRect)
//      textLabel.text = "\(numberOfBikes)"
//      textLabel.sizeToFit()
//      textLabel.translatesAutoresizingMaskIntoConstraints = false
//      imageView.translatesAutoresizingMaskIntoConstraints = false
//      imageView.addSubview(textLabel)
//      textLabel.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
//      textLabel.centerYAnchor.constraint(equalTo: imageView.centerYAnchor).isActive = true
//
//      let size = unwrappedImage.size
//      UIGraphicsBeginImageContext(size)
//
//      let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
//      pinImage.draw(in: areaSize)
//
//      textLabel.drawText(in: areaSize)
////      textLabel!.drawInRect(areaSize, blendMode: kCGBlendModeNormal, alpha: 0.8)
//
//      let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
//      UIGraphicsEndImageContext()
//
//      return newImage
//   }
   
   private func addTextLabelTo(image: UIImage?) -> UIImage? {
      
      guard let unwrappedImage = image else { return nil }
      
      let size = unwrappedImage.size
      UIGraphicsBeginImageContext(size)
      
      let areaSize = CGRect(x: 0, y: 0, width: size.width, height: size.height)
      unwrappedImage.draw(in: areaSize, blendMode: CGBlendMode.normal, alpha: 0.9)
      
      let freeBikesString = String(bikeStation!.freeBikes)
      let label = UILabel()
      label.text = freeBikesString
      label.textColor = UIColor.secondaryAppColor
      label.sizeToFit()
      
      let xValue = (areaSize.width - label.bounds.width) / 2
      let yValue = (areaSize.height - label.bounds.height) / 3
      let origin = CGPoint(x: xValue, y: yValue)
      let labelSize = CGRect(origin: origin, size: label.frame.size)
      
      label.drawText(in: labelSize)
      //      textLabel!.drawInRect(areaSize, blendMode: kCGBlendModeNormal, alpha: 0.8)
      
      let newImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
   }
}

extension UIImage {
   func tinted(with color: UIColor) -> UIImage? {
      defer { UIGraphicsEndImageContext() }
      UIGraphicsBeginImageContextWithOptions(size, false, scale)
      color.set()
      withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
      return UIGraphicsGetImageFromCurrentImageContext()
   }
}
