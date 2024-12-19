//
//  BinarySearch.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-05.
//

public
extension RandomAccessCollection {
    
    /// Finds such index N that predicate is true for all elements up to
    /// but not including the index N, and is false for all elements
    /// starting with index N.
    /// Behavior is undefined if there is no such N.
    func binarySearch(predicate: (Self.Index) -> Bool) -> Index {
        // Copied from https://stackoverflow.com/a/33674192/400056
        var low = startIndex
        var high = endIndex
        while low != high {
            let mid = index(low, offsetBy: distance(from: low, to: high) / 2)
            if predicate(mid) {
                low = index(after: mid)
            } else {
                high = mid
            }
        }
        return low
    }
    
}
