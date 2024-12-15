//
//  main.swift
//  Day6
//
//  Created by Marc Haisenko on 2024-12-06.
//

import Foundation
import AOCTools

enum DayError: Error {
    case missingWatch
    case unexpectedLoop
}


enum Field: FieldProtocol, Equatable {
    case empty
    case obstacle
    case watch
    
    static func parse(_ input: Character) -> Field? {
        switch input {
        case ".": return .empty
        case "#": return .obstacle
        case "^": return .watch
        default: return nil
        }
    }
}


enum Outcome {
    case exit(visited: Set<Coord>)
    case loop
}


func walk(grid: FieldGrid<Field>, from: Coord) -> Outcome {
    var cursor = from
    var direction: Direction = .north
    var visited: [Coord: Int] = [cursor: 1]
    
    while true {
        let ahead = cursor + direction
        guard grid.isInBounds(ahead) else {
            return .exit(visited: Set(visited.keys))
        }
        
        if grid[ahead] == .obstacle {
            direction = direction.turn(.right)
            
        } else {
            let previousVisits = visited[ahead] ?? 0
            if previousVisits >= 4 {
                return .loop
            }
            
            visited[ahead] = previousVisits + 1
            cursor = ahead
        }
    }
}


runPart(.input) {
    (lines) in
    
    let grid = try FieldGrid<Field>(lines)
    guard let watchPos = grid.findFirst(.watch) else {
        throw DayError.missingWatch
    }
    
    switch walk(grid: grid, from: watchPos) {
    case .exit(let visited):
        print("Part 1: \(visited.count)")
        
    case .loop:
        throw DayError.unexpectedLoop
    }
    
}

await runPart(.input) {
    (lines) in
    
    let original = try FieldGrid<Field>(lines)
    guard let watchPos = original.findFirst(.watch) else {
        throw DayError.missingWatch
    }
    
    // My first version was just a brute force attempt: iterate all field coordinates, replacing
    // empty fields with an obstacle and checking it.
    //
    // This optimization is not mine, unfortunately: saw it in a solution from someone else (sorry,
    // don't remember who). First, walk the field without additional obstacles. That gives us all
    // fields that are actually worth putting an obstacle into.
    
    let candidates: Set<Coord>
    switch walk(grid: original, from: watchPos) {
    case .exit(let visited):
        candidates = visited.subtracting([watchPos])
        
    case .loop:
        throw DayError.unexpectedLoop
    }
    
    
    let loops = await candidates.mapAndReduce(0) {
        (candidate) in
        
        var grid = original
        grid[candidate] = .obstacle
        
        switch walk(grid: grid, from: watchPos) {
        case .exit: return 0
        case .loop: return 1
        }
    } reduce: { $0 + $1 }
    // In Xcode 16.1, the `+` operator is not @Sendable, so `reduce: +` doesn't work… 🙄
        
    print("Part 2: \(loops)")
}
