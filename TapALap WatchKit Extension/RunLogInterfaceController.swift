//
//  RunLogInterfaceController.swift
//  TapALap
//
//  Created by Marten,Sam on 5/30/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import WatchKit
import Foundation


class RunLogInterfaceController: WKInterfaceController {

    @IBOutlet weak var runTable: WKInterfaceTable!

    var runs: [Run]?
    
    lazy var dateFormatter: NSDateFormatter = {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        return dateFormatter
        }()
    
    lazy var distanceFormatter = NSLengthFormatter()
    
    lazy var durationFormatter: NSDateComponentsFormatter = {
        let dateComponentsFormatter = NSDateComponentsFormatter()
        dateComponentsFormatter.unitsStyle = .Positional
        return dateComponentsFormatter
        }()
    
    override init() {
        let duration: NSTimeInterval = 30.0 * 60.0
        let laps = 5
        let lapDuration = duration / NSTimeInterval(laps)
        
        let run = Run(distance: 5000, laps: Array(count: laps, repeatedValue: lapDuration), startDate: NSDate())
        
        runs = Array(count: 5, repeatedValue: run)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        if let run = context as? Run {
            becomeCurrentPage()
            
            runs?.insert(run, atIndex: 0)
            
            runTable.insertRowsAtIndexes(NSIndexSet(index: 0), withRowType: "RunRow")
            
            if let rowc = runTable.rowControllerAtIndex(0) as? RunLogRowController {
                configureRow(rowc, forRun: run)
            }
        }
    }

    override func willActivate() {
        super.willActivate()
        
        if runs == nil {
            return
        }
        
        runTable.setNumberOfRows(runs!.count, withRowType: "RunRow")
        
        for i in 0 ..< runTable.numberOfRows {
            if let rowc = runTable.rowControllerAtIndex(i) as? RunLogRowController {
                configureRow(rowc, forRun: runs![i])
            }
        }        
    }
    
    func configureRow(rowController: RunLogRowController, forRun run: Run) {
        rowController.dateFormatter = dateFormatter
        rowController.distanceFormatter = distanceFormatter
        rowController.durationFormatter = durationFormatter
        
        rowController.configure(date: run.startDate,
            distance: run.distance,
            duration: run.duration)
    }
    
    override func contextForSegueWithIdentifier(segueIdentifier: String, inTable table: WKInterfaceTable, rowIndex: Int) -> AnyObject? {
        var context: AnyObject?
    
        if segueIdentifier == "RunDetails" {
            context = runs![rowIndex]
        }
    
        return context
    }

    override func table(table: WKInterfaceTable, didSelectRowAtIndex rowIndex: Int) {
        NSLog("User tapped on row %d", rowIndex)
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
