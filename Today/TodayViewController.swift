//
//  TodayViewController.swift
//  Today
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import UIKit
import NotificationCenter
import WeatherKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topDetailLabel: UILabel!
    @IBOutlet weak var bottomDetailLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
       
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        print("widget did load")
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        let weather = WeatherKit()
        weather.startLocation() { result in
            switch result {
            case let .success(forecast):
                print("success")
                DispatchQueue.main.sync {
                    self.nameLabel.text = forecast.city
                    self.tempLabel.text = "\(Int(round(forecast.temp)))°"
                    self.iconLabel.text = forecast.getEmoji()
                    self.topDetailLabel.text = "UTC: \(forecast.timezone) ● Last Updated: \(forecast.updatedAt.shortStyle())"
                    self.bottomDetailLabel.text = "Humidity: \(forecast.humidity)% ● Windspeed: \(forecast.windspeed) mph"
                    self.view.layoutIfNeeded()
                    completionHandler(NCUpdateResult.newData)
                }
            default:
                print("error")
            }
        }
    }
    
}
