//
//  AddLocationViewController.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import UIKit
import CoreLocation
import WeatherKit

class AddLocationViewController: UITableViewController {
    
    @IBOutlet weak var searchbar: UISearchBar!
    
    var placemarks: [CLPlacemark]?
    let weather: WeatherKit = WeatherKit()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchbar.delegate = self
        self.tableView.registerCell(WeatherTableViewCell.self)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchbar.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true)
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let count = placemarks?.count {
            return count
        }
        return 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherTableViewCell", for: indexPath) as! WeatherTableViewCell
        
        if let placemark: CLPlacemark = placemarks?[indexPath.row] {
            DispatchQueue.main.async {
                cell.nameLabel?.text = "\(placemark.locality ?? ""), \(placemark.country ?? "")"
            }
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if let placemark: CLPlacemark = placemarks?[indexPath.row] {
            weather.getForecast((placemark.location?.coordinate)!) { result in
                switch result {
                case let .success(forecast):
                    self.weather.save(forecast: forecast)
                    self.cancel(self)
                default:
                    print("error getting forecast in addVC")
                }
            }
        }
    }
    
}

// MARK: SearchBar Deleagate
extension AddLocationViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        weather.search(address: searchText) { result in
            switch result {
            case let .cities(places):
                self.placemarks = places
                self.tableView.reloadData()
            default:
                print("no cities came back")
            }
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        print("search clicked")
    }
}
