//
//  main.swift
//  Day20
//
//  Created by Marc Haisenko on 2024-12-20.
//

import Foundation
import AOCTools
import Collections


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


struct Cheat: Hashable {
    let start: Coord
    let end: Coord
}


func findCheats(along optimalPath: [Coord], maxCheatLength: Int) -> [Int: Set<Cheat>] {
    var result: [Int: Set<Cheat>] = [:]
    
    // For each point along the path, calculate the Manhattan distance to each subsequent points
    // on the path (skipping the first 2 since they can't make the path shorter). If the distance
    // is shorter than our cheat length, it means we've found a valid shortcut through walls.
    //
    // Again, I was not able to come up with the solution myself. I wasted half a day trying to
    // come with various solutions mostly based on BFS, and like the past few days I _almost_ made
    // it work, but there were always some solutions missing in part 2 (did make part 1 work on my
    // own, at least). I was searching on Reddits for hints where the bugs in my solution are, but
    // it looks nobody came up with such a convoluted BFS attempt. Instead, I accidentally noticed
    // that it can be solved by just looking at the optimal path. I assumed that through cheats,
    // new paths can become viable but no, they can't. Boy am I frustrated with my aptitude as a
    // programmer.
    for i in 0 ..< optimalPath.count - 2  {
        let start = optimalPath[i]
        
        for k in i + 2 ..< optimalPath.count {
            let end = optimalPath[k]
            let distance = start.manhattanDistance(to: end)
            if distance <= maxCheatLength {
                let saved = (k - i) - distance
                let cheat = Cheat(start: start, end: end)
                result[saved, default: []].insert(cheat)
            }
        }
    }
    
    return result
}


func solve(lines: [Substring], maxCheatLength: Int, minSaved: Int) throws -> Int {
    var grid = try FieldGrid<Field>(lines)
    let start = grid.findFirst(.start)!
    let goal = grid.findFirst(.goal)!
    grid[start] = .empty
    grid[goal] = .empty
    
    let pathfinder = AStar {
        $0 == goal
    } neighbours: {
        $0.neighbours(scheme: .cross).filter { grid[$0] == .empty }
    } estimateCost: {
        $0.manhattanDistance(to: goal)
    } cost: {
        (_, _) in
        return 1
    }
    
    guard let (optimalPath, _) = pathfinder.findPath(starts: [start]) else {
        fatalError("Cannot find path")
    }
    
    let solutions = findCheats(along: optimalPath, maxCheatLength: maxCheatLength)
    return solutions.reduce(0) {
        (accumulator, solution) in
        
        guard solution.key >= minSaved else {
            return accumulator
        }
        
        return accumulator + solution.value.count
    }
}


runPart(.input) {
    let count = try solve(lines: $0, maxCheatLength: 2, minSaved: 100)
    print("Part 1: \(count)")
}

runPart(.input) {
    let count = try solve(lines: $0, maxCheatLength: 20, minSaved: 100)
    print("Part 2: \(count)")
}
