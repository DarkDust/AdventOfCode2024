//
//  main.swift
//  Day11
//
//  Created by Marc Haisenko on 2024-12-11.
//

import Foundation
import AOCTools

func evolve(stone: Int) -> [Int] {
    if stone == 0 {
        return [1]
    }
    
    let digits = stone.numberOfDigits
    if digits % 2 == 0 {
        let halfMagnitude = Int(pow(10, Double(digits / 2)))
        let lower = stone % halfMagnitude
        let upper = stone / halfMagnitude
        return [upper, lower]
    }
    
    return [stone * 2024]
}


func evolve(stone: Int, step: Int, maxSteps: Int, cache: inout [[Int]: Int]) -> Int {
    // I admit, I copied this strategy from someone else. Didn't manage to come up with it on my
    // own even though it's not _that_ hard to come up with (when you get stuck with a horizontal
    // problem try to turn it into a vertical one…).
    //
    // I tried to come up with some kind of cycle detection or interpolation, all based around the
    // "horizontal" thinking of all stones in a line, instead of thinking: how does each stone
    // individually evolve with each step?
    if step == maxSteps { return 1 }
    
    // It's so ugly that you can't use a (Int, Int) tuple as a dictionary key…
    if let cached = cache[[stone, step]] {
        // Have a cached intermediate result, no need to recurse.
        return cached
    }
    
    // Not cached. Recurse, then cache the value and return.
    let evolvedCount = {
        if stone == 0 {
            return evolve(stone: 1, step: step + 1, maxSteps: maxSteps, cache: &cache)
        }
        
        let digits = stone.numberOfDigits
        if digits % 2 == 0 {
            let halfMagnitude = Int(pow(10, Double(digits / 2)))
            let lower = stone % halfMagnitude
            let upper = stone / halfMagnitude
            
            let stonesUpper = evolve(stone: upper, step: step + 1, maxSteps: maxSteps, cache: &cache)
            let stonesLower = evolve(stone: lower, step: step + 1, maxSteps: maxSteps, cache: &cache)
            return stonesLower + stonesUpper
        }
        
        return evolve(stone: stone * 2024, step: step + 1, maxSteps: maxSteps, cache: &cache)
    }()
    cache[[stone, step]] = evolvedCount
    return evolvedCount
}

runPart(.input) {
    (lines) in
    
    let originalStones = lines[0].split(separator: .whitespace).compactMap { Int($0) }
    var stones = originalStones
    for _ in 0 ..< 25 {
        stones = stones.map(evolve(stone:)).flatMap(\.self)
    }
    
    print("Part 1: \(stones.count)")
}

runPart(.input) {
    (lines) in
    
    let stones = lines[0].split(separator: .whitespace).compactMap { Int($0) }
    var cache: [[Int]: Int] = [:]
    let alt = stones.map { evolve(stone: $0, step: 0, maxSteps: 75, cache: &cache) }.reduce(0, +)
    print("Part 2: \(alt)")
}
