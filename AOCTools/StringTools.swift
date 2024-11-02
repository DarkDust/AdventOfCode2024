//
//  StringTools.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

public
extension Substring {
    
    /// Returns an iterator that drops characters from the start.
    ///
    /// For example, given the input "abc", returns the strings "abc", "bc", and "c".
    func droppingFromStart() -> any Sequence<Substring> {
        return StringChoppingIterator(string: self, index: self.startIndex)
    }
    
}

public
extension String {
    
    /// Returns an iterator that drops characters from the start.
    ///
    /// For example, given the input "abc", returns the strings "abc", "bc", and "c".
    func droppingFromStart() -> any Sequence<Substring> {
        return StringChoppingIterator(string: Substring(self), index: self.startIndex)
    }
    
}

struct StringChoppingIterator: Sequence, IteratorProtocol {
    var string: Substring
    var index: String.Index
    
    mutating func next() -> Substring? {
        guard index < string.endIndex else { return nil }
        let prefix = string[index...]
        index = string.index(after: index)
        return prefix
    }
}
