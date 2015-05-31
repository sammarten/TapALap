//
//  RunLogRowController.swift
//  TapALap
//
//  Created by Marten,Sam on 5/30/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import Foundation
import WatchKit

class RunLogRowController : NSObject {
    @IBOutlet weak var dateLabel: WKInterfaceLabel!
    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    @IBOutlet weak var durationLabel: WKInterfaceLabel!
    
    var dateFormatter: NSDateFormatter?
    var distanceFormatter: NSLengthFormatter?
    var durationFormatter: NSDateComponentsFormatter?
    
    func configure(#date: NSDate, distance: Double, duration: NSTimeInterval) {
        dateLabel.setText(dateFormatter?.stringFromDate(date))
        distanceLabel.setText(distanceFormatter?.stringFromMeters(distance))
        durationLabel.setText(durationFormatter?.stringFromTimeInterval(duration))
    }
}
