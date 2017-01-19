//
//  LocationManager.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation
import CoreLocation

let location = LocationManager()

class LocationManager: NSObject {
    
    // MARK: - Properties
    
    let queue = DispatchQueue(label: "Location Queue")
    
    var manager: CLLocationManager?
    var locationType: LocationType = .always
    var monitors: [AnyHashable : Bool]?
    
    typealias LocationClosure = (_ result: LocationResult) -> Void
    var locationCallback: LocationClosure!
    
    // MARK: - Enums
    
    enum LocationType {
        case location
        case inUse
        case always
    }
    
    enum LocationResult {
        #if os(iOS)
        case heading(CLHeading)
        case beacons([CLBeacon], CLBeaconRegion)
        case visit(CLVisit)
        case regionState(CLRegionState, CLRegion)
        case exitRegion(CLRegion)
        case enterRegion(CLRegion)
        case monitor(CLRegion)
        #endif
        case authorization(CLAuthorizationStatus)
        case locations([CLLocation])
        case geocode([CLPlacemark])
        case error(WeatherError)
    }
    
    enum MonitorType {
        case location
        case locationOneTime
        #if os(iOS)
        case significant
        case region(CLRegion)
        case beacon(CLBeaconRegion)
        case heading
        case visit
        #endif
    }
    
    // MARK: - Methods
    
    func start(_ monitorType: MonitorType = .locationOneTime, result: LocationClosure? = nil) {
        if let callback = result {
            locationCallback = callback
        }
        manager = CLLocationManager()
        
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyKilometer
        
        
        if !requestAuth() {
            locationCallback(LocationResult.error(WeatherError.permissions()))
            return
        }
        #if os(iOS)
            switch monitorType {
            case .location:
                manager?.startUpdatingLocation()
            case .locationOneTime:
                manager?.requestLocation()
            case .significant:
                manager?.startMonitoringSignificantLocationChanges()
            case let .region(region):
                manager?.startMonitoring(for: region)
            case let .beacon(region):
                manager?.startRangingBeacons(in: region)
            case .heading:
                manager?.startUpdatingHeading()
            case .visit:
                manager?.startMonitoringVisits()
            }
        #else
            switch monitorType {
            case .location:
                manager?.startUpdatingLocation()
            case .locationOneTime:
                manager?.requestLocation()
            }
        #endif
    }
    
    func stop(_ monitorType: MonitorType = .location) {
        manager?.delegate = self
        #if os(iOS)
            switch monitorType {
            case .location:
                manager?.stopUpdatingLocation()
            case .locationOneTime:
                manager?.stopUpdatingLocation()
            case .significant:
                manager?.stopMonitoringSignificantLocationChanges()
            case let .region(region):
                manager?.stopMonitoring(for: region)
            case let .beacon(region):
                manager?.stopRangingBeacons(in: region)
            case .heading:
                manager?.stopUpdatingHeading()
            case .visit:
                manager?.stopMonitoringVisits()
            }
        #else
            switch monitorType {
            case .location:
                manager?.stopUpdatingLocation()
            case .locationOneTime:
                manager?.stopUpdatingLocation()
            }
        #endif
        
        manager = nil
    }
    
    func isMonitoring(_ monitorType: MonitorType = .location) -> Bool {
        manager?.delegate = self
        #if os(iOS)
            switch monitorType {
            case .location:
                return monitors!["location"] ?? false
            case .locationOneTime:
                return monitors!["locationOneTime"] ?? false
            case .significant:
                return monitors!["significant"] ?? false
            case .region:
                return monitors!["region"] ?? false
            case .beacon:
                return monitors!["beacon"] ?? false
            case .heading:
                return monitors!["heading"] ?? false
            case .visit:
                return monitors!["visit"] ?? false
            }
        #else
            switch monitorType {
            case .location:
                return monitors!["location"] ?? false
            case .locationOneTime:
                return monitors!["locationOneTime"] ?? false
            }
        #endif
    }
    
    func listen(_ result: @escaping LocationClosure) {
        locationCallback = result
        manager?.delegate = self
        
        if !requestAuth() {
            locationCallback(LocationResult.error(WeatherError.permissions()))
            return
        }
    }
    
    func search(location: CLLocation, result: @escaping LocationClosure) {
        queue.async {
            log.debug("")
            
            self.locationCallback = result
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { placemarks, error in
                if let err = error {
                    self.locationCallback(LocationResult.error(WeatherError.init(errorType: err)))
                } else {
                    self.locationCallback(LocationResult.geocode(placemarks!))
                }
            }
        }
    }
    
    func search(address: String, result: @escaping LocationClosure) {
        queue.async {
            log.debug("")
            
            self.locationCallback = result
            let geocoder = CLGeocoder()
            geocoder.geocodeAddressString(address) { placemarks, error in
                if let err = error {
                    self.locationCallback(LocationResult.error(WeatherError.init(errorType: err)))
                } else {
                    self.locationCallback(LocationResult.geocode(placemarks!))
                }
            }
        }
    }
}

// MARK: - Internal Methods
extension LocationManager {
    internal func requestAuth() -> Bool {
        manager?.delegate = self
        plist.file("Info")
        switch locationType {
        case .location:
            if plist.alreadyExists(key: Permissions.location.rawValue) {
                manager?.requestLocation()
                return true
            }
            return false
        case .inUse:
            if plist.alreadyExists(key: Permissions.locationInUse.rawValue) {
                manager?.requestWhenInUseAuthorization()
                return true
            }
            return false
        case .always:
            if plist.alreadyExists(key: Permissions.locationAlways.rawValue) {
                manager?.requestAlwaysAuthorization()
                return true
            }
            return false
        }
    }
}

// MARK: - CLLocationManager Delegates
extension LocationManager: CLLocationManagerDelegate {
    #if os(iOS)
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationCallback(LocationResult.heading(newHeading))
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        locationCallback(LocationResult.regionState(state, region))
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        locationCallback(LocationResult.beacons(beacons, region))
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        locationCallback(LocationResult.error(WeatherError.default()))
    }
    
    func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        locationCallback(LocationResult.visit(visit))
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationCallback(LocationResult.enterRegion(region))
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationCallback(LocationResult.exitRegion(region))
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationCallback(LocationResult.monitor(region))
    }
    #endif
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCallback(LocationResult.locations(locations))
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationCallback(LocationResult.authorization(status))
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCallback(LocationResult.error(WeatherError.init(errorType: error)))
    }
}
