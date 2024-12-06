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
    case exit(visited: Int)
    case loop
}


func walk(map: FieldMap<Field>, from: Coord) -> Outcome {
    var cursor = from
    var direction: Direction = .north
    var visited: [Coord: Int] = [cursor: 1]
    
    while true {
        let ahead = cursor + direction.stepOffset
        guard map.isInBounds(ahead) else {
            return .exit(visited: visited.count)
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
        print("Part 1: \(visited)")
        
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
    
    var loops = 0
    for x in 0 ..< original.width {
        for y in 0 ..< original.height {
            guard original[x, y] == .empty else { continue }
            
            var map = original
            map[x, y] = .obstacle
            
            switch walk(map: map, from: watchPos) {
            case .exit: break
            case .loop: loops += 1
            }
        }
    }
    
    print("Part 2: \(loops)")
}
