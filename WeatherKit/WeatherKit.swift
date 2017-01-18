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
    let darkSkyKey = "00b0517b03ef04728fc9e98058d92ca0"
    let baseURL = "https://api.darksky.net/forecast"
    
    // MARK: Enums
    public enum WeatherResult {
        case success(Forecast)
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
    public func getForecast(_ location: String, completion: @escaping WeatherClosure) {
        network.call("\(baseURL)/\(darkSkyKey)/\(location)") { result in
            switch result {
            case let .downloadCompleted(_, data):
                let json = JSON(data: data)
                completion(WeatherResult.success(self.createForecast(json)))
            case let .error(error):
                completion(WeatherResult.error(error))
            default:
                completion(WeatherResult.error(WeatherError.default()))
            }
        }
    }
    
    /**
     Get all the saved forecasts
     
     - Returns: Array of `Forecast` objects
     */
    public func getSavedForecast() -> Results<Forecast> {
        return realm.query(Forecast.self)!
    }
    
    /**
     Saves the given forecast to the database
     
     - Parameter: **forecast**    The forecast that will be saved to the database
     */
    public func save(forecast: Forecast) {
        realm.add([forecast])
    }
    
    /**
     Deletes the given forecast from the database
     
     - Parameter: **forecast**    The forecast that will be deleted from the database
     */
    public func delete(forecast: Forecast) {
        realm.delete(Forecast.self, id: forecast.id)
    }
}

extension WeatherKit {
    internal func createForecast(_ json: JSON) -> Forecast {
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
        return forecast
    }
}
