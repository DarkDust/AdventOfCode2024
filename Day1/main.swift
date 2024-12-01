//
//  main.swift
//  Day1
//
//  Created by Marc Haisenko on 2024-12-01.
//

import Foundation
import AOCTools

runPart(.input) {
    (lines) in
    
#if true
    // More swifty solution. With debug build, takes twice as long as the manual solution below.
    // With release build, there's almost no difference.
    let numbers: [(Int, Int)] = lines.map {
        let parts = $0.split(separator: "   ")
        return (Int(parts[0])!, Int(parts[1])!)
    }
    let left = numbers.map { $0.0 }.sorted()
    let right = numbers.map { $0.1 }.sorted()
#else
    // Faster way in debug builds. Reduces runtime by half.
    var left: [Int] = []
    var right: [Int] = []
    left.reserveCapacity(lines.count)
    right.reserveCapacity(lines.count)
    for line in lines {
        let parts = line.split(separator: "   ")
        left.append(Int(parts[0])!)
        right.append(Int(parts[1])!)
    }
#endif
    
    let distances = zip(left, right).map { abs($1 - $0) }
    let result = distances.reduce(0, +)
    print("Part 1: \(result)")
}


runPart(.input) {
    (lines) in
    
    let numbers: [(Int, Int)] = lines.map {
        let parts = $0.split(separator: "   ")
        return (Int(parts[0])!, Int(parts[1])!)
    }
    
    let left = numbers.map { $0.0 }
    let repetitions: [Int: Int] = numbers.reduce(into: [:]) {
        $0[$1.1, default: 0] += 1
    }
    
    let result = left.map {
        $0 * repetitions[$0, default: 0]
    }.reduce(0, +)
    print("Part 2: \(result)")
}
