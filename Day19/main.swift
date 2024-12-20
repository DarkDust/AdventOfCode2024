//
//  main.swift
//  Day19
//
//  Created by Marc Haisenko on 2024-12-20.
//

import Foundation
import AOCTools

enum Color: Sendable {
    case black
    case white
    case red
    case green
    case blue
    
    init?(_ char: Character) {
        switch char {
        case "b": self = .black
        case "w": self = .white
        case "r": self = .red
        case "g": self = .green
        case "u": self = .blue
        default:
            assertionFailure("Invalid color")
            return nil
        }
    }
}

typealias Towel = [Color]
typealias TowelList = [Towel]
typealias TowelSet = Set<Towel>
typealias Pattern = [Color]


func isPatternValid(_ pattern: some Collection<Color>, towels availableTowels: [Int: TowelSet]) -> Bool {
    if pattern.isEmpty { return true }
    
    for (length, towels) in availableTowels where length <= pattern.count {
        let subPattern = Array(pattern.prefix(length))
        if towels.contains(subPattern), isPatternValid(pattern.dropFirst(length), towels: availableTowels) {
            return true
        }
    }
    
    return false
}


func countCombinations(cache: inout [Pattern: Int], remainingPattern: Pattern, towels availableTowels: [Int: TowelSet]) -> Int {
    if remainingPattern.isEmpty { return 1 }
    
    if let cached = cache[remainingPattern] { return cached }
    
    var count = 0
    
    for (length, towels) in availableTowels where length <= remainingPattern.count {
        let subPattern = Array(remainingPattern.prefix(length))
        if towels.contains(subPattern) {
            count += countCombinations(
                cache: &cache,
                remainingPattern: Array(remainingPattern.dropFirst(length)),
                towels: availableTowels
            )
        }
    }
    
    cache[remainingPattern] = count
    return count
}


extension Towel {
    init(_ string: any StringProtocol) {
        self = string.compactMap { Color($0) }
    }
}


runPart(.input) {
    (lines) in
    
    assert(lines[1].isEmpty, "Unexpected input")
    let towels = lines[0].split(separator: ", ").map { Towel($0) }
    // Group the towels by pattern length to speed up the recursive algorithm.
    let grouped = Dictionary(grouping: towels, by: { $0.count }).mapValues { Set($0) }
    
    let patterns = lines.dropFirst(2).map { Pattern($0) }
    let validPatterns = patterns.count(where: {
        isPatternValid($0, towels: grouped)
    })
    print("Part 1: \(validPatterns)")
}


runPart(.input) {
    (lines) in
    
    assert(lines[1].isEmpty, "Unexpected input")
    let towels = lines[0].split(separator: ", ").map { Towel($0) }
    // Group the towels by pattern length to speed up the recursive algorithm.
    let grouped = Dictionary(grouping: towels, by: { $0.count }).mapValues { Set($0) }
    
    let patterns = lines.dropFirst(2).map { Pattern($0) }
    var cache: [Pattern: Int] = [:]
    let validCombinations = patterns.reduce(0) {
        $0 + countCombinations(cache: &cache, remainingPattern: $1, towels: grouped)
    }
    
    print("Part 2: \(validCombinations)")
}
