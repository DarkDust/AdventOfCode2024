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


struct Calibration {
    let target: Int
    let values: [Int]
    
    
    init(_ line: Substring) throws {
        let refTarget = Reference(Int.self)
        let refValues = Reference([Int].self)
        
        let regex = Regex {
            Capture(OneOrMore(.digit), as: refTarget, transform: { Int($0)! })
            ": "
            Capture(as: refValues) {
                OneOrMore {
                    .digit.union(.whitespace)
                }
            } transform: {
                $0.split(separator: .whitespace).map { Int($0)! }
            }
        }
        
        guard let match = try regex.firstMatch(in: line) else {
            throw DayError.invalidFormat
        }
        
        self.target = match[refTarget]
        self.values = match[refValues]
    }
    
    
    /// Check whether the input is valid when combining with the given list of operators.
    func isValid(ops: [Operator]) -> Bool {
        // Handle some edge cases first.
        switch self.values.count {
        case 0: return false
        case 1: return self.values[0] == self.target
        default: break
        }
        
        let current = values[0]
        let remaining = self.values.dropFirst()
        for op in ops {
            if self.isValid(current: current, remaining: remaining, op: op, ops: ops) {
                return true
            }
        }
        return false
    }
    
    
    private
    func isValid(current: Int, remaining: ArraySlice<Int>, op: Operator, ops: [Operator]) -> Bool {
        let next = remaining[remaining.startIndex]
        let intermediate = op(current, next)
        if intermediate > self.target {
            return false
        }
        
        let nextRemaining = remaining.dropFirst()
        if nextRemaining.isEmpty {
            return intermediate == self.target
        }
        
        for op in ops {
            if self.isValid(current: intermediate, remaining: nextRemaining, op: op, ops: ops) {
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
        .map { $0.target }
        .reduce(0, +)
}


runPart(.input) {
    let result = try process($0, ops: [ {$0 + $1}, {$0 * $1} ])
    print("Part 1: \(result)")
}

runPart(.input) {
    let result = try process($0, ops: [ {$0 + $1}, {$0 * $1}, {$0.concatenate($1)} ])
    print("Part 2: \(result)")
}
