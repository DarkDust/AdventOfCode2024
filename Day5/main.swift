//
//  main.swift
//  Day5
//
//  Created by Marc Haisenko on 2024-12-05.
//

import Foundation
import AOCTools
import Algorithms


func process(lines: [Substring], countIncorrect: Bool) -> Int {
    var seen: Set<Int> = []
    var successors: [Int: Set<Int>] = [:]
    var isBuilding = true
    var sum = 0
    
    for line in lines {
        if line.isEmpty {
            isBuilding = false
            continue
            
        } else if isBuilding {
            let numbers = line.split(separator: "|").map { Int($0)! }
            assert(numbers.count == 2)
            let left = numbers[0]
            let right = numbers[1]
            
            seen.insert(left)
            seen.insert(right)
            successors[left, default: []].insert(right)
            
            continue
        }
        
        let numbers = line.split(separator: ",").map { Int($0)! }
        assert(numbers.count % 2 == 1, "Assuming an odd number of numbers")
        let middleIndex = numbers.count / 2
        let sorted = numbers.sorted {
            successors[$0]?.contains($1) ?? false
        }
        
        let isCorrect = numbers == sorted
        if isCorrect, !countIncorrect {
            sum += numbers[middleIndex]
            
        } else if !isCorrect, countIncorrect {
            sum += sorted[middleIndex]
        }
    }
    
    return sum
}


runPart(.input) {
    let sum = process(lines: $0, countIncorrect: false)
    print("Part 1: \(sum)")
}

runPart(.input) {
    let sum = process(lines: $0, countIncorrect: true)
    print("Part 2: \(sum)")
}
