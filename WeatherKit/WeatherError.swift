//
//  WeatherError.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

/**
 Used to error data.
 */
public class WeatherError: NSObject, Error {
    
    // MARK: - Properties
    
    /**
     The localized error description.
     */
    public let localizedDescription: String
    /**
     The error code.
     */
    public let code: Int
    
    // MARK: - Lifecycle
    
    /**
     The initializer.
     
     - parameter error: String
     */
    public init(error: String) {
        localizedDescription = error
        code = 0
    }
    public init(string: String, code: Int) {
        localizedDescription = string
        self.code = code
    }
    public init(errorType: Error) {
        localizedDescription = errorType.localizedDescription
        if let nserror = errorType as NSError? {
            code = nserror.code
        } else {
            code = 0
        }
    }
}

protocol NSErrorConvertible {
    func toError() -> Error
}

extension WeatherError: NSErrorConvertible {
    public func toError() -> Error {
        return NSError(domain: "QuickBuildKit", code: code, userInfo: [NSLocalizedDescriptionKey: localizedDescription]) as Error
    }
}

public extension WeatherError {
    public static func `default`(code: Int = 0) -> WeatherError {
        return WeatherError(string: "Please contact 45 Bit Code.", code: code)
    }
    public static func realmInsufficientAddressSpace() -> WeatherError {
        return WeatherError(string: "There is insufficient available address space.", code: 0)
    }
    public static func permissions() -> WeatherError {
        return WeatherError(string: "You don't have your info.plist permissions setup", code: 0)
    }
    override var description: String {
        get {
            return toError().localizedDescription
        }
    }
}

