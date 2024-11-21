//
//  main.swift
//  Day6
//
//  Created by Marc Haisenko on 2024-11-21.
//

import Foundation
import AOCTools


runPart(.input) {
    (lines) in
    
    let times = lines[0]
        .split(separator: ":")
        .last!
        .split(separator: .whitespace)
        .map { Int($0)! }
    let distances = lines[1]
        .split(separator: ":")
        .last!
        .split(separator: .whitespace)
        .map { Int($0)! }
    
    var result = 1
    for (time, distance) in zip(times, distances) {
        let candidates = (1..<time)
            .map { (time - $0) * $0 }
            .filter { $0 > distance }
        result *= candidates.count
    }
    
    print("Part 1: \(result)")
}

runPart(.input) {
    (lines) in
    
    let time = Int64(
        lines[0]
        .split(separator: ":")
        .last!
        .filter(\.isNumber)
    )!
    let distance = Int64(
        lines[1]
        .split(separator: ":")
        .last!
        .filter(\.isNumber)
    )!
    
//    let candidates = (1..<time)
//        .map { (time - $0) * $0 }
//        .filter { $0 > distance }
//    let result = candidates.count
    var result: Int64 = 0
    var hitting = false
    for t in 1 ..< time {
        let d = (time - t) * t
        if d > distance {
            result += 1
            hitting = true
        } else if hitting {
            break
        }
    }
    
    print("Part 2: \(result)")
}
