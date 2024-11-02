//
//  main.swift
//  Day1
//
//  Created by Marc Haisenko on 2024-11-01.
//

import AOCTools
import Foundation
import RegexBuilder

// Day 1 from 2023 for testing

runPart(.input) {
    (lines) in
    
    let regex = Regex {
        One(.digit)
    }
    
    let numbers: [Int] = lines.map {
        let numbers = $0.matches(of: regex).compactMap { Int($0.0) }
        return (numbers.first ?? 0) * 10 + (numbers.last ?? 0)
    }
    
    let sum = numbers.reduce(0, +)
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    func convert(numberString string: Substring) -> Int? {
        if string.hasPrefix("1") {return 1 }
        if string.hasPrefix("2") {return 2 }
        if string.hasPrefix("3") {return 3 }
        if string.hasPrefix("4") {return 4 }
        if string.hasPrefix("5") {return 5 }
        if string.hasPrefix("6") {return 6 }
        if string.hasPrefix("7") {return 7 }
        if string.hasPrefix("8") {return 8 }
        if string.hasPrefix("9") {return 9 }
        if string.hasPrefix("one") { return 1 }
        if string.hasPrefix("two") { return 2 }
        if string.hasPrefix("three") { return 3 }
        if string.hasPrefix("four") { return 4 }
        if string.hasPrefix("five") { return 5 }
        if string.hasPrefix("six") { return 6 }
        if string.hasPrefix("seven") { return 7 }
        if string.hasPrefix("eight") { return 8 }
        if string.hasPrefix("nine") { return 9 }
        return nil
    }
    
    let numbers: [Int] = lines.map {
        let numbers = $0.droppingFromStart().compactMap(convert(numberString:))
        return (numbers.first ?? 0) * 10 + (numbers.last ?? 0)
    }
    
    let sum = numbers.reduce(0, +)
    print("Part 2: \(sum)")
}
