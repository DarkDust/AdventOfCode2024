//
//  SymbolMap.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-23.
//

import Foundation

/// A simple helper to map arbitrary values to integers, starting at zero.
public
struct SymbolMap<Value: Hashable> {
    
    @usableFromInline internal
    var map: [Value: Int] = [:]
    
    @usableFromInline internal
    var values: [Value] = []
    
    
    public
    init() { }
    
    
    /// Add a value to the map.
    @discardableResult public
    mutating func add(_ value: Value) -> Int {
        if let index = map[value] {
            return index
        }
        
        let index = map.count
        map[value] = index
        values.append(value)
        return index
    }
    
    
    /// Get the value associated with an index.
    @inlinable public
    subscript(_ index: Int) -> Value {
        values[index]
    }
    
    /// Get index associated with a value.
    @inlinable public
    func lookup(_ value: Value) -> Int? {
        map[value]
    }
}
