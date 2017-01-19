//
//  Logging.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

let `log` = LogManager()

class LogManager: NSObject {
    
    // MARK: Properties
    
    /// The log level for project. Default is `debug` which is all
    var logLevel: LogType = .debug
    
    // MARK: Enums
    
    /**
     The type of logs that you can have
     
     ```
     case verbose
     case debug
     case info
     case warning
     case error
     ```
     */
    enum LogType: Int {
        /// Not important logging
        case verbose = -1
        /// Something you want to debug
        case debug = 0
        /// A parameter that you are looking at
        case info = 1
        /// A warning you've encountered
        case warning = 2
        /// An error that has happened
        case error = 3
        
        /// The name that you want displayed for the `logType`
        var name: String {
            switch self {
            case .verbose:
                return "💜 VERBOSE"
            case .debug:
                return "💚 DEBUG"
            case .info:
                return "💙 INFO"
            case .warning:
                return "💛 WARNING"
            case .error:
                return "❤️ ERROR"
            }
        }
    }
    
    // MARK: Methods
    
    /**
     Verbose error logging
     
     - Parameter: **object**    The object that you want logged
     */
    func verbose<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(object, .verbose, file, function, line)
    }
    
    /**
     Debug logging
     
     - Parameter: **object**    The object that you want logged
     */
    func debug<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(object, .debug, file, function, line)
    }
    
    /**
     Info logging
     
     - Parameter: **object**    The object that you want logged
     */
    func info<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(object, .info, file, function, line)
    }
    
    /**
     Warning logging
     
     - Parameter: **object**    The object that you want logged
     */
    func warning<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(object, .warning, file, function, line)
    }
    
    /**
     Error logging
     
     - Parameter: **object**    The object that you want logged
     */
    func error<T>(_ object: @autoclosure () -> T, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        log(object, .error, file, function, line)
    }
    
    func saveLog() {
        // let pathForLog = Quick.file
        
        //freopen(pathForLog.cString(usingEncoding: NSASCIIStringEncoding)!, "a+", stderr)
    }
}

internal extension LogManager {
    /**
     Prints the filename, function name, line number and textual representation of `object` and a newline character into
     the standard output if the build setting for "Active Complilation Conditions" (SWIFT_ACTIVE_COMPILATION_CONDITIONS) defines `DEBUG`.
     The current thread is a prefix on the output. <UI> for the main thread, <BG> for anything else.
     Only the first parameter needs to be passed to this funtion.
     The textual representation is obtained from the `object` using `String(reflecting:)` which works for _any_ type.
     To provide a custom format for the output make your object conform to `CustomDebugStringConvertible` and provide your format in
     the `debugDescription` parameter. **this needs to have the `-D DEBUG` flag set in the “Other Swift Flags” section under Debug.**
     
     - Parameter: **logType**   The log level at which to display. If the logtype is lower than `logLevel` var, it will not be displayed.
     - Parameter: **object**    The object whose textual representation will be printed. If this is an expression, it is lazily evaluated.
     - Parameter: **file**      The name of the file, defaults to the current file without the ".swift" extension.
     - Parameter: **function**  The name of the function, defaults to the function within which the call is made.
     - Parameter: **line**      The line number, defaults to the line number within the file that the call is made.
     */
    internal func log<T>(_ object: @autoclosure () -> T, _ logType: LogType = .debug, _ file: String = #file, _ function: String = #function, _ line: Int = #line) {
        if logType.rawValue >= logLevel.rawValue {
            let value = object()
            let fileURL = NSURL(string: file)?.lastPathComponent ?? "Unknown file"
            let queue = Thread.isMainThread ? "MainQueue" : currentQueueName()
            print("\(logType.name) <\(queue)> \(fileURL) \(function) \(line): " + String(reflecting: value))
        }
    }
    
    internal func currentQueueName() -> String {
        let name = __dispatch_queue_get_label(nil)
        return String(cString: name, encoding: .utf8) ?? "Unknown Queue"
    }
}
