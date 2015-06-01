//
//  Run.swift
//  TapALap
//
//  Created by Marten,Sam on 5/30/15.
//  Copyright (c) 2015 Sam Marten. All rights reserved.
//

import Foundation

class Run {
    
    let distance: Double // in meters
    let laps: [NSTimeInterval]
    let startDate: NSDate
    
    init(distance: Double, laps: [NSTimeInterval], startDate: NSDate) {
        self.distance = distance
        self.laps = laps
        self.startDate = startDate
    }
    
    var duration: NSTimeInterval {
        return laps.reduce(0, combine: +)
    }
    
    var pace: NSTimeInterval {
        return duration / NSTimeInterval(laps.count)
    }
}