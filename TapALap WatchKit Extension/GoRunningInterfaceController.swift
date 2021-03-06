//
//  InterfaceController.swift
//  TapALap WatchKit Extension
//
//  Created by Marten,Sam on 5/29/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import WatchKit
import Foundation


class GoRunningInterfaceController: WKInterfaceController {

    @IBAction func trackButtonPressed() {
        presentControllerWithName("TrackConfiguration", context: nil)
    }
    
    @IBAction func startRunButtonPressed() {
        // let names = ["RunTimerInterfaceController"]
        let names = ["RunTimer"]
        WKInterfaceController.reloadRootControllersWithNames(names, contexts: nil)
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
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
