//
//  main.swift
//  Day3
//
//  Created by Marc Haisenko on 2024-12-03.
//

import Foundation
import AOCTools
import RegexBuilder


runPart(.input) {
    (lines) in
    
    let regex = /mul\(([0-9]{1,3}),([0-9]{1,3})\)/
    var sum = 0
    for line in lines {
        for match in line.matches(of: regex) {
            let left = Int(match.1)!
            let right = Int(match.2)!
            sum += left * right
        }
    }
    
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    let strDo = "do()"
    let strDont = "don't()"
    let refAll = Reference<Substring>()
    let refLeft = Reference<Int>()
    let refRight = Reference<Int>()
    
    let mulRegex = Regex {
        "mul("
        // Short form.
        Capture(Repeat(.digit, 1...3), as: refLeft) { Int($0)! }
        ","
        // Same thing, only more verbose.
        Capture(as: refRight) {
            Repeat(.digit, 1...3)
        } transform: {
            Int($0)!
        }
        ")"
    }
    let regex = Regex {
        Capture(as: refAll) {
            ChoiceOf {
                strDo
                strDont
                mulRegex
            }
        }
    }
    
    var sum = 0
    var enabled = true
    for line in lines {
        for match in line.matches(of: regex) {
            switch match[refAll] {
            case strDo:
                enabled = true
                
            case strDont:
                enabled = false
                
            default:
                guard enabled else { continue }
                sum += match[refLeft] * match[refRight]
            }
        }
    }
    
    print("Part 2: \(sum)")

}
