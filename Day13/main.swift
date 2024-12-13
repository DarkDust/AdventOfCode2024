//
//  main.swift
//  Day13
//
//  Created by Marc Haisenko on 2024-12-13.
//

import Foundation
import AOCTools
import Algorithms


func parse(_ lines: [Substring]) -> [( (Int64, Int64, Int64), (Int64, Int64, Int64) )] {
    var result: [( (Int64, Int64, Int64), (Int64, Int64, Int64) )] = []
    
    let regexButton = /X\+(\d+), Y\+(\d+)/
    let regexPrize = /X=(\d+), Y=(\d+)/
    for chunk in lines.filter({ !$0.isEmpty }).chunks(ofCount: 3) {
        let matchA = chunk[chunk.startIndex].firstMatch(of: regexButton)!
        let a1 = Int64(matchA.output.1)!
        let a2 = Int64(matchA.output.2)!
            
        let matchB = chunk[chunk.startIndex + 1].firstMatch(of: regexButton)!
        let b1 = Int64(matchB.output.1)!
        let b2 = Int64(matchB.output.2)!
            
        let matchC = chunk[chunk.startIndex + 2].firstMatch(of: regexPrize)!
        let c1 = Int64(matchC.output.1)!
        let c2 = Int64(matchC.output.2)!
        
        result.append(( (a1, b1, c1), (a2, b2, c2) ))
    }
    
    return result
}

runPart(.input) {
    (lines) in
    
    let equations = parse(lines)
    var sum: Int64 = 0
    
    for equation in equations {
        guard
            let steps = NumberAlgorithms.cramersRule(
                a1: equation.0.0,
                b1: equation.0.1,
                c1: equation.0.2,
                a2: equation.1.0,
                b2: equation.1.1,
                c2: equation.1.2
            ),
            steps.0 >= 0 && steps.0 <= 100,
            steps.1 >= 0 && steps.1 <= 100
        else {
            continue
        }
        
        sum += steps.0 * 3 + steps.1
    }
    
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    let equations = parse(lines)
    var sum: Int64 = 0
    
    for equation in equations {
        guard
            let steps = NumberAlgorithms.cramersRule(
                a1: equation.0.0,
                b1: equation.0.1,
                c1: 10_000_000_000_000 + equation.0.2,
                a2: equation.1.0,
                b2: equation.1.1,
                c2: 10_000_000_000_000 + equation.1.2
            ),
            steps.0 >= 0,
            steps.1 >= 0
        else {
            continue
        }
        
        sum += steps.0 * 3 + steps.1
    }
    
    print("Part 2: \(sum)")
}
