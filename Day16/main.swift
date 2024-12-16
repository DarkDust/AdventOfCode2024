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
    
    var neighbours: [Elk] {
        let left = self.direction.turn(.left)
        let right = self.direction.turn(.right)
        
        return [
            Elk(position: self.position.neighbour(direction: direction), direction: direction),
            Elk(position: self.position.neighbour(direction: left), direction: left),
            Elk(position: self.position.neighbour(direction: right), direction: right),
        ]
    }
}


func calculateScore(path: [Elk], start: Elk) -> Int {
    var from = start
    var score = 0
    for to in path.dropFirst() {
        // Assume the distance is always 1. Just need to detect a turn.
        if from.direction != to.direction {
            score += 1001
        } else {
            score += 1
        }
        from = to
    }
    return score
}


runPart(.input) {
    (lines) in
    
    var grid = try FieldGrid<Field>(lines)
    guard let start = grid.findFirst(.start), let goal = grid.findFirst(.goal) else { fatalError() }
    grid[start] = .empty
    grid[goal] = .empty
    
    let aStar = AStar<Elk>() {
        $0.neighbours.filter {
            grid.isInBounds($0.position) && grid[$0.position] == .empty
        }
    } estimateCost: {
        $0.position.rightAngledDistance(to: goal)
    } cost: {
        (from, to) in
        // Assume the distance is always 1. Just need to detect a turn.
        if from.direction != to.direction {
            return 1001
        } else {
            return 1
        }
    }
    
    let startElk = Elk(position: start, direction: .east)
    let solution = aStar.findPath(starts: [startElk]) {
        $0.position == goal
    }!
    print("Part 1: \(solution.cost)")
    print("Part 1a: \(calculateScore(path: solution.path, start: startElk))")
}

#if false
// Does not work yet.
runPart(.sample2) {
    (lines) in
    
    var grid = try FieldGrid<Field>(lines)
    guard let start = grid.findFirst(.start), let goal = grid.findFirst(.goal) else { fatalError() }
    grid[start] = .empty
    grid[goal] = .empty
    
    let aStarFirst = AStar<Elk>() {
        $0.neighbours.filter {
            grid.isInBounds($0.position) && grid[$0.position] == .empty
        }
    } estimateCost: {
        $0.position.rightAngledDistance(to: goal)
    } cost: {
        (from, to) in
        // Assume the distance is always 1. Just need to detect a turn.
        if from.direction != to.direction {
            return 1001
        } else {
            return 1
        }
    }
    
    let startElk = Elk(position: start, direction: .east)
    let first = aStarFirst.findPath(starts: [startElk]) {
        $0.position == goal
    }!
    
    var visited: Set<Coord> = Set(first.path.map(\.position))
    
    while true {
        let aStar = AStar<Elk>() {
            $0.neighbours.filter {
                grid.isInBounds($0.position) && grid[$0.position] == .empty
            }
        } estimateCost: {
            $0.position.rightAngledDistance(to: goal)
        } cost: {
            (from, to) in
            // Assume the distance is always 1. Just need to detect a turn.
            let penalty = visited.contains(to.position) ? 1 : 0
            if from.direction != to.direction {
                return 1001 + penalty
            } else {
                return 1 + penalty
            }
        }
        
        let solution = aStar.findPath(starts: [startElk]) {
            $0.position == goal
        }
        guard let solution else {
            break
        }
        let score = calculateScore(path: solution.path, start: startElk)
        guard score == first.cost else {
            break
        }
        
        let visitedThisTime: Set<Coord> = Set(solution.path.map(\.position))
        if visitedThisTime.subtracting(visited).isEmpty {
            // No new solution found.
            break
        }
        
        visited.formUnion(visitedThisTime)
        print(visited.count)
    }
    
    print("Part 2: \(visited.count)")
}
#endif
