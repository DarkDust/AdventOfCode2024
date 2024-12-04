//
//  main.swift
//  Day4
//
//  Created by Marc Haisenko on 2024-12-04.
//

import Foundation
import AOCTools


// `remaining` is in reverse.
func scan(map: Fixed2DArray<Character>, from: Coord, direction: Direction, remaining: String) -> Bool {
    let step = direction.stepOffset
    var match = remaining
    var current = from + step
    while map.isInBounds(current), map[current] == match.last {
        current += step
        match.removeLast()
        if match.isEmpty { return true }
    }
    
    return false
}


func scanPart1(map: Fixed2DArray<Character>) -> Int {
    var found = 0
    
    for y in 0..<map.rows {
        for x in 0..<map.columns {
            guard map[x, y] == "X" else { continue }
            
            for direction in Direction.allCases {
                if scan(map: map, from: .init(x: x, y: y), direction: direction, remaining: "SAM") {
                    found += 1
                }
            }
        }
    }
    
    return found
}


func scanPart2(map: Fixed2DArray<Character>) -> Int {
    var found: [Coord: Int] = [:]
    
    for y in 0..<map.rows {
        for x in 0..<map.columns {
            guard map[x, y] == "M" else { continue }
            
            for direction in Direction.directions(.diagonal) {
                if scan(map: map, from: .init(x: x, y: y), direction: direction, remaining: "SA") {
                    let coord = Coord(x: x, y: y) + direction.stepOffset
                    found[coord, default: 0] += 1
                }
            }
        }
    }
    
    return found.values.count(where: { $0 == 2 })
}


runPart(.input) {
    (lines) in
    
    let map = Fixed2DArray(lines: lines)
    let found = scanPart1(map: map)
    print("Part 1: \(found)")
}

runPart(.input) {
    (lines) in
    
    let map = Fixed2DArray(lines: lines)
    let found = scanPart2(map: map)
    print("Part 2: \(found)")
}
