//
//  WeatherViewController.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import UIKit
import WeatherKit
import RealmSwift
import CoreLocation
import BRYXBanner

class WeatherViewController: UITableViewController, RealmFetchable {
    
    let weather: WeatherKit = WeatherKit()
    
    var savedLocations: Results<Forecast>?
    var currentLocation: Results<Forecast>?
    
    var currentLocationtoken: NotificationToken? = nil
    var savedLocationstoken: NotificationToken? = nil
    
    var refresh: UIRefreshControl!
    
    var timer: Timer?
    
    let MTRed = #colorLiteral(red: 0.8378046751, green: 0.01143348496, blue: 0.112503089, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Weather Sample", comment: "app name")
        self.tableView.registerCell(WeatherTableViewCell.self)
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        setupPullToRefresh()
        
        SSASwiftReachability.sharedManager?.startMonitoring()
        // MARK: Listen For Network Reachability Changes
        NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityStatusChanged(notification:)), name: NSNotification.Name(rawValue: SSAReachabilityDidChangeNotification), object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        updateConditions()
        startTimer() // Default time is 5 minutes to refresh weather conditions
        startFetches()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
        stopFetches()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let locations = savedLocations {
            return (section == 0) ? 1 : locations.count
        }
        return (section == 0) ? 1 : 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (section == 0) ? NSLocalizedString("Current Location", comment: "current") :
            NSLocalizedString("Saved Locations", comment: "locations")
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80.0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        if indexPath.section == 0 {
            if let forecast = currentLocation?.first {
                cell = update(cell: cell, forecast: forecast)
            } else {
                cell = update(cell: cell, forecast: nil)
            }
        } else {
            if let forecast = savedLocations?[indexPath.row] {
                cell = update(cell: cell, forecast: forecast)
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return (indexPath.section == 0) ? false : true
    }
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete && indexPath.section == 1 {
            if let forecast = savedLocations?[indexPath.row] {
                weather.delete(forecast: forecast)
            }
            
        }
    }
}

// MARK: Actions
extension WeatherViewController {
    func startFetches() {
        currentLocation = weather.getSavedForecast()?.filter("id = 'Current'")
        if let results = currentLocation{
            currentLocationtoken = startFetch(results)
        }
        
        savedLocations = weather.getSavedForecast()?.filter("id <> 'Current'")
        if let results = savedLocations {
            savedLocationstoken = startFetch(results)
        }
    }
    
    func stopFetches() {
        if let token = currentLocationtoken {
            stopFetch(token)
        }
        
        if let token = savedLocationstoken {
            stopFetch(token)
        }
    }
    
    func startTimer(refreshTime: TimeInterval = 300) {
        timer = Timer.scheduledTimer(timeInterval: refreshTime, target: self, selector: #selector(updateConditions), userInfo: nil, repeats: true)
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func updateConditions() {
        if let results = weather.getSavedForecast() {
            for forecast in results {
                let loc = CLLocation(latitude: forecast.lat, longitude: forecast.lon)
                weather.getForecast(loc.coordinate) { result in
                    switch result {
                    case let .success(forecast):
                        self.weather.save(forecast: forecast)
                    default:
                        print("error updating conditions")
                    }
                }
            }
        }
        weather.startLocation() { result in
            switch result {
            case let .error(error):
                print("location error - \(error)")
            default:
                print("update conditions default")
            }
        }
        refresh?.endRefreshing()
    }
    
    func setupPullToRefresh() {
        refresh = UIRefreshControl()
        refresh.attributedTitle = NSAttributedString(string: "Pull to update")
        refresh?.addTarget(self, action: #selector(updateConditions), for: .valueChanged)
        self.tableView.addSubview(refresh)
    }
    
    func update(cell: WeatherTableViewCell, forecast: Forecast?) -> WeatherTableViewCell {
        if let forecast = forecast {
            DispatchQueue.main.async {
                cell.nameLabel.text = forecast.city
                cell.tempLabel.text = "\(Int(round(forecast.temp)))°"
                cell.iconLabel.text = forecast.getEmoji()
                cell.topDetailLabel.text = "UTC: \(forecast.timezone) ● Last Updated: \(forecast.updatedAt.shortStyle())"
                cell.bottomDetailLabel.text = "Humidity: \(forecast.humidity)% ● Windspeed: \(forecast.windspeed) mph"
            }
        } else {
            DispatchQueue.main.async {
                cell.nameLabel.text = "No conditions avaiable"
                cell.tempLabel.text = "--°"
                cell.iconLabel.text = ""
                cell.topDetailLabel.text = ""
                cell.bottomDetailLabel.text = ""
            }
        }
        
        return cell
    }
}

// MARK: Reachability Methods
extension WeatherViewController {
    func reachabilityStatusChanged(notification: NSNotification) {
        if let info = notification.userInfo {
            if let status = info[SSAReachabilityNotificationStatusItem] as? String {
                switch status {
                case "unknown", "notReachable":
                    showNoInternetBanner()
                default:
                    print("reachable")
                }
            }
        }
    }
    
    func showNoInternetBanner() {
        DispatchQueue.main.async {
            let banner = Banner(title: "No Internet", subtitle: "Please check your connection and try again", image:nil, backgroundColor: self.MTRed)
            banner.dismissesOnTap = true
            banner.show(duration: 3.0)
        }
    }
}
