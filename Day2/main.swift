//
//  main.swift
//  Day2
//
//  Created by Marc Haisenko on 2024-12-02.
//

import Foundation
import AOCTools
import Algorithms


func countSafeLevels(lines: [Substring], safetyCheck: ([Int]) -> Bool) -> Int {
    let levelsList: [[Int]] = lines.map {
        (line) in
        return line.split(separator: .whitespace).compactMap { Int($0) }
    }
    return levelsList.filter(safetyCheck).count
}

func isSafe(_ levels: [Int]) -> Bool {
    guard levels.count > 1 else { return true }
    
    let shouldIncrease = levels[0] < levels[1]
    return levels.adjacentPairs().allSatisfy {
        let difference = abs($0.0 - $0.1)
        return ($0.0 < $0.1) == shouldIncrease && difference >= 1 && difference <= 3
    }
}

func isSafeTolerant(_ levels: [Int]) -> Bool {
    if isSafe(levels) { return true }
    
    // This is a pretty naive implementation: for each element, check if the line would be valid
    // without it. I tried to come up with a smart solution and struggled, then gave the naive
    // implementation a chance… and it just runs less than 1ms(!) slower than part 1 on my Mac.
    // Absolutely not worth trying to come up with a more clever solution.
    for i in 0 ..< levels.count {
        var patched = levels
        patched.remove(at: i)
        
        if isSafe(patched) { return true }
    }
    
    return false
}


runPart(.input) {
    let count = countSafeLevels(lines: $0, safetyCheck: isSafe)
    print("Part 1: \(count)")
}

runPart(.input) {
    let count = countSafeLevels(lines: $0, safetyCheck: isSafeTolerant)
    print("Part 2: \(count)")
}
