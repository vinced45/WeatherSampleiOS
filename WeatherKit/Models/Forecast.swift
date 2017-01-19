//
//  Forecast.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation
import RealmSwift

@objc
public class Forecast: Object {

    public dynamic var id = ""
    public dynamic var timezone = ""
    public dynamic var city = ""
    public dynamic var icon = ""
    public dynamic var temp = 0.0
    public dynamic var windspeed = 0.0
    public dynamic var humidity = 0.0
    public dynamic var lat = 0.0
    public dynamic var lon = 0.0
    public dynamic var summary = ""
    public dynamic var updatedAt = Date()
    public dynamic var isCurrentLocation: Bool = false
    
    override public static func primaryKey() -> String? {
        return "id"
    }
    
    public func getEmoji() -> String? {
        switch self.icon {
        case "clear-day":
            return "☀️"
        case "clear-night":
            return "🌙"
        case "rain":
            return "🌧"
        case "snow":
            return "🌨"
        case "wind":
            return "💨"
        case "fog":
            return "🌫"
        case "cloudy":
            return "☁️"
        case "partly-cloudy-day":
            return "🌤"
        case "partky-cloudy-night":
            return "🌥"
        case "hail":
            return "❄️"
        case "thunderstorm":
            return "⛈"
        case "tornado":
            return "🌪"
        default:
            return "☀️"
        }
    }
}
