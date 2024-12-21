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


struct CheatCoord: Hashable {
    let coord: Coord
    let index: Int
    let cheatIndex: Int
    var path: [Coord] = []
    
    static func == (lhs: CheatCoord, rhs: CheatCoord) -> Bool {
        return lhs.coord == rhs.coord && lhs.index == rhs.index
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(coord)
    }
}


struct Cheat: Hashable {
    let start: Coord
    let end: Coord
}


struct CheatFinder {
    let grid: FieldGrid<Field>
    let start: Coord
    let goal: Coord
    let optimalPath: [Coord]
    let optimalCost: Int
    
    func findCheatsBFS(index: Int, saved: inout [Int: Set<Cheat>]) {
        // This *almost* worked, found 40 of 44 of the sample cheats. But I couldn't make it work
        // completely.
        var queue = Deque<CheatCoord>()
        var visited = Set<Coord>()
        var solutions: [CheatCoord] = []
        
        visited.insert(start)
        queue.append(CheatCoord(coord: start, index: 0, cheatIndex: index, path: [start]))
        
        while let node = queue.popFirst() {
            guard node.index <= optimalCost else { continue }
            if node.coord == self.goal {
                solutions.append(node)
                continue
            }
            
            for neighbour in node.coord.neighbours(scheme: .cross) {
                guard
                    neighbour != node.coord,
                    grid.isInBounds(neighbour),
                    !visited.contains(neighbour)
                else {
                    continue
                }
                
                if node.index == node.cheatIndex {
                    guard grid[neighbour] == .wall else { continue }
                } else {
                    guard grid[neighbour] == .empty else { continue }
                }
                
                visited.insert(neighbour)
                let neighbourNode = CheatCoord(
                    coord: neighbour,
                    index: node.index + 1,
                    cheatIndex: node.cheatIndex,
                    path: node.path + [neighbour]
                )
                queue.append(neighbourNode)
            }
        }
        
        for solution in solutions {
            let cost = solution.path.count - 1
            guard cost < optimalCost else { continue }
            
            let first = solution.path[index]
            let second = solution.path[index + 2]
            let savedAmount = optimalCost - cost
            saved[savedAmount, default: []].insert(Cheat(start: first, end: second))
        }
    }
    
    
    func findCheatsBFS() -> [Int: Set<Cheat>] {
        var saved: [Int: Set<Cheat>] = [:]
        
        for i in 0..<optimalCost {
            findCheatsBFS(index: i, saved: &saved)
        }
        
        return saved
    }
    
    
    func findCheatsAStar(index: Int, saved: inout [Int: Set<Cheat>]) {
        // This *almost* worked, found 41 of 44 of the sample cheats. But I couldn't make it work
        // completely.
        let pathfinder = AStar<CheatCoord> {
            $0.coord == goal
        } neighbours: {
            (node) in
            
            if node.index > optimalCost {
                return []
            }
            
            return node.coord.neighbours(scheme: .cross)
                .filter {
                    guard $0 != node.coord, grid.isInBounds($0) else { return false }
                    
                    if node.index == node.cheatIndex /* || node.index == node.cheatIndex + 1 */ {
                        return grid[$0] == .wall
                    } else {
                        return grid[$0] == .empty
                    }
                }
                .map { CheatCoord(coord: $0, index: node.index + 1, cheatIndex: node.cheatIndex) }
            
        } estimateCost: {
            $0.coord.manhattanDistance(to: goal)
        } cost: {
            (from, to) in
            
            if to.coord == goal {
                // When a cheat is done at the n-th step, we may end up with two path which are
                // both shorter than the former optimal path. We not only want the shortest of
                // these but ALL the ones that are shorter. Trick A* by adjusting the final cost
                // so they all end up having the same total cost.
                return optimalCost - to.index
            }
            
            return 1
        }
        
        let solutions = pathfinder
            .findAllPaths(start: CheatCoord(coord: start, index: 0, cheatIndex: index))
        guard let solutions else {
            return
        }
        
        for path in solutions.paths {
            let cost = path.count - 1
            guard cost < optimalCost else { continue }
            
            guard
                let first = path.first(where: { $0.cheatIndex == $0.index }),
                let second = path.first(where: { $0.cheatIndex + 2 == $0.index })
            else {
                continue
            }
            
            let savedAmount = optimalCost - cost
            saved[savedAmount, default: []].insert(Cheat(start: first.coord, end: second.coord))
        }
    }
    
    
    func findCheatsAStar() -> [Int: Set<Cheat>] {
        var saved: [Int: Set<Cheat>] = [:]
        
        for i in 0..<optimalCost {
            findCheatsAStar(index: i, saved: &saved)
        }
        
        return saved
    }
    
    
    func findCheatsBruteForce() -> [Int: Set<Cheat>] {
        var saved: [Int: Set<Cheat>] = [:]
        
        for y in 1 ..< grid.height - 1 {
            for x in 1 ..< grid.width - 1 {
                guard grid[x, y] == .wall else { continue }
                
                var modifiedGrid = grid
                modifiedGrid[x, y] = .empty
                
                let pathfinder = AStar {
                    $0 == goal
                } neighbours: {
                    $0.neighbours(scheme: .cross).filter { modifiedGrid[$0] == .empty }
                } estimateCost: {
                    $0.manhattanDistance(to: goal)
                } cost: {
                    (_, _) in
                    return 1
                }
                
                guard
                    let path = pathfinder.findPath(start: self.start),
                    path.cost < self.optimalCost,
                    let index = path.path.firstIndex(where: { $0.x == x && $0.y == y })
                else {
                    continue
                }
                
                let savedAmount = self.optimalCost - path.cost
                let cheat = Cheat(start: path.path[index - 1], end: path.path[index + 1])
                saved[savedAmount, default: []].insert(cheat)
            }
        }
        
        return saved
    }
}


runPart(.input) {
    (lines) in
    
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
    
    guard let optimalPath = pathfinder.findPath(starts: [start]) else {
        fatalError("Cannot find path")
    }
    
    let cheatFinder = CheatFinder(
        grid: grid,
        start: start,
        goal: goal,
        optimalPath: optimalPath.path,
        optimalCost: optimalPath.cost
    )
    let solutions = cheatFinder.findCheatsBruteForce()
    
    let count = solutions.reduce(0) {
        (accumulator, solution) in
        
        guard solution.key >= 100 else {
            return accumulator
        }
        
        return accumulator + solution.value.count
    }
    
    print("Part 1: \(count)")
}
