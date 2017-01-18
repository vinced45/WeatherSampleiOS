//
//  WeatherKitTests.swift
//  WeatherKitTests
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import XCTest
@testable import WeatherKit

class WeatherKitTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testForeast() {
        let expectation = self.expectation(description: "Should be able to get forecast for given location")
        var forecast = Forecast()
        let weather = WeatherKit()
        weather.getForecast("42.3601,-71.0589") { result in
            switch result {
            case let .success(f):
                forecast = f
                print("forecast - \(f)")
                expectation.fulfill()
            case let .error(error):
                XCTFail("error - \(error)")
            }
        }
        
        waitForExpectations(timeout: 60) { error in
            XCTAssertEqual(forecast.timezone, "America/New_York")
            XCTAssertNil(error, "Got an error getting forecast - \(error.debugDescription)")
        }
    }
    
}
