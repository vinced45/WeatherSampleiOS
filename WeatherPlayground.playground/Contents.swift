//: Playground - noun: a place where people can play

import UIKit
import WeatherKit

let weather = WeatherKit()
weather.getForecast("42.3601,-71.0589") { result in
    switch result {
    case let .success(f):
        print("timezone - \(f.timezone)")
    case let .error(error):
        print("error - \(error)")
    }
}