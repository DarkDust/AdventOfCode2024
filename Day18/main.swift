//
//  main.swift
//  Day18
//
//  Created by Marc Haisenko on 2024-12-19.
//

import Foundation
import AOCTools

runPart(.input) {
    (lines) in
    
    let start = Coord(x: 0, y: 0)
    let goal = Coord(x: 70, y: 70)
    let numBytes = 1024
    let corrupted: Set<Coord> = Set(lines.prefix(numBytes).compactMap { Coord($0) })
    func isSafe(_ coord: Coord) -> Bool {
        coord.x >= start.x && coord.y >= start.y && coord.x <= goal.x && coord.y <= goal.y
        && !corrupted.contains(coord)
    }
    
    let pathfinder = AStar<Coord> {
        $0 == goal
    } neighbours: {
        $0.neighbours(scheme: .cross).filter(isSafe)
    } estimateCost: {
        $0.manhattanDistance(to: goal)
    } cost: {
        $0.manhattanDistance(to: $1)
    }
    
    guard let (path, _) = pathfinder.findPath(starts: [start]) else {
        fatalError("No path found")
    }
    
    
    print("Part 1: \(path.count - 1)")
}

runPart(.input) {
    (lines) in
    
    let start = Coord(x: 0, y: 0)
    let goal = Coord(x: 70, y: 70)
    let corrupted: [Coord] = lines.compactMap { Coord($0) }
    
    let firstBlocking = corrupted.binarySearch {
        (splitIndex) in
        
        let corruptedSoFar = Set(corrupted[..<splitIndex])
        func isSafe(_ coord: Coord) -> Bool {
            coord.x >= start.x && coord.y >= start.y && coord.x <= goal.x && coord.y <= goal.y
            && !corruptedSoFar.contains(coord)
        }
        
        let pathfinder = AStar<Coord> {
            $0 == goal
        } neighbours: {
            $0.neighbours(scheme: .cross).filter(isSafe)
        } estimateCost: {
            $0.manhattanDistance(to: goal)
        } cost: {
            $0.manhattanDistance(to: $1)
        }
        
        return pathfinder.findPath(starts: [start]) != nil
    }
    
    print("Part 2: \(corrupted[firstBlocking - 1])")
}
