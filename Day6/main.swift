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


func walk(map: FieldMap<Field>, from: Coord) -> Outcome {
    var cursor = from
    var direction: Direction = .north
    var visited: [Coord: Int] = [cursor: 1]
    
    while true {
        let ahead = cursor + direction
        guard map.isInBounds(ahead) else {
            return .exit(visited: Set(visited.keys))
        }
        
        if map[ahead] == .obstacle {
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
    
    let map = try FieldMap<Field>(lines)
    guard let watchPos = map.findFirst(.watch) else {
        throw DayError.missingWatch
    }
    
    switch walk(map: map, from: watchPos) {
    case .exit(let visited):
        print("Part 1: \(visited.count)")
        
    case .loop:
        throw DayError.unexpectedLoop
    }
    
}

runPart(.input) {
    (lines) in
    
    let original = try FieldMap<Field>(lines)
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
    switch walk(map: original, from: watchPos) {
    case .exit(let visited):
        candidates = visited.subtracting([watchPos])
        
    case .loop:
        throw DayError.unexpectedLoop
    }
    
    var loops = 0
    for candidate in candidates {
        var map = original
        map[candidate] = .obstacle
        
        switch walk(map: map, from: watchPos) {
        case .exit: break
        case .loop: loops += 1
        }
    }
    
    print("Part 2: \(loops)")
}
