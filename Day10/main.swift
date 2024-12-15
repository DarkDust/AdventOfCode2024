//
//  main.swift
//  Day10
//
//  Created by Marc Haisenko on 2024-12-10.
//

import Foundation
import AOCTools


func findTrails(_ grid: FieldGrid<Int>, coord: Coord, height: Int, goals: inout Set<Coord>) -> Int {
    if height == 9 {
        goals.insert(coord)
        return 1
    }
    
    let neighbours = grid.neighbours(for: coord, scheme: .cross, wrap: false)
    var sum = 0
    for neighbour in neighbours where neighbour.field == height + 1 {
        sum += findTrails(grid, coord: neighbour.coord, height: neighbour.field, goals: &goals)
    }
    return sum
}


runPart(.input) {
    (lines) in
    
    let grid = try FieldGrid<Int>(lines)
    let starts = grid.filter { $1 == 0 }
    let sum = starts.reduce(0) {
        var goals: Set<Coord> = []
        _ = findTrails(grid, coord: $1.coord, height: 0, goals: &goals)
        return $0 + goals.count
    }
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    let grid = try FieldGrid<Int>(lines)
    let starts = grid.filter { $1 == 0 }
    let sum = starts.reduce(0) {
        var goals: Set<Coord> = []
        return $0 + findTrails(grid, coord: $1.coord, height: 0, goals: &goals)
    }
    print("Part 2: \(sum)")
}
