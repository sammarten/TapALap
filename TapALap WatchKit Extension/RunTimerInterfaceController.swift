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
    
    func endRun() {
        let contexts: [AnyObject]?
        
        if let lapCount = laps?.count {
            let run = Run(distance: track.lapDistance * Double(lapCount), laps: laps!, startDate: startDate!)
            
            saveRunToUserDefaults(run)
            saveRunToHealthKit(run)
            
            contexts = [NSNull(), run]
        }
        else {
            contexts = nil
        }
        
        let names = ["GoRunning", "RunLog"]
        WKInterfaceController.reloadRootControllersWithNames(names, contexts: contexts)
    }
    
    func saveRunToHealthKit(run: Run) {
        let userInfo = ["RunToSave": run.dictionaryRepresentation()]
        
        WKInterfaceController.openParentApplication(userInfo) {
            replyInfo, error in
            if replyInfo != nil {
                self.handleReply(replyInfo)
            }
            else if let error = error {
                NSLog("Error in reply: %@", error.localizedDescription)
            }
        }
    }
    
    func handleReply(replyInfo: [NSObject: AnyObject]) {
        if let success = replyInfo["Success"] as? Bool where success == true {
            NSLog("Saved run to HealthKit")
        }
        else {
            NSLog("Couldn't save run!")
            
            if let replyError = replyInfo["Error"] as? String {
                NSLog("Error: " + replyError)
            }
        }
    }
    
    @IBAction func finishLapButtonPressed() {
        let totalDuration = NSDate().timeIntervalSinceDate(startDate!)
        let lapDuration = totalDuration - laps!.reduce(0, combine: +)
        
        laps!.append(lapDuration)
        
        updateDistanceLabel()
    }
    
    func saveRunToUserDefaults(run: Run) {
        let defaults = NSUserDefaults(suiteName: "group.com.pragprog.tapalap")
        
        if let defaults = defaults {
            var savedRuns = defaults.objectForKey("Runs") as? [[NSObject: AnyObject]]
            
            if savedRuns != nil {
                savedRuns!.append(run.dictionaryRepresentation())
            }
            else {
                savedRuns = [run.dictionaryRepresentation()]
            }
            
            defaults.setObject(savedRuns, forKey: "Runs")
            defaults.synchronize()
        }
    }
}
