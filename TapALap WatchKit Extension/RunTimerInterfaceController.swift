//
//  RunTimerInterfaceController.swift
//  TapALap
//
//  Created by Marten,Sam on 5/29/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import WatchKit
import Foundation

class RunTimerInterfaceController: WKInterfaceController {

    @IBOutlet weak var distanceLabel: WKInterfaceLabel!
    let track:Track
    var distance: Double = 0
    
    var startDate: NSDate?
    var laps: [NSTimeInterval]?
    
    override init() {
        track = Track(name: "Track", lapDistance: 500.0)
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        
        if startDate == nil {
            startDate = NSDate()
            laps = []
        }
        
        updateDistanceLabel()
    }
    
    func updateDistanceLabel() {
        let lengthFormatter = NSLengthFormatter()
        
        lengthFormatter.numberFormatter.maximumSignificantDigits = 3
        
        let distance = track.lapDistance * Double(laps!.count)
        
        distanceLabel.setText(lengthFormatter.stringFromMeters(distance))
    }
    
    @IBAction func endRunButtonPressed() {
        endRun()
    }
    
    @IBAction func finishLapButtonPressed() {
        let totalDuration = NSDate().timeIntervalSinceDate(startDate!)
        let lapDuration = totalDuration - laps!.reduce(0, combine: +)
        
        laps!.append(lapDuration)
        
        updateDistanceLabel()
    }
    
    func endRun() {
        
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
