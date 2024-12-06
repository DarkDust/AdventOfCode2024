//
//  Measure.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-01.
//

import Foundation
import RegexBuilder


// "Normal" implementation
public
func runPart(_ input: Input, repetitions: Int = 1, block: ([Substring]) throws -> Void) {
    var string = input.string
    string.makeContiguousUTF8()
    assert(string.isContiguousUTF8, "Cannot make the string contiguous, performance would be bad")
    
    let start = Date()
    
    // Consider preparing the input as part of the "run" when it comes to measuring the duration.
    // Need to handle empty lines in the middle, but remove a trailing empty line.
    var lines = string.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
    if lines.last?.isEmpty ?? false {
        lines.removeLast()
    }
    
    for _ in 0 ..< repetitions {
        do {
            try block(lines)
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
    
    let elapsed = -start.timeIntervalSinceNow
    
    print("Elapsed: " + format(elpasedTime: elapsed))
    if repetitions > 1 {
        print("Average: " + format(elpasedTime: elapsed / Double(repetitions)))
    }
}


// async implementation
public
func runPart(_ input: Input, repetitions: Int = 1, block: ([Substring]) async throws -> Void) async {
    var string = input.string
    string.makeContiguousUTF8()
    assert(string.isContiguousUTF8, "Cannot make the string contiguous, performance would be bad")
    
    let start = Date()
    
    // Consider preparing the input as part of the "run" when it comes to measuring the duration.
    // Need to handle empty lines in the middle, but remove a trailing empty line.
    var lines = string.split(omittingEmptySubsequences: false, whereSeparator: \.isNewline)
    if lines.last?.isEmpty ?? false {
        lines.removeLast()
    }
    
    for _ in 0 ..< repetitions {
        do {
            try await block(lines)
        } catch {
            print("Error: \(error)")
            exit(1)
        }
    }
    
    let elapsed = -start.timeIntervalSinceNow
    
    print("Elapsed: " + format(elpasedTime: elapsed))
    if repetitions > 1 {
        print("Average: " + format(elpasedTime: elapsed / Double(repetitions)))
    }
}

private
func format(elpasedTime elapsed: TimeInterval) -> String {
    let formatter = NumberFormatter()
    formatter.maximumSignificantDigits = 3
    formatter.locale = Locale(identifier: "en_US_POSIX")

    let microSeconds = elapsed * 1_000_000_000
    let milliSeconds = elapsed * 1_000
    
    if microSeconds < 1_100 {
        return (formatter.string(from: NSNumber(value: microSeconds)) ?? "\(microSeconds)") + " µs"
    }

    if milliSeconds < 1_100 {
        return (formatter.string(from: NSNumber(value: milliSeconds)) ?? "\(milliSeconds)") + " ms"
    }
    
    return (formatter.string(from: NSNumber(value: elapsed)) ?? "\(elapsed)") + " s"
}
