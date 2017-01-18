//
//  Enums.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

public enum Permissions: String {
    /**
     All the plist permissions that can be granted
     
     */
    case appleMusic = "NSAppleMusicUsageDescription"
    case bluetooth = "NSBluetoothPeripheralUsageDescription"
    case calendar = "NSCalendarsUsageDescription"
    case camera = "NSCameraUsageDescription"
    case contacts = "NSContactsUsageDescription"
    case healthShare = "NSHealthShareUsageDescription"
    case healthUpdate = "NSHealthUpdateUsageDescription"
    case homeKit = "NSHomeKitUsageDescription"
    case location = "NSLocationUsageDescription"
    case locationAlways = "NSLocationAlwaysUsageDescription"
    case locationInUse = "NSLocationWhenInUseUsageDescription"
    case microphone = "NSMicrophoneUsageDescription"
    case motion = "NSMotionUsageDescription"
    case photos = "NSPhotoLibraryUsageDescription"
    case reminders = "NSRemindersUsageDescription"
    case siri = "NSSiriUsageDescription"
    case speech = "NSSpeechRecognitionUsageDescription"
    case tvProvider = "NSVideoSubscriberAccountUsageDescription"
    
    static let allValues = [appleMusic, bluetooth, calendar, camera, contacts, healthShare, healthUpdate, homeKit, location, locationAlways, locationInUse, microphone, motion, photos, reminders, siri, speech, tvProvider]
}
