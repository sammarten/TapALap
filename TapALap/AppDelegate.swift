//
//  AppDelegate.swift
//  TapALap
//
//  Created by Marten,Sam on 5/29/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import UIKit
import HealthKit


import UIKit
import HealthKit

extension UIApplication {
    func app_delegate() -> AppDelegate {
        return self.delegate as! AppDelegate
    }
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    lazy var healthStore = HKHealthStore()
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        return true
    }
    
    func application(application: UIApplication,
        handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?,
        reply: (([NSObject : AnyObject]!) -> Void)!) {
            let backgroundID = application.beginBackgroundTaskWithExpirationHandler {
                self.replyToWatchKitRequest(false,
                    error: nil,
                    reply: reply,
                    backgroundTaskIdentifier: UIBackgroundTaskInvalid)
            }
            
            if let userInfo = userInfo as? [String: AnyObject],
                runToSave = userInfo["RunToSave"] as? [NSObject: AnyObject] {
                    saveRunToHealthKit(runToSave: runToSave,
                        reply: reply,
                        backgroundTaskIdentifier: backgroundID)
            }
            else {
                replyToWatchKitRequest(false,
                    error: nil,
                    reply: reply,
                    backgroundTaskIdentifier: backgroundID)
            }
    }
    
    func saveRunToHealthKit(runToSave run: [NSObject: AnyObject],
        reply: (([NSObject : AnyObject]!) -> Void)!,
        backgroundTaskIdentifier identifier: UIBackgroundTaskIdentifier) {
            if (!HKHealthStore.isHealthDataAvailable()) {
                replyToWatchKitRequest(false,
                    error: nil,
                    reply: reply,
                    backgroundTaskIdentifier: identifier)
                return
            }
            
            let runDistance = HKQuantity(unit: HKUnit.meterUnit(),
                doubleValue: run["distance"] as! Double)
            
            let startDate = run["startDate"] as! NSDate
            let duration = run["duration"] as! NSTimeInterval
            let endDate = NSDate(timeInterval: duration, sinceDate: startDate)
            
            let workout = HKWorkout(activityType: .Running,
                startDate: startDate,
                endDate: endDate,
                duration: duration,
                totalEnergyBurned: nil,
                totalDistance: runDistance,
                metadata: nil)
            
            healthStore.saveObject(workout) {
                success, error in
                if success {
                    // Samples can only be added after you save.
                    self.addLapsFromDictionary(runToSave: run,
                        toWorkout: workout,
                        runDistance: runDistance,
                        reply: reply,
                        backgroundTaskIdentifier: identifier)
                }
                else {
                    self.replyToWatchKitRequest(false,
                        error: nil,
                        reply: reply,
                        backgroundTaskIdentifier: identifier)
                }
            }
    }
    
    func addLapsFromDictionary(runToSave run: [NSObject: AnyObject],
        toWorkout workout: HKWorkout,
        runDistance: HKQuantity,
        reply: (([NSObject : AnyObject]!) -> Void)!,
        backgroundTaskIdentifier identifier: UIBackgroundTaskIdentifier) {
            if let laps = run["laps"] as? [Double] where laps.count > 0 {
                var samples = [HKQuantitySample]()
                
                let totalDistance = run["distance"] as! Double
                
                let distancePerLap = HKQuantity(unit: HKUnit.meterUnit(),
                    doubleValue: totalDistance / Double(laps.count))
                
                var startDate = run["startDate"] as! NSDate
                
                let distanceType = HKQuantityType.quantityTypeForIdentifier (
                    HKQuantityTypeIdentifierDistanceWalkingRunning)
                
                for duration in laps {
                    let endDate = NSDate(timeInterval: duration, sinceDate: startDate)
                    
                    let sample = HKQuantitySample(type: distanceType,
                        quantity: distancePerLap,
                        startDate: startDate,
                        endDate: endDate)
                    
                    samples.append(sample)
                    
                    // The next lap begins when this one ends.
                    startDate = endDate
                }
                
                healthStore.addSamples(samples, toWorkout: workout) {
                    success, error in
                    self.replyToWatchKitRequest(success,
                        error: error,
                        reply: reply,
                        backgroundTaskIdentifier: identifier)
                }
            }
            else {
                replyToWatchKitRequest(false,
                    error: nil,
                    reply: reply,
                    backgroundTaskIdentifier: identifier)
            }
    }
    
    func replyToWatchKitRequest(success: Bool,
        error: NSError?,
        reply: (([NSObject : AnyObject]!) -> Void)!,
        backgroundTaskIdentifier identifier: UIBackgroundTaskIdentifier) {
            var replyInfo = [NSObject: AnyObject]()
            
            replyInfo["Success"] = success
            
            if let error = error {
                replyInfo["Error"] = error.localizedDescription
            }
            
            reply(replyInfo)
            
            if identifier != UIBackgroundTaskInvalid {
                // Wait two seconds before ending the background task to give WatchKit
                // time to communicate with the device.
                let twoSecondsFromNow = dispatch_time(DISPATCH_TIME_NOW,
                    Int64(2 * NSEC_PER_SEC))
                
                dispatch_after(twoSecondsFromNow, dispatch_get_main_queue()) { 
                    UIApplication.sharedApplication().endBackgroundTask(identifier) 
                }
            }
    }
}




//@UIApplicationMain
//class AppDelegate: UIResponder, UIApplicationDelegate {
//
//    var window: UIWindow?
//    lazy var healthStore = HKHealthStore()
//
//    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
//        let backgroundID = application.beginBackgroundTaskWithExpirationHandler {
//            self.replyToWatchKitRequest(false,
//                error: nil,
//                reply: reply,
//                backgroundTaskIdentifier: UIBackgroundTaskInvalid)
//        }
//        
//        if let userInfo = userInfo as? [String: AnyObject]?, runToSave = userInfo["RunToSave"] as? [NSObject: AnyObject] {
//            saveRunToHealthKit(runToSave: runToSave,
//                reply: reply,
//                backgroundTaskIdentifier: backgroundID)
//        }
//        else {
//            replyToWatchKitRequest(false,
//                error: nil,
//                reply: reply,
//                backgroundTaskIdentifier: backgroundID)
//        }
//    }
//    
//    func replyToWatchKitRequest(success: Bool,
//        error: NSError?,
//        reply: (([NSObject : AnyObject]!) -> Void)!,
//        backgroundTaskIdentifier identifier: UIBackgroundTaskIdentifier) {
//
//        var replyInfo = [NSObject: AnyObject]()
//
//        replyInfo["Success"] = success
//        
//        if let error = error {
//            replyInfo["Error"] = error.localizedDescription
//        }
//        
//        reply(replyInfo)
//        
//        if identifier != UIBackgroundTaskInvalid {
//            // Wait two seconds before ending the backgroud task to give WatchKit
//            // time to communicate with the device
//            let twoSecondsFromNow = dispatch_time(DISPATCH_TIME_NOW, Int64(2 * NSEC_PER_SEC)
//            
//            dispatch_after(twoSecondsFromNow, dispatch_get_main_queue()) {
//                UIApplication.sharedApplication().endBackgroundTask(identifier)
//            }
//        }
//    }
//
//    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//        // Override point for customization after application launch.
//        return true
//    }
//
//    func applicationWillResignActive(application: UIApplication) {
//        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
//        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
//    }
//
//    func applicationDidEnterBackground(application: UIApplication) {
//        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
//        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    }
//
//    func applicationWillEnterForeground(application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//    }
//
//    func applicationDidBecomeActive(application: UIApplication) {
//        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//    }
//
//    func applicationWillTerminate(application: UIApplication) {
//        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
//    }
//
//
//}
//
