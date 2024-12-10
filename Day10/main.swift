//
//  main.swift
//  Day10
//
//  Created by Marc Haisenko on 2024-12-10.
//

import Foundation
import AOCTools


func findTrails(_ map: FieldMap<Int>, coord: Coord, height: Int, goals: inout Set<Coord>) -> Int {
    if height == 9 {
        goals.insert(coord)
        return 1
    }
    
    let neighbours = map.neighbours(for: coord, scheme: .cross, wrap: false)
    var sum = 0
    for neighbour in neighbours where neighbour.field == height + 1 {
        sum += findTrails(map, coord: neighbour.coord, height: neighbour.field, goals: &goals)
    }
    return sum
}


runPart(.input) {
    (lines) in
    
    let map = try FieldMap<Int>(lines)
    let starts = map.filter { $1 == 0 }
    let sum = starts.reduce(0) {
        var goals: Set<Coord> = []
        _ = findTrails(map, coord: $1.coord, height: 0, goals: &goals)
        return $0 + goals.count
    }
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    let map = try FieldMap<Int>(lines)
    let starts = map.filter { $1 == 0 }
    let sum = starts.reduce(0) {
        var goals: Set<Coord> = []
        return $0 + findTrails(map, coord: $1.coord, height: 0, goals: &goals)
    }
    print("Part 2: \(sum)")
}
