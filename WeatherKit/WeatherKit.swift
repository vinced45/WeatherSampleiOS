//
//  WeatherKit.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation
import CoreLocation
import SwiftyJSON
import RealmSwift

@objc
public class WeatherKit: NSObject {
    
    // MARK: Properties
    public var realmPath: String?
    
    let darkSkyKey = "00b0517b03ef04728fc9e98058d92ca0"
    let baseURL = "https://api.darksky.net/forecast"
    
    
    // MARK: Enums
    public enum WeatherResult {
        case success(Forecast)
        case cities([CLPlacemark])
        case error(Error)
    }
    
    public typealias WeatherClosure = (_ result: WeatherResult) -> Void
    
    // MARK: Methods
    /**
     This method will get forecast info for a given location
     
     - Parameter: **location**    The coordinates of the locatins searching
     - Returns: Forcast Object
     
     - Remark: https://api.darksky.net/forecast/00b0517b03ef04728fc9e98058d92ca0/42.3601,-71.0589
     */
    public func getForecast(_ location: CLLocationCoordinate2D, completion: @escaping WeatherClosure) {
        network.call("\(baseURL)/\(darkSkyKey)/\(location.latitude),\(location.longitude)") { result in
            switch result {
            case let .downloadCompleted(_, data):
                let json = JSON(data: data)
                self.createForecast(json) { forecastResult in
                    switch forecastResult {
                    case let .success(f):
                        completion(WeatherResult.success(f))
                    default:
                        completion(WeatherResult.error(WeatherError.default()))
                    }
                }
            case let .error(error):
                completion(WeatherResult.error(error))
            default:
                completion(WeatherResult.error(WeatherError.default()))
            }
        }
    }
    
    /**
     Start monitoring for location services. Once it starts monitoring location it will get forecast info and save to database

     */
    public func startLocation(_ completion: WeatherClosure? = nil) {
        location.start() { result in
            switch result {
            case let .locations(locations):
                self.getForecast((locations.first?.coordinate)!) { result in
                    switch result {
                    case let .success(forecast):
                        forecast.id = "Current"
                        forecast.isCurrentLocation = true
                        if let closure = completion {
                            closure(WeatherResult.success(forecast))
                        }
                        location.stop()
                        self.save(forecast: forecast)
                    case let .error(error):
                        log.error(error)
                        if let closure = completion {
                            closure(WeatherResult.error(error))
                        }
                        location.stop()
                    default:
                        log.error(WeatherError.default())
                        if let closure = completion {
                                closure(WeatherResult.error(WeatherError.default()))
                        }
                    }
                }
            default:
                log.verbose("Not monitoring location")
            }
        }
    }
    
    /**
     Lets you search for placemarkes based off of address
     
     - Parameter: **address**    The address you are searching for
     - Parameter: **completion**    The completion block
     */
    public func search(address: String, completion: @escaping WeatherClosure) {
        location.search(address: address) { result in
            switch result {
            case let .geocode(placemarks):
                completion(WeatherResult.cities(placemarks))
            default:
                completion(WeatherResult.error(WeatherError.default()))
            }
        }
    }
    
    /**
     Get all the saved forecasts
     
     - Returns: Array of `Forecast` objects
     */
    public func getSavedForecast() -> Results<Forecast>? {
        return db.query(Forecast.self, sort: "id")
    }
    
    /**
     Saves the given forecast to the database
     
     - Parameter: **forecast**    The forecast that will be saved to the database
     */
    public func save(forecast: Forecast) {
        db.add([forecast])
    }
    
    /**
     Deletes the given forecast from the database
     
     - Parameter: **forecast**    The forecast that will be deleted from the database
     */
    public func delete(forecast: Forecast) {
        db.delete(Forecast.self, id: forecast.id)
    }
}

extension WeatherKit {
    internal func createForecast(_ json: JSON, completion: @escaping WeatherClosure) {
        let forecast = Forecast()
        forecast.timezone = json["timezone"].stringValue
        forecast.icon = json["currently"]["icon"].stringValue
        forecast.windspeed = json["currently"]["windSpeed"].doubleValue
        forecast.temp = json["currently"]["temperature"].doubleValue
        forecast.humidity = json["currently"]["humidity"].doubleValue
        forecast.summary = json["currently"]["summary"].stringValue
        forecast.updatedAt = Date(timeIntervalSince1970: TimeInterval(json["currently"]["time"].intValue))
        forecast.lat = json["latitude"].doubleValue
        forecast.lon = json["longitude"].doubleValue
        
        let locManager = LocationManager()
        let location = CLLocation(latitude: forecast.lat, longitude: forecast.lon)
        locManager.search(location: location) { result in
            switch result {
            case let .geocode(placemarks):
                if let city = placemarks.first?.locality {
                    forecast.id = city
                    forecast.city = city
                }
                completion(WeatherResult.success(forecast))
            default:
                completion(WeatherResult.error(WeatherError.default()))
            }
        }
    }
}
