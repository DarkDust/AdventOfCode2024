//
//  main.swift
//  Day16
//
//  Created by Marc Haisenko on 2024-12-16.
//

import Foundation
import AOCTools

enum Field: FieldProtocol {
    case empty
    case wall
    case start
    case goal
    
    static func parse(_ input: Character) -> Field? {
        switch input {
        case ".": return .empty
        case "#": return .wall
        case "S": return .start
        case "E": return .goal
        default: return nil
        }
    }
}


struct Elk: Hashable {
    let position: Coord
    let direction: Direction
    
    /// Turn + step in one operation.
    var neighbours: [Elk] {
        let left = self.direction.turn(.left)
        let right = self.direction.turn(.right)
        
        return [
            Elk(position: self.position.neighbour(direction: direction), direction: direction),
            Elk(position: self.position.neighbour(direction: left), direction: left),
            Elk(position: self.position.neighbour(direction: right), direction: right),
        ]
    }
    
    /// Either turn or step.
    var nextSteps: [Elk] {
        let left = self.direction.turn(.left)
        let right = self.direction.turn(.right)
        
        return [
            Elk(position: self.position.neighbour(direction: direction), direction: direction),
            Elk(position: self.position, direction: left),
            Elk(position: self.position, direction: right),
        ]
    }
}

#if false
func parse(_ lines: [Substring]) throws -> (pathfinder: Dijkstra<Elk>, start: Elk) {
    var grid = try FieldGrid<Field>(lines)
    guard let start = grid.findFirst(.start), let goal = grid.findFirst(.goal) else { fatalError() }
    grid[start] = .empty
    grid[goal] = .empty
    
    let dijkstra = Dijkstra<Elk>() {
        $0.position == goal
    } neighbours: {
        $0.neighbours.filter {
            grid.isInBounds($0.position) && grid[$0.position] == .empty
        }
    } cost: {
        (from, to) in
        // Assume the distance is always 1. Just need to detect a turn.
        if from.direction != to.direction {
            return 1001
        } else {
            return 1
        }
    }
    
    return (dijkstra, Elk(position: start, direction: .east))
}
#else
func parse(_ lines: [Substring]) throws -> (pathfinder: AStar<Elk>, start: Elk) {
    var grid = try FieldGrid<Field>(lines)
    guard let start = grid.findFirst(.start), let goal = grid.findFirst(.goal) else { fatalError() }
    grid[start] = .empty
    grid[goal] = .empty
    
    let aStar = AStar<Elk>() {
        $0.position == goal
    } neighbours: {
        $0.neighbours.filter {
            grid.isInBounds($0.position) && grid[$0.position] == .empty
        }
    } estimateCost: {
        $0.position.manhattanDistance(to: goal)
    } cost: {
        (from, to) in
        // Assume the distance is always 1. Just need to detect a turn.
        if from.direction != to.direction {
            return 1001
        } else {
            return 1
        }
    }
    
    return (aStar, Elk(position: start, direction: .east))
}
#endif


runPart(.input) {
    (lines) in
    
    let (pathfinder, startElk) = try parse(lines)
    let solution = pathfinder.findPath(start: startElk)!
    print("Part 1: \(solution.cost)")
}

runPart(.input) {
    (lines) in
    
    let (pathfinder, startElk) = try parse(lines)
    let solutions = pathfinder.findAllPaths(start: startElk)!
    
    var visited: Set<Coord> = []
    for path in solutions.paths {
        visited.formUnion(path.map(\.position))
    }
    print("Part 2: \(visited.count)")
}
