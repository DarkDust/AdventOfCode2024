//
//  FieldMap+AStar.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-04.
//

import Collections


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
    
    /// Designated initializer.
    ///
    /// - parameter neighbours: Get neighbours of a given node.
    /// - parameter estimateCosts: Estimate the cost from a node to the goal.
    /// - parameter cost: Get the cost from one node to another.
    public
    init(
        neighbours: @escaping (Node) -> [Node],
        estimateCost: @escaping (Node) -> Int,
        cost: @escaping (Node, Node) -> Int
    ) {
        self.neighbours = neighbours
        self.estimateCost = estimateCost
        self.cost = cost
    }
    
    /// Find a path using the A* algorithm.
    public
    func findPath(
        starts: [Node],
        isGoal: (Node) -> Bool
    ) -> (path: [Node], cost: Int)? {
        var openSet: Deque<FNode> = []
        var gScore: [Node: Int] = [:]
        var fScore: [Node: Int] = [:]
        var cameFrom: [Node: Node] = [:]
        
        for start in starts {
            openSet.append(FNode(node: start, fScore: 0))
        }
        
        while !openSet.isEmpty {
            let current = openSet.removeFirst()
            
            if isGoal(current.node) {
                // Reconstruct path
                assert(gScore[current.node] != nil)
                let path = self.reconstructPath(cameFrom: cameFrom, current: current.node)
                return (path, gScore[current.node] ?? 0)
            }
            
            for neighbour in self.neighbours(current.node) {
                let tentativeGScore = gScore[current.node, default: 0]
                    + self.cost(current.node, neighbour)
                guard tentativeGScore < gScore[neighbour, default: .max] else { continue }
                
                cameFrom[neighbour] = current.node
                gScore[neighbour] = tentativeGScore
                
                let newFScore = tentativeGScore + estimateCost(neighbour)
                if let oldFScore = fScore[neighbour] {
                    if oldFScore == newFScore {
                        continue
                    }
                    
                    if let index = openSet.firstIndex(of: FNode(node: neighbour, fScore: oldFScore)) {
                        openSet.remove(at: index)
                    }
                }
                fScore[neighbour] = newFScore
                
                let insertion = openSet.binarySearch(predicate: { $0.fScore < newFScore })
                openSet.insert(FNode(node: neighbour, fScore: newFScore), at: insertion)
            }
        }
        
        // No path found
        return nil
    }
    
    
    /// Find a path using the A* algorithm, returning the score.
    /// Faster than ``findPath(start:,isGoal:)`` since the actual path is not tracked.
    public
    func findPathScore(
        starts: [Node],
        isGoal: (Node) -> Bool
    ) -> Int? {
        // NOTE: This currently also skips updating the fScore, which works for the 2023-Day21
        // scenario.
        
        var openSet: Heap<FNode> = []
        var gScore: [Node: Int] = [:]
        
        for start in starts {
            openSet.insert(FNode(node: start, fScore: estimateCost(start)))
        }
        
        while let current = openSet.popMin() {
            if isGoal(current.node) {
                // Reconstruct path
                assert(gScore[current.node] != nil)
                return gScore[current.node] ?? 0
            }
            
            for neighbour in self.neighbours(current.node) {
                let tentativeGScore = gScore[current.node, default: 0]
                    + self.cost(current.node, neighbour)
                guard tentativeGScore < gScore[neighbour, default: .max] else { continue }
                
                gScore[neighbour] = tentativeGScore
                let fScore = tentativeGScore + estimateCost(neighbour)
                
                openSet.insert(FNode(node: neighbour, fScore: fScore))
            }
        }
        
        // No path found
        return nil
    }
    
}


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
    
}
