//
//  RunDetailsViewController.swift
//  TapALap
//
//  Created by Marten,Sam on 5/31/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import WatchKit
import Foundation

class LapDetailRowController: NSObject {
    
    @IBOutlet weak var lapNumberLabel: WKInterfaceLabel!
    @IBOutlet weak var lapDurationLabel: WKInterfaceLabel!
    
    lazy var durationFormatter: NSDateComponentsFormatter = {
        let durationFormatter = NSDateComponentsFormatter()
        durationFormatter.unitsStyle = .Positional
        return durationFormatter
        }()
    
    func configureForLap(lap: NSTimeInterval, atIndex index: UInt) {
        lapDurationLabel.setText(durationFormatter.stringFromTimeInterval(lap))
        lapNumberLabel.setText("\(index + 1)")
    }
}

class RunDetailsViewController: WKInterfaceController {

    @IBOutlet weak var runDateLabel: WKInterfaceLabel!
    @IBOutlet weak var runDistanceLabel: WKInterfaceLabel!
    @IBOutlet weak var runPaceLabel: WKInterfaceLabel!
    @IBOutlet weak var lapsTable: WKInterfaceTable!
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        dateFormatter.timeStyle = .NoStyle
        return dateFormatter
    }()
    
    func configureForRun(run: Run) {
        runDateLabel.setText(dateFormatter.stringFromDate(run.startDate))
        
        let lengthFormatter = NSLengthFormatter()
        runDistanceLabel.setText(lengthFormatter.stringFromMeters(run.distance))
        
        lapsTable.setNumberOfRows(run.laps.count, withRowType: "LapRow")
        
        for i in 0 ..< lapsTable.numberOfRows {
            if let rowController = lapsTable.rowControllerAtIndex(i) as? LapDetailRowController {
                let lapTime: NSTimeInterval = run.laps[i]
                rowController.configureForLap(lapTime, atIndex: UInt(i))
            }
        }
        
        let paceFormatter = NSDateComponentsFormatter()
        runPaceLabel.setText(paceFormatter.stringFromTimeInterval(run.pace))
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let run = context as? Run {
            configureForRun(run)
        }
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}

