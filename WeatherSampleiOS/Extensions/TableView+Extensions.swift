//
//  TableView+Extensions.swift
//  WeatherSampleiOS
//
//  Created by Vince on 1/18/17.
//  Copyright © 2017 Vince Davis. All rights reserved.
//

import Foundation

#if os(iOS) || os(tvOS)
    import UIKit
    
    public extension UITableView {
        
        public func registerCell<T: UITableViewCell>(_: T.Type) {
            register(T.self, forCellReuseIdentifier: NSStringFromClass(T.self))
        }
        
        public func registerNib<T: UITableViewCell>(_: T.Type) {
            let nib = UINib(nibName: NSStringFromClass(T.self), bundle: nil)
            register(nib, forCellReuseIdentifier: NSStringFromClass(T.self))
        }
        
        public func cell<T: UITableViewCell>(_: T.Type, indexPath: IndexPath) -> T {
            guard let cell = dequeueReusableCell(withIdentifier: NSStringFromClass(T.self), for: indexPath) as? T else {
                fatalError("Could not dequeue cell with identifier: \(NSStringFromClass(T.self))")
            }
            return cell
        }
    }
#endif
