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

public class LocationManager: NSObject {
    
    // MARK: - Properties
    
    let queue = DispatchQueue(label: "Location Queue")
    
    var manager: CLLocationManager = CLLocationManager()
    var locationType: LocationType = .always
    var monitors: [AnyHashable : Bool]?
    
    public typealias LocationClosure = (_ result: LocationResult) -> Void
    var locationCallback: LocationClosure!
    
    // MARK: - Enums
    
    public enum LocationType {
        case location
        case inUse
        case always
    }
    
    public enum LocationResult {
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
    
    public enum MonitorType {
        case location
        #if os(iOS)
        case significant
        case region(CLRegion)
        case beacon(CLBeaconRegion)
        case heading
        case visit
        #endif
    }
    
    // MARK: - Public Methods
    
    public func start(_ monitorType: MonitorType = .location, result: LocationClosure? = nil) {
        if let callback = result {
            locationCallback = callback
        }
        
        manager.delegate = self
        
        if !requestAuth() {
            locationCallback(LocationResult.error(WeatherError.permissions()))
            return
        }
        #if os(iOS)
            switch monitorType {
            case .location:
                manager.startUpdatingLocation()
            case .significant:
                manager.startMonitoringSignificantLocationChanges()
            case let .region(region):
                manager.startMonitoring(for: region)
            case let .beacon(region):
                manager.startRangingBeacons(in: region)
            case .heading:
                manager.startUpdatingHeading()
            case .visit:
                manager.startMonitoringVisits()
            }
        #else
            switch monitorType {
            case .location:
                manager.startUpdatingLocation()
            }
        #endif
    }
    
    public func stop(_ monitorType: MonitorType = .location) {
        manager.delegate = self
        #if os(iOS)
            switch monitorType {
            case .location:
                manager.startUpdatingLocation()
            case .significant:
                manager.startMonitoringSignificantLocationChanges()
            case let .region(region):
                manager.startMonitoring(for: region)
            case let .beacon(region):
                manager.startRangingBeacons(in: region)
            case .heading:
                manager.startUpdatingHeading()
            case .visit:
                manager.startMonitoringVisits()
            }
        #else
            switch monitorType {
            case .location:
                manager.startUpdatingLocation()
            }
        #endif
    }
    
    public func isMonitoring(_ monitorType: MonitorType = .location) -> Bool {
        manager.delegate = self
        #if os(iOS)
            switch monitorType {
            case .location:
                return monitors!["location"] ?? false
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
            }
        #endif
    }
    
    public func listen(_ result: @escaping LocationClosure) {
        locationCallback = result
        manager.delegate = self
        
        if !requestAuth() {
            locationCallback(LocationResult.error(WeatherError.permissions()))
            return
        }
    }
    
    public func search(location: CLLocation, result: @escaping LocationClosure) {
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
    
    public func search(address: String, result: @escaping LocationClosure) {
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
        manager.delegate = self
        plist.file("Info")
        switch locationType {
        case .location:
            if plist.alreadyExists(key: Permissions.location.rawValue) {
                manager.requestLocation()
                return true
            }
            return false
        case .inUse:
            if plist.alreadyExists(key: Permissions.locationInUse.rawValue) {
                manager.requestWhenInUseAuthorization()
                return true
            }
            return false
        case .always:
            if plist.alreadyExists(key: Permissions.locationAlways.rawValue) {
                manager.requestAlwaysAuthorization()
                return true
            }
            return false
        }
    }
}

// MARK: - CLLocationManager Delegates
extension LocationManager: CLLocationManagerDelegate {
    #if os(iOS)
    public func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        locationCallback(LocationResult.heading(newHeading))
    }
    
    public func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        locationCallback(LocationResult.regionState(state, region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        locationCallback(LocationResult.beacons(beacons, region))
    }
    
    public func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        locationCallback(LocationResult.error(WeatherError.default()))
    }
    
    public func locationManager(_ manager: CLLocationManager, didVisit visit: CLVisit) {
        locationCallback(LocationResult.visit(visit))
    }
    
    public func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        locationCallback(LocationResult.enterRegion(region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        locationCallback(LocationResult.exitRegion(region))
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        locationCallback(LocationResult.monitor(region))
    }
    #endif
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationCallback(LocationResult.locations(locations))
    }
    
    public func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        locationCallback(LocationResult.authorization(status))
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationCallback(LocationResult.error(WeatherError.init(errorType: error)))
    }
}
