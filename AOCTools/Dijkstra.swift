//
//  Dijkstra.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-12-20.
//

import Foundation

/// Dijkstra's path finding algorithm.
public
struct Dijkstra<Node: Hashable> {
    
    /// Get neighbours of a given node.
    public
    let neighbours: (Node) -> [Node]
    
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
    /// - parameter cost: Get the cost from one node to another.
    public
    init(
        isGoal: @escaping (Node) -> Bool,
        neighbours: @escaping (Node) -> [Node],
        cost: @escaping (Node, Node) -> Int
    ) {
        self.isGoal = isGoal
        self.neighbours = neighbours
        self.cost = cost
    }
    
    
    /// Find an optimal path using Djikstra's algorithm.
    public
    func findPath(start: Node) -> (path: [Node], cost: Int)? {
        let queue = RedBlackTree<Int, Node>()
        
        var distances: [Node: Int] = [:]
        var previous: [Node: Node] = [:]
        var bestDistance: Int?
        var goal: Node?
        
        distances[start] = 0
        queue.insert(0, value: start)
        
        while let entry = queue.removeMinimum() {
            if isGoal(entry.value) {
                bestDistance = entry.key
                goal = entry.value
                break
            }
            
            for neighbour in neighbours(entry.value) {
                let alt = distances[entry.value]! + cost(entry.value, neighbour)
                let oldDistance = distances[neighbour, default: .max]
                guard alt < oldDistance else { continue }
                
                previous[neighbour] = entry.value
                distances[neighbour] = alt
                
                queue.insert(alt, value: neighbour)
            }
        }
        
        guard let bestDistance, let goal else { return nil }
        return (reconstructPath(cameFrom: previous, current: goal), bestDistance)
    }
    
    
    /// Find all optimal paths (having equal scores) using Djikstra's algorithm.
    public
    func findAllPaths(start: Node) -> (paths: [[Node]], cost: Int)? {
        let queue = RedBlackTree<Int, Node>()
        
        var distances: [Node: Int] = [:]
        var previous: [Node: Set<Node>] = [:]
        var bestDistance: Int?
        var goals: Set<Node> = []
        
        distances[start] = 0
        queue.insert(0, value: start)
        
        while let entry = queue.removeMinimum() {
            if isGoal(entry.value) {
                if let currentBestDistance = bestDistance {
                    if entry.key == currentBestDistance {
                        // New solution of equal distance. Continue.
                        goals.insert(entry.value)
                        continue
                    } else {
                        // New solution is more costly. Stop.
                        break
                    }
                    
                } else {
                    bestDistance = entry.key
                    goals.insert(entry.value)
                    continue
                }
            }
            
            for neighbour in neighbours(entry.value) {
                let alt = distances[entry.value]! + cost(entry.value, neighbour)
                let oldDistance = distances[neighbour, default: .max]
                guard alt <= oldDistance else { continue }
                
                previous[neighbour, default: []].insert(entry.value)
                distances[neighbour] = alt
                
                queue.insert(alt, value: neighbour)
            }
        }
        
        guard let bestDistance else { return nil }
        return (reconstructAllPaths(cameFrom: previous, current: goals), bestDistance)
    }
}


// MARK: - Private helpers
private
extension Dijkstra {
    
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
