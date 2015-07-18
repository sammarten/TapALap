//
//  ViewController.swift
//  TapALap
//
//  Created by Marten,Sam on 5/29/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import UIKit
import HealthKit

class ViewController: UIViewController, UITableViewDataSource {
    
    var runs: [[NSObject: AnyObject]]? {
        get {
            let defaults = NSUserDefaults(suiteName: "group.com.sammarten.tapalap")!
            
            return defaults.objectForKey("Runs") as? [[NSObject: AnyObject]]
        }
    }
    
    lazy var distanceFormatter: NSLengthFormatter = {
        let distanceFormatter = NSLengthFormatter()
        distanceFormatter.numberFormatter.maximumSignificantDigits = 3
        return distanceFormatter
        }()
    
    lazy var runDateFormatter: NSDateFormatter = {
        let runDateFormatter = NSDateFormatter()
        runDateFormatter.dateStyle = .MediumStyle
        runDateFormatter.timeStyle = .NoStyle
        return runDateFormatter
        }()
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = runs?.count {
            return count
        }
        else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView,
        cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            let cellIdentifier = "RunCell"
            
            var cell: UITableViewCell? =
            tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as?
            UITableViewCell
            
            if cell == nil {
                cell = UITableViewCell(style: .Value1, reuseIdentifier: cellIdentifier)
            }
            
            if let runDictionary = runs?[indexPath.row] {
                cell?.textLabel?.text =
                    distanceFormatter.stringFromMeters(runDictionary["distance"] as!
                        Double)
                
                cell?.detailTextLabel?.text =
                    runDateFormatter.stringFromDate(runDictionary["startDate"] as!
                        NSDate)
            }
            
            return cell!
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        let healthStore = UIApplication.sharedApplication().app_delegate().healthStore
        
        let workoutType = HKObjectType.workoutType()
        
        let workoutAuthorizationStatus =
        healthStore.authorizationStatusForType(workoutType)
        
        let distanceType = HKQuantityType.quantityTypeForIdentifier(
            HKQuantityTypeIdentifierDistanceWalkingRunning)
        
        let distanceAuthorizationStatus =
        healthStore.authorizationStatusForType(distanceType)
        
        if workoutAuthorizationStatus != HKAuthorizationStatus.SharingAuthorized ||
            distanceAuthorizationStatus != HKAuthorizationStatus.SharingAuthorized {
                let typesToShare: Set = [workoutType, distanceType]
                
                healthStore.requestAuthorizationToShareTypes(typesToShare, readTypes: nil) {
                    success, error in
                    if success == false {
                        NSLog("Failed to authorize: \(error.description)")
                    }
                }
        }
    }
    
}
