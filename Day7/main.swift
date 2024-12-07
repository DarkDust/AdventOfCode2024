//
//  main.swift
//  Day7
//
//  Created by Marc Haisenko on 2024-12-07.
//

import Foundation
import AOCTools
import RegexBuilder

enum DayError: Error {
    case invalidFormat
}

/// Operator to apply to two integers.
typealias Operator = (Int, Int) -> Int

// Passing closures is much more expensive than passing functions!
func plus(_ a: Int, _ b: Int) -> Int        { a + b }
func multiply(_ a: Int, _ b: Int) -> Int    { a * b }
func concatenate(_ a: Int, _ b: Int) -> Int { a.concatenate(b) }


struct Calibration {
    let target: Int
    let values: [Int]
    let valuesCount: Int
    
    
    init(_ line: Substring) throws {
        let refTarget = Reference(Int.self)
        let refValues = Reference([Int].self)
        
        let regex = Regex {
            Capture(OneOrMore(.digit), as: refTarget, transform: { Int($0)! })
            ": "
            Capture(as: refValues) {
                OneOrMore(.digit.union(.whitespace))
            } transform: {
                $0.split(separator: .whitespace).map { Int($0)! }
            }
        }
        
        guard let match = try regex.firstMatch(in: line) else {
            throw DayError.invalidFormat
        }
        
        self.target = match[refTarget]
        self.values = match[refValues]
        self.valuesCount = self.values.count
    }
    
    
    /// Check whether the input is valid when combining with the given list of operators.
    func isValid(ops: [Operator]) -> Bool {
        // Handle some edge cases first. They don't happen in the puzzles but ignoring them feels
        // wrong.
        switch self.valuesCount {
        case 0: return false
        case 1: return self.values[0] == self.target
        default: break
        }
        
        return isValid(current: self.values[0], index: 1, ops: ops)
    }
    
    
    private
    func isValid(current: Int, index: Int, ops: [Operator]) -> Bool {
        if current > self.target { return false }
        if index == self.valuesCount { return current == self.target }
        
        let next = self.values[index]
        for op in ops {
            if isValid(current: op(current, next), index: index + 1, ops: ops) {
                return true
            }
        }
        return false
    }
    
}


func process(_ lines: [Substring], ops: [Operator]) throws -> Int {
    let calibrations = try lines.map(Calibration.init)
    return calibrations
        .filter { $0.isValid(ops: ops) }
        .reduce(0) { $0 + $1.target }
}


runPart(.input) {
    let result = try process($0, ops: [ plus, multiply ])
    print("Part 1: \(result)")
}

runPart(.input) {
    let result = try process($0, ops: [ plus, multiply, concatenate ])
    print("Part 2: \(result)")
}
