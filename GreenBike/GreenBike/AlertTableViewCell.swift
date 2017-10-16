//
//  AlertTableViewCell.swift
//  GreenBike
//
//  Created by Joe Lucero on 10/11/17.
//  Copyright © 2017 Joe Lucero. All rights reserved.
//

import UIKit

protocol AlertTableViewCellDelegate {
   func didToggleOnOffSwitch()
}

class AlertTableViewCell: UITableViewCell {
   // MARK: - IBOutlets
   @IBOutlet weak var timeLabel: UILabel!
   @IBOutlet weak var amPmLabel: UILabel!
   @IBOutlet weak var fromStationLabel: UILabel!
   @IBOutlet weak var toStationLabel: UILabel!
   @IBOutlet weak var repeatsLabel: UILabel!
   @IBOutlet weak var onOffSwitch: UISwitch!
   
   // MARK: - Variables
   var alert: Alert? {
      didSet {
         updateViews()
      }
   }
   
   var dateFormatter: DateFormatter {
      let dateFormatter = DateFormatter()
      dateFormatter.timeStyle = .short
      
      return dateFormatter
   }
   
   var delegate: AlertTableViewCellDelegate?

   // MARK: - IBActions
   @IBAction func onOffSwitchToggled(_ sender: UISwitch) {
      alert?.toggleOnOff()
      delegate?.didToggleOnOffSwitch()
   }
   
}

extension AlertTableViewCell {
   func updateViews() {
      guard let alert = alert else { return }
      if let valueAndSymbol = dateFormatter.valueAndSymbol(date: alert.timeOfDay) {
         timeLabel.text = valueAndSymbol.number
         amPmLabel.text = valueAndSymbol.amPmSymbol
      } else {
         // this should not run ever
         timeLabel.text = dateFormatter.string(from: alert.timeOfDay)
         amPmLabel.text = ""
      }
      
      if let fromBikeStationName = alert.fromBikeStation?.name {
         fromStationLabel.text = "→ \(fromBikeStationName)"
      } else {
         fromStationLabel.text = ""
      }
      
      if let toBikeStationName = alert.toBikeStation?.name {
         toStationLabel.text = "← \(toBikeStationName)"
      } else {
         toStationLabel.text = ""
      }
      
      if !alert.weeklySchedule.daysThatAlertShouldRepeat.isEmpty {
         repeatsLabel.text = "↻ \(alert.weeklySchedule.stringOfDaysThatAlertShouldRepeat)"
      } else {
         repeatsLabel.text = alert.weeklySchedule.stringOfDaysThatAlertShouldRepeat
      }
      
   }
   
}

extension DateFormatter {
   func valueAndSymbol(date : Date) -> (number: String, amPmSymbol: String)? {
      let dateFormatter = DateFormatter()
      dateFormatter.timeStyle = .short
      
      let dateAsString = dateFormatter.string(from: date)
      let twoWords = dateAsString.components(separatedBy: " ")
      print(twoWords)
      guard twoWords.count == 2 else { print("trouble with time") ; return nil }
      
      return (twoWords[0], twoWords[1])
   }
}


