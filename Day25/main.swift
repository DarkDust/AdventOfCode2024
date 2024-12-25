//
//  main.swift
//  Day25
//
//  Created by Marc Haisenko on 2024-12-25.
//

import Foundation
import AOCTools

enum DayError: Error {
    case invalidKeyOrLockInput
    case invalidKeyLockCombination
}


func transpose(lines: [Substring]) -> [String] {
    guard !lines.isEmpty else { return [] }
    
    let width = lines[0].count
    
    var transposed: [String] = Array(repeating: "", count: width)
    for line in lines {
        for (x, char) in line.enumerated() {
            transposed[x].append(char)
        }
    }
    
    return transposed
}


struct KeyOrLock: CustomDebugStringConvertible {
    enum Kind {
        case key
        case lock
    }
    
    let kind: Kind
    let heights: [Int]
    let maximumHeight: Int
    
    init(lines: [Substring]) throws(DayError) {
        guard !lines.isEmpty else { throw .invalidKeyOrLockInput }
        guard let firstChar = lines[0].first else { throw .invalidKeyOrLockInput }
        
        var scanChar: Character
        switch firstChar {
        case ".":
            self.kind = .key
            scanChar = "#"
            
        case "#":
            self.kind = .lock
            scanChar = "#"
            
        default:
            throw .invalidKeyOrLockInput
        }
        
        let transposed = transpose(lines: lines)
        self.heights = transposed.map {
            $0.count(where: { $0 == scanChar }) - 1
        }
        self.maximumHeight = lines.count - 2
    }
    
    func fits(_ other: KeyOrLock) throws(DayError) -> Bool {
        guard self.kind != other.kind else {
            throw .invalidKeyLockCombination
        }
        
        assert(self.heights.count == other.heights.count)
        let maximumHeight = self.maximumHeight
        for (i, height) in self.heights.enumerated() {
            if height + other.heights[i] > maximumHeight {
                return false
            }
        }
        
        return true
    }
    
    var debugDescription: String {
        switch kind {
        case .key: "Key \(self.heights.map { String($0) }.joined(separator: ","))"
        case .lock: "Lock \(self.heights.map { String($0) }.joined(separator: ","))"
        }
    }
    
}


func parse(_ lines: [Substring]) throws(DayError) -> (keys: [KeyOrLock], locks: [KeyOrLock]) {
    var keys: [KeyOrLock] = []
    var locks: [KeyOrLock] = []
    
    var accumulator: [Substring] = []
    for line in lines {
        guard line.isEmpty else {
            accumulator.append(line)
            continue
        }
        
        let keyOrLock = try KeyOrLock(lines: accumulator)
        if keyOrLock.kind == .key {
            keys.append(keyOrLock)
        } else {
            locks.append(keyOrLock)
        }
        accumulator.removeAll()
        continue
    }
    
    if !accumulator.isEmpty {
        let keyOrLock = try KeyOrLock(lines: accumulator)
        if keyOrLock.kind == .key {
            keys.append(keyOrLock)
        } else {
            locks.append(keyOrLock)
        }
    }
    
    return (keys, locks)
}


runPart(.input) {
    (lines) in
    
    var fits = 0
    let (keys, locks) = try parse(lines)
    for lock in locks {
        for key in keys where try key.fits(lock) {
            fits += 1
        }
    }
    
    print("Part 1: \(fits)")
}
