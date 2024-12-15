//
//  main.swift
//  Day15
//
//  Created by Marc Haisenko on 2024-12-15.
//

import Foundation
import AOCTools

enum DayError: Error {
    case invalidInput
    case missingRobot
    case invalidMovement
    case corruptedGrid
}

enum Field: FieldProtocol, CustomStringConvertible {
    case empty
    case wall
    case box
    case boxLeft
    case boxRight
    case robot
    
    static func parse(_ input: Character) -> Field? {
        switch input {
        case ".": return .empty
        case "#": return .wall
        case "@": return .robot
        case "O": return .box
        case "[": return .boxLeft
        case "]": return .boxRight
        default: return nil
        }
    }
    
    var description: String {
        switch self {
        case .empty: return "."
        case .wall: return "#"
        case .robot: return "@"
        case .box: return "O"
        case .boxLeft: return "["
        case .boxRight: return"]"
        }
    }
}

func move(grid: FieldGrid<Field>, robot: Coord, direction: Direction) throws -> (FieldGrid<Field>, Coord) {
    // Don't need to check whether the robot is in bounds since there's a wall all around.
    let updatedRobot = robot.neighbour(direction: direction)
    let field = grid[updatedRobot]
    
    switch field {
    case .wall: return (grid, robot) // Cannot move.
    case .empty: return (grid, updatedRobot) // Simple.
    case .robot: throw DayError.corruptedGrid // There should not be any robot in the grid
    case .box, .boxLeft, .boxRight:
        var patched = grid
        if try move(grid: &patched, coord: updatedRobot, direction: direction) {
            assert(patched[updatedRobot] == .empty)
            return (patched, updatedRobot)
        } else {
            // Cannot move.
            return (grid, robot)
        }
    }
    
}

func move(grid: inout FieldGrid<Field>, coord: Coord, direction: Direction) throws  -> Bool {
    let box = grid[coord]
    let nextCoord = coord.neighbour(direction: direction)
    let firstBox: (Field, Coord)
    let nextFirstBox: (Field, Coord)
    let secondBox: (Field, Coord)
    let nextSecondBox: (Field, Coord)
    
    switch (box, grid[nextCoord], direction) {
    case (.empty, _, _):
        // Don't need to move.
        return true
        
    case (_, .wall, _):
        // Cannot move.
        return false
        
    case (.box, .empty, _):
        grid[coord] = .empty
        grid[nextCoord] = box
        return true
        
    case (.box, .box, _):
        guard try move(grid: &grid, coord: nextCoord, direction: direction) else {
            return false
        }
        grid[coord] = .empty
        grid[nextCoord] = box
        return true
        
    case (.boxLeft, _, .north), (.boxLeft, _, .south), (.boxLeft, _, .west):
        // Need to move the left side first.
        firstBox = (box, coord)
        nextFirstBox = (box, nextCoord)
        secondBox = (.boxRight, coord.east)
        nextSecondBox = (.boxRight, secondBox.1.neighbour(direction: direction))
        assert(grid[secondBox.1] == .boxRight)
        
    case (.boxLeft, _, .east):
        // Need to move the right side first.
        firstBox = (.boxRight, coord.east)
        nextFirstBox = (.boxRight, firstBox.1.neighbour(direction: direction))
        secondBox = (box, coord)
        nextSecondBox = (box, nextCoord)
        assert(grid[firstBox.1] == .boxRight)
        
    case (.boxRight, _, .north), (.boxRight, _, .south), (.boxRight, _, .east):
        // Need to move the right side first.
        firstBox = (box, coord)
        nextFirstBox = (box, nextCoord)
        secondBox = (.boxLeft, coord.west)
        nextSecondBox = (.boxLeft, secondBox.1.neighbour(direction: direction))
        assert(grid[secondBox.1] == .boxLeft)
        
    case (.boxRight, _, .west):
        // Need to move the left side first.
        firstBox = (.boxLeft, coord.west)
        nextFirstBox = (.boxLeft, firstBox.1.neighbour(direction: direction))
        secondBox = (box, coord)
        nextSecondBox = (box, nextCoord)
        assert(grid[firstBox.1] == .boxLeft)
    
    default:
        throw DayError.invalidMovement
    }
    
    // Handle the double-box movements.
    switch grid[nextFirstBox.1] {
    case .wall:
        // Cannot move.
        return false
        
    case .empty:
        // Can move immediately, continue below.
        break
        
    case .box, .boxLeft, .boxRight:
        // Need to move something out of the way first:
        guard
            try move(grid: &grid, coord: nextFirstBox.1, direction: direction)
        else {
            // Can't make room.
            return false
        }
        // Field it now empty, continue below.
        
    case .robot:
        throw DayError.corruptedGrid
    }
    
    // For north/south, both box parts need to be considered. (Not necessary for east/west.)
    if (direction == .north || direction == .south) {
        switch grid[nextSecondBox.1] {
        case .wall:
            // Cannot move.
            return false
            
        case .empty:
            // Can move immediately, continue below.
            break
            
        case .box, .boxLeft, .boxRight:
            // Need to move something out of the way first:
            guard
                try move(grid: &grid, coord: nextSecondBox.1, direction: direction)
            else {
                // Can't make room.
                return false
            }
            // Field it now empty, continue below.
            
        case .robot:
            throw DayError.corruptedGrid
        }
    }
    
    
    grid[firstBox.1] = .empty
    grid[secondBox.1] = .empty
    grid[nextFirstBox.1] = nextFirstBox.0
    grid[nextSecondBox.1] = nextSecondBox.0
    return true
}

runPart(.input) {
    (lines) in
    
    guard let delimiter = lines.firstIndex(of: "") else {
        throw DayError.invalidInput
    }
    
    var grid = try FieldGrid<Field>(lines[..<delimiter])
    guard var robot = grid.findFirst(.robot) else {
        throw DayError.missingRobot
    }
    grid[robot] = .empty
    
    let instructions = lines[delimiter...].flatMap { $0 }
    for instruction in instructions {
        let direction: Direction
        switch instruction {
        case "^": direction = .north
        case "v": direction = .south
        case "<": direction = .west
        case ">": direction = .east
        default: throw DayError.invalidMovement
        }
        
        (grid, robot) = try move(grid: grid, robot: robot, direction: direction)
    }
    
    let score = grid
        .filter { $1 == .box }
        .map { $0.coord.y * 100 + $0.coord.x }
        .reduce(0, +)
    print("Part 1: \(score)")
}

runPart(.input) {
    (lines) in
    
    guard let delimiter = lines.firstIndex(of: "") else {
        throw DayError.invalidInput
    }
    
    let originalGrid = try FieldGrid<Field>(lines[..<delimiter])
    // Scale-up the grid.
    var grid = FieldGrid<Field>(width: originalGrid.width * 2, height: originalGrid.height, repeating: .empty)
    for (coord, field) in originalGrid {
        switch field {
        case .empty:
            continue
            
        case .wall:
            grid[coord.x * 2, coord.y] = .wall
            grid[coord.x * 2  + 1, coord.y] = .wall
        
        case .box:
            grid[coord.x * 2, coord.y] = .boxLeft
            grid[coord.x * 2  + 1, coord.y] = .boxRight
            
        case .robot:
            grid[coord.x * 2, coord.y] = .robot
            
        case .boxLeft, .boxRight:
            throw DayError.invalidInput
        }
    }
    
    guard var robot = grid.findFirst(.robot) else {
        throw DayError.missingRobot
    }
    grid[robot] = .empty
    
    let instructions = lines[delimiter...].flatMap { $0 }
    for instruction in instructions {
        let direction: Direction
        switch instruction {
        case "^": direction = .north
        case "v": direction = .south
        case "<": direction = .west
        case ">": direction = .east
        default: throw DayError.invalidMovement
        }
        
        (grid, robot) = try move(grid: grid, robot: robot, direction: direction)
    }
    
    let score = grid
        .filter { $1 == .boxLeft }
        .map { $0.coord.y * 100 + $0.coord.x }
        .reduce(0, +)
    print("Part 2: \(score)")
}
