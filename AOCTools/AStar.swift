//
//  AStar.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-04.
//


/// A* path finding algorithm.
public
struct AStar<Node: Hashable> {
    
    /// Get neighbours of a given node.
    public
    let neighbours: (Node) -> [Node]
    
    /// Estimate the cost from a node to the goal.
    public
    let estimateCost: (Node) -> Int
    
    /// Get the cost from one node to another.
    public
    let cost: (Node, Node) -> Int
    
    /// Check whether a node is a goal.
    public
    let isGoal: (Node) -> Bool
    
    
    /// Designated initializer.
    ///
    /// - parameter isGoal: Check whether a node is a goal.
    /// - parameter neighbours: Get neighbours of a given node.
    /// - parameter estimateCosts: Estimate the cost from a node to the goal.
    /// - parameter cost: Get the cost from one node to another.
    public
    init(
        isGoal: @escaping (Node) -> Bool,
        neighbours: @escaping (Node) -> [Node],
        estimateCost: @escaping (Node) -> Int,
        cost: @escaping (Node, Node) -> Int
    ) {
        self.isGoal = isGoal
        self.neighbours = neighbours
        self.estimateCost = estimateCost
        self.cost = cost
    }
    
    /// Find a path using the A* algorithm.
    public
    func findPath(starts: [Node]) -> (path: [Node], cost: Int)? {
        let openSet: RedBlackTree<Int, Node> = []
        var gScore: [Node: Int] = [:]
        var fScore: [Node: Int] = [:]
        var cameFrom: [Node: Node] = [:]
        var visited: Set<Node> = []
        
        for start in starts {
            // Edge-case: start == goal.
            if isGoal(start) {
                return ([start], 0)
            }
            
            openSet.insert(0, value: start)
        }
        
        while let current = openSet.removeMinimum() {
            if isGoal(current.value) {
                // Reconstruct path
                assert(gScore[current.value] != nil)
                let path = self.reconstructPath(cameFrom: cameFrom, current: current.value)
                return (path, gScore[current.value] ?? 0)
            }
            
            visited.insert(current.value)
            
            for neighbour in self.neighbours(current.value) {
                // Avoid loops.
                guard !visited.contains(neighbour) else { continue }
                
                let tentativeGScore = gScore[current.value, default: 0]
                    + self.cost(current.value, neighbour)
                guard tentativeGScore < gScore[neighbour, default: .max] else { continue }
                
                cameFrom[neighbour] = current.value
                gScore[neighbour] = tentativeGScore
                
                let newFScore = tentativeGScore + estimateCost(neighbour)
                if let oldFScore = fScore[neighbour] {
                    if oldFScore == newFScore {
                        continue
                    }
                    
                    openSet.remove(key: oldFScore, value: neighbour)
                }
                fScore[neighbour] = newFScore
                
                openSet.insert(newFScore, value: neighbour)
            }
        }
        
        // No path found
        return nil
    }
    
    
    /// Find a path using the A* algorithm, returning the score.
    /// Faster than ``findPath(start:,isGoal:)`` since the actual path is not tracked.
    public
    func findPathScore(starts: [Node]) -> Int? {
        // NOTE: This currently also skips updating the fScore, which works for the 2023-Day17
        // scenario but might give wrong results in other scenarios.
        
        let openSet: RedBlackTree<Int, Node> = []
        var gScore: [Node: Int] = [:]
        
        for start in starts {
            openSet.insert(0, value: start)
        }
        
        while let current = openSet.removeMinimum() {
            if isGoal(current.value) {
                // Reconstruct path
                assert(gScore[current.value] != nil)
                return gScore[current.value] ?? 0
            }
            
            for neighbour in self.neighbours(current.value) {
                let tentativeGScore = gScore[current.value, default: 0]
                    + self.cost(current.value, neighbour)
                guard tentativeGScore < gScore[neighbour, default: .max] else { continue }
                
                gScore[neighbour] = tentativeGScore
                let fScore = tentativeGScore + estimateCost(neighbour)
                
                openSet.insert(fScore, value: neighbour)
            }
        }
        
        // No path found
        return nil
    }
    
    
    /// Find all optimal paths (having equal scores) using the A* algorithm.
    public
    func findAllPaths(starts: [Node]) -> (paths: [[Node]], cost: Int)? {
        let openSet: RedBlackTree<Int, Node> = []
        var gScore: [Node: Int] = [:]
        var fScore: [Node: Int] = [:]
        // Instead of tracking _the_ parent of a node, track _all_ parents of each node.
        var cameFrom: [Node: Set<Node>] = [:]
        var visited: [Node: Int] = [:]
        var bestScore: Int?
        var goals: Set<Node> = []
        
        for start in starts {
            // Edge-case: start == goal.
            if isGoal(start) {
                return ([[start]], 0)
            }
            
            openSet.insert(0, value: start)
        }
        
        while let current = openSet.removeMinimum() {
            if isGoal(current.value) {
                assert(gScore[current.value] != nil)
                let score = gScore[current.value] ?? .max
                
                if let bestScore {
                    if score > bestScore {
                        continue
                    }
                } else {
                    bestScore = gScore[current.value]
                }
                goals.insert(current.value)
                continue
            }
            
            visited[current.value] = gScore[current.value]
            
            for neighbour in self.neighbours(current.value) {
                let tentativeGScore = gScore[current.value, default: 0]
                    + self.cost(current.value, neighbour)
                if visited[neighbour, default: .max] < tentativeGScore {
                    continue
                }
                if tentativeGScore > gScore[neighbour, default: .max] { continue }
                
                cameFrom[neighbour, default: []].insert(current.value)
                gScore[neighbour] = tentativeGScore
                
                let newFScore = tentativeGScore + estimateCost(neighbour)
                if let oldFScore = fScore[neighbour] {
                    if oldFScore == newFScore {
                        continue
                    }
                    
                    openSet.remove(key: oldFScore, value: neighbour)
                }
                fScore[neighbour] = newFScore
                openSet.insert(newFScore, value: neighbour)
            }
        }
        
        if let bestScore {
            for start in starts {
                cameFrom.removeValue(forKey: start)
            }
            return (reconstructAllPaths(cameFrom: cameFrom, current: goals), bestScore)
        } else {
            // No path found
            return nil
        }
    }
}


// MARK: - Private helpers
private
extension AStar {
    
    struct FNode: Comparable, Hashable {
        let node: Node
        let fScore: Int
        
        static func < (lhs: Self, rhs: Self) -> Bool {
            lhs.fScore < rhs.fScore
        }
    }
    
    func reconstructPath(cameFrom: [Node: Node], current: Node) -> [Node] {
        var path: [Node] = [current]
        
        var cursor = current
        while let next = cameFrom[cursor] {
            path.append(next)
            cursor = next
        }
        
        return path.reversed()
    }
    
    func reconstructAllPaths(cameFrom: [Node: Set<Node>], current: Set<Node>) -> [[Node]] {
        var result: [[Node]] = []
        
        var workingPaths: [[Node]] = []
        for node in current {
            workingPaths.append([node])
        }
        
        while !workingPaths.isEmpty {
            let path = workingPaths.removeLast()
            let lastNode = path.last!
            
            if let nexts = cameFrom[lastNode] {
                for next in nexts {
                    workingPaths.append(path + [next])
                }
            } else {
                result.append(path.reversed())
            }
        }
        
        return result
    }
    
}
