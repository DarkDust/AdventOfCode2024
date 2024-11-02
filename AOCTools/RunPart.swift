//
//  Measure.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-01.
//

import Foundation
import RegexBuilder


public
func runPart(_ input: Input, block: ([Substring]) -> Void) {
    let string = input.string
    let start = Date()
    
    // Consider preparing the input as part of the "run" when it comes to measuring the duration.
    let lines = string.split(whereSeparator: \.isNewline)
    block(lines)
    
    let elapsed = -start.timeIntervalSinceNow
    
    print("Elapsed: " + format(elpasedTime: elapsed))
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
