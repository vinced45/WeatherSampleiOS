//
//  Date+Extensions.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

public extension Date {
    
    public func shortStyle() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .short
        dateformatter.timeStyle = .short
        
        return dateformatter.string(from: self)
    }
    
    public func mediumStyle() -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateStyle = .medium
        dateformatter.timeStyle = .medium
        
        return dateformatter.string(from: self)
    }
    
    public func format(_ format: String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = format
        
        return dateformatter.string(from: self)
    }
}
