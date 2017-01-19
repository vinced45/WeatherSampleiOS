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
import CoreLocation

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var topDetailLabel: UILabel!
    @IBOutlet weak var bottomDetailLabel: UILabel!
    @IBOutlet weak var iconLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    var weather: WeatherKit? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update(forecast: nil)
        locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        locationManager.delegate = self
        locationManager.requestLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {

        completionHandler(NCUpdateResult.newData)
    }
    
    @IBAction func openApp(_ sender: Any) {
        let url: URL? = URL(string: "weathersample:")!
        if let appurl = url {
            self.extensionContext!.open(appurl,
                                        completionHandler: nil)
        }
    }
    
}

// MARK: Methods
extension TodayViewController {
    func checkCurrentWeather(_ location: CLLocationCoordinate2D) {
        let weather = WeatherKit()
        weather.getForecast(location) { result in
            switch result {
            case let .success(forecast):
                print("forecast - \(forecast)")
                self.update(forecast: forecast)
            case let .error(error):
                print("error - \(error)")
            default:
                print("default")
            }
        }
    }
    
    func update(forecast: Forecast?) {
        if let forecast = forecast {
            DispatchQueue.main.async {
                self.nameLabel.text = forecast.city
                self.tempLabel.text = "\(Int(round(forecast.temp)))°"
                self.iconLabel.text = forecast.getEmoji()
                self.topDetailLabel.text = "UTC: \(forecast.timezone) ● Last Updated: \(forecast.updatedAt.shortStyle())"
                self.bottomDetailLabel.text = "Humidity: \(forecast.humidity)% ● Windspeed: \(forecast.windspeed) mph"
            }
        } else {
            DispatchQueue.main.async {
                self.nameLabel.text = "No conditions avaiable"
                self.tempLabel.text = "--°"
                self.iconLabel.text = ""
                self.topDetailLabel.text = ""
                self.bottomDetailLabel.text = ""
            }
        }
    }
}

// MARK: Location Delegate
extension TodayViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations[0]
        checkCurrentWeather((currentLocation?.coordinate)!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
