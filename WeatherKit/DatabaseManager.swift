//
//  RealmManager.swift
//  Pods
//
//  Created by Vince on 1/18/17.
//
//

import Foundation
import RealmSwift

let db = DatabaseManager()

class DatabaseManager: NSObject {
    
    // MARK: Properties
    
    let queue = DispatchQueue(label: "Realm Queue")
    var displayRealmUrl = true
    var realmUrl: URL?

    
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
            
            guard let realm = self.getRealm() else {
                completion?(RealmResult.error(WeatherError.default()))
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
            
            guard let realm = self.getRealm() else {
                completion?(RealmResult.error(WeatherError.default()))
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
            
            guard let realm = self.getRealm() else {
                completion?(RealmResult.error(WeatherError.default()))
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
        
        guard let realm = getRealm() else { return nil }
        let results = realm.objects(T.self).filter(predicate).sorted(byProperty: sort, ascending: ascending)
        return results
        //}
    }
}

// MARK: - Private
extension DatabaseManager {
    internal func getRealm() -> Realm? {

        var config = Realm.Configuration()
        if displayRealmUrl {
            displayRealmUrl = false
            print("realm is at \(config.fileURL)")
        }

        
        config.schemaVersion = 1
        config.migrationBlock = { (migration, oldSchemaVersion) in
            if oldSchemaVersion < 1 {
                
            }
        }
        
        config.objectTypes = [Forecast.self]

        do {
            let realm = try Realm(configuration: config)
            return realm
        } catch {
            return nil
        }
    }
}
