//
//  RealmFetchable.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation
import RealmSwift

public protocol RealmFetchable {

    func startFetch<T: Object>(_ results: Results<T>) -> NotificationToken
    func stopFetch(_ token: NotificationToken)
}
#if os(iOS) || os(tvOS)
    public extension RealmFetchable where Self: UITableViewController {
        
        public func startFetch<T: Object>(_ results: Results<T>) -> NotificationToken {
            let token = results.addNotificationBlock { [weak self] (changes: RealmCollectionChange) in
                guard let tableView = self?.tableView else { return }
                switch changes {
                case .initial:
                    // Results are now populated and can be accessed without blocking the UI
                    tableView.reloadData()
                    break
                case .update(_, _, _, _):
                    // Query results have changed, so apply them to the UITableView
                    tableView.reloadData()
                    break
                case .error(let error):
                    // An error occurred while opening the Realm file on the background worker thread
                    fatalError("\(error)")
                    break
                }
            }
            return token
        }
        
        public func stopFetch(_ token: NotificationToken) {
            token.stop()
        }
    }

#endif
