//
//  InterfaceController.swift
//  Watch Extension
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import WatchKit
import Foundation
import WeatherKit

class InterfaceController: WKInterfaceController {

    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        let weather = WeatherKit()
        weather.startLocation()
        
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
