//
//  RealmManager.swift
//  Pods
//
//  Created by Vince on 1/18/17.
//
//

import Foundation
import RealmSwift

let realm = RealmManager()

class RealmManager: NSObject {
    
    // MARK: Properties
    
    let queue = DispatchQueue(label: "Realm Queue")
    var displayRealmUrl = true
    var realmUrl: URL?
    
    var realmPath: String?
    
    var migrationBlock: MigrationBlock?
    var schemaVersion: UInt64 = 0
    var objects: [Object.Type]?
    
    enum RealmResult {
        case success
        case error(Error)
        case noResults
    }
    
    typealias QBRealmClosure = (_ result: RealmResult) -> Void
    var realmCallback: QBRealmClosure!
    
    // MARK: Methods
    
    func add(_ objects: [Object], update: Bool = true, path: String = "", completion: QBRealmClosure? = nil) {
        queue.async {
            log.debug("")
            
            let realmDirectory: String = (path.isEmpty) ? self.realmPath! : path
            let (realmOptional, error) = self.getRealmWithError(realmDirectory)
            guard let realm = realmOptional else {
                completion?(RealmResult.error(error!))
                return
            }
            do {
                try realm.write {
                    realm.add(objects, update: update)
                    completion?(RealmResult.success)
                }
            } catch {
                completion?(RealmResult.error(WeatherError.default()))
            }
        }
    }
    
    func update<T: Object>(_ object: T.Type, id: String, values: [String: Any], path: String = "", completion: QBRealmClosure? = nil) {
        queue.async {
            log.debug("")
            
            let realmDirectory: String = (path.isEmpty) ? self.realmPath! : path
            let (realmOptional, error) = self.getRealmWithError(realmDirectory)
            guard let realm = realmOptional else {
                completion?(RealmResult.error(error!))
                return
            }
            
            let results = realm.objects(T.self).filter("id = '\(id)'")
            if results.isEmpty {
                completion?(RealmResult.noResults)
                return
            }
            
            do {
                try realm.write {
                    for (key, value) in values {
                        results.setValue(value, forKey: key)
                    }
                    completion?(RealmResult.success)
                }
            } catch {
                completion?(RealmResult.error(WeatherError.default()))
            }
        }
    }
    
    func delete<T: Object>(_ object: T.Type, id: String, path: String = "", completion: QBRealmClosure? = nil) {
        queue.async {
            log.debug("")
            
            let realmDirectory: String = (path.isEmpty) ? self.realmPath! : path
            let (realmOptional, error) = self.getRealmWithError(realmDirectory)
            guard let realm = realmOptional else {
                completion?(RealmResult.error(error!))
                return
            }
            let results = realm.objects(T.self).filter("id = '\(id)'")
            do {
                try realm.write {
                    realm.delete(results)
                    completion?(RealmResult.success)
                }
            } catch {
                completion?(RealmResult.error(WeatherError.default()))
            }
        }
    }
    
    func query<T: Object>(_ object: T.Type, predicate: NSPredicate = NSPredicate(format: "TRUEPREDICATE"), sort: String = "id", ascending: Bool = true, path: String = "") -> Results<T>? {
        //queue.async {
        log.debug("")
        
        let realmDirectory: String = (path.isEmpty) ? self.realmPath! : path
        let (realmOptional, _) = self.getRealmWithError(realmDirectory)
        guard let realm = realmOptional else { return nil }
        let results = realm.objects(T.self).filter(predicate).sorted(byProperty: sort, ascending: ascending)
        return results
        //}
    }
    
    // MARK: Migration
    
    internal func internalSchemaVersion() -> UInt64 {
        return 1
    }
    
    // swiftlint:disable cyclomatic_complexity
    internal func internalMigrationBlock() -> MigrationBlock {
        return { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                
            }
        }
    }
}

// MARK: - Private
extension RealmManager {
    internal func getRealmWithError(_ path: String = "") -> (Realm?, Swift.Error?) {
        let tempUrl = URL(string: path)
        guard var url = tempUrl else {
            return (nil, WeatherError.default())
        }
        
        url.appendPathComponent("default.realm")
        realmUrl = url
        
        if displayRealmUrl {
            displayRealmUrl = false
            print("realm is at \(realmUrl!)")
        }
        
        var config = Realm.Configuration()
        config.fileURL = realmUrl
        
        config.schemaVersion = (schemaVersion > 0) ? schemaVersion : internalSchemaVersion()
        config.migrationBlock = (migrationBlock != nil) ? migrationBlock : internalMigrationBlock()
        
        if let objectTypes = objects {
            config.objectTypes = objectTypes
        }
        
        do {
            let realm = try Realm(configuration: config)
            return (realm, nil)
        } catch {
            return (nil, WeatherError.default())
        }
    }
}
