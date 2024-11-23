//
//  Dictionary.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-23.
//

import Foundation

public
extension Dictionary where Value: Comparable {
    
    /// Sets the greater of an existing value or the passed value for a key.
    @inlinable
    mutating func setMax(key: Key, value: Value) {
        if let existing = self[key] {
            if existing < value {
                self[key] = value
            }
        } else {
            self[key] = value
        }
    }
    
}
