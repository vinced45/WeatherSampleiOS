//
//  Plist.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

let plist = QBPlist()

struct Plist {
    
    enum PlistError: Error {
        case FileNotWritten
        case FileDoesNotExist
    }
    
    let name: String
    let bundle: Bundle?
    
    var sourcePath: String? {
        if bundle != nil {
            guard let path = bundle?.path(forResource: name, ofType: "plist") else { return .none }
            log.info("test bundle")
            return path
        } else {
            guard let path = Bundle.main.path(forResource: name, ofType: "plist") else { return .none }
            return path
        }
    }
    
    var destPath: String? {
        guard sourcePath != .none else { return .none }
        let dir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        return (dir as NSString).appendingPathComponent("\(name).plist")
    }
    
    init?(name: String, bundle: Bundle? = nil) {
        
        self.name = name
        self.bundle = bundle
        
        let fileManager = FileManager.default
        
        guard let source = sourcePath else { return nil }
        guard let destination = destPath else { return nil }
        guard fileManager.fileExists(atPath: source) else { return nil }
        
        if !fileManager.fileExists(atPath: destination) {
            
            do {
                try fileManager.copyItem(atPath: source, toPath: destination)
            } catch let error as NSError {
                log.verbose("Unable to copy file. ERROR: \(error.localizedDescription)")
                return nil
            }
        }
    }
    
    func getValuesInPlistFile() -> NSDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func getMutablePlistFile() -> NSMutableDictionary? {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            guard let dict = NSMutableDictionary(contentsOfFile: destPath!) else { return .none }
            return dict
        } else {
            return .none
        }
    }
    
    func addValuesToPlistFile(dictionary: NSDictionary) throws {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: destPath!) {
            if !dictionary.write(toFile: destPath!, atomically: false) {
                log.verbose("File not written successfully")
                throw PlistError.FileNotWritten
            }
        } else {
            throw PlistError.FileDoesNotExist
        }
    }
    
}

class QBPlist {
    //private init() {} //This prevents others from using the default '()' initializer for this class.
    
    var plistFileName: String!
    
    func file(_ name: String, bundle: Bundle? = nil) {
        if let _ = Plist(name: name, bundle: bundle) {
            plistFileName = name
            log.verbose("plist started")
        } else {
            log.error("error")
        }
    }
    
    func allItems() -> NSDictionary? {
        if let plist = Plist(name: plistFileName) {
            return plist.getValuesInPlistFile()
        }
        return nil
    }
    
    func add(key: String, value: AnyObject) {
        log.verbose("Starting to add item for key '\(key) with value '\(value)' . . .")
        if !alreadyExists(key: key) {
            if let plist = Plist(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict[key] = value
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                } catch {
                    log.verbose(error)
                }
                log.verbose("An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                log.verbose("\(plist.getValuesInPlistFile())")
            } else {
                log.verbose("Unable to get Plist")
            }
        } else {
            log.verbose("Item for key '\(key)' already exists. Not saving Item. Not overwriting value.")
        }
        
        
    }
    
    func remove(key: String) {
        log.verbose("Starting to remove item for key '\(key) . . .")
        if alreadyExists(key: key) {
            if let plist = Plist(name: plistFileName) {
                
                let dict = plist.getMutablePlistFile()!
                dict.removeObject(forKey: key)
                
                do {
                    try plist.addValuesToPlistFile(dictionary: dict)
                } catch {
                    log.verbose(error)
                }
                log.verbose("An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
                log.verbose("\(plist.getValuesInPlistFile())")
            } else {
                log.verbose("Unable to get Plist")
            }
        } else {
            log.verbose("Item for key '\(key)' does not exists. Remove canceled.")
        }
        
    }
    
    func removeAll() {
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            
            if !keys.isEmpty {
                dict.removeAllObjects()
            } else {
                log.verbose("Plist is already empty. Removal of all items canceled.")
            }
            
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
            } catch {
                log.verbose(error)
            }
            log.verbose("An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            log.verbose("\(plist.getValuesInPlistFile())")
        } else {
            log.verbose("Unable to get Plist")
        }
    }
    
    func save(value: AnyObject, forKey: String) {
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            if let dictValue = dict[forKey] {
                
                if type(of: value) != type(of: dictValue) {
                    log.verbose("WARNING: You are saving a \(type(of: value)) typed value into a \(type(of: dictValue)) typed value. Best practice is to save Int values to Int fields, String values to String fields etc.")
                }
                
                dict[forKey] = value
                
            }
            
            do {
                try plist.addValuesToPlistFile(dictionary: dict)
            } catch {
                log.verbose(error)
            }
            log.verbose("An Action has been performed. You can check if it went ok by taking a look at the current content of the plist file: ")
            log.verbose("\(plist.getValuesInPlistFile())")
        } else {
            log.verbose("Unable to get Plist")
        }
    }
    
    func getValue(key: String) -> AnyObject? {
        var value: AnyObject?
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            
            if !keys.isEmpty {
                
                for (_, element) in keys.enumerated() {
                    if element as? String == key {
                        log.verbose("Found the Item that we were looking for for key: [\(key)]")
                        value = dict[key]! as AnyObject?
                    } else {
                        log.verbose("This is Item with key '\(element)' and not the Item that we are looking for with key: \(key)")
                    }
                }
                
                if value != nil {
                    return value!
                } else {
                    log.verbose("WARNING: The Item for key '\(key)' does not exist! Please, check your spelling.")
                    return .none
                }
                
            } else {
                log.verbose("No Plist Item Found when searching for item with key: \(key). The Plist is Empty!")
                return .none
            }
            
        } else {
            log.verbose("Unable to get Plist")
            return .none
        }
        
    }
    
    /**
     Checks to see if a key already exist
     - Parameter: **key**    The key you are searching for
     - Returns: A boolean if it was bale to find it or not
     */
    func alreadyExists(key: String) -> Bool {
        var keyExists = false
        
        if let plist = Plist(name: plistFileName) {
            
            let dict = plist.getMutablePlistFile()!
            
            let keys = Array(dict.allKeys)
            
            if !keys.isEmpty {
                
                for (_, element) in keys.enumerated() {
                        if element as? String == key {
                        log.verbose("Checked if item exists and found it for key: [\(key)]")
                        keyExists = true
                    } else {
                        log.verbose("This is Element with key '\(element)' and not the Element that we are looking for with Key: \(key)")
                    }
                }
                
            } else {
                keyExists =  false
            }
            
        } else {
            keyExists = false
        }
        
        return keyExists
    }
    
}
