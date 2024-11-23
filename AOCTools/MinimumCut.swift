//
//  MinimumCut.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-23.
//

import Foundation


/// Union-Find structure implementation.
/// Also called Disjoint-set data structure.
private
struct UnionFind<Vertex: VertexProtocol> {
    
    /// A node in the forest.
    struct Node {
        var parent: Vertex
        var rank: Int
        
        init(parent: Vertex, rank: Int) {
            self.parent = parent
            self.rank = rank
        }
    }
    
    /// Nodes lookup table.
    var nodes: [Vertex: Node] = [:]
    
    /// Add a vertex to the forest.
    mutating func makeSet(vertex: Vertex) {
        nodes[vertex] = Node(parent: vertex, rank: 0)
    }
    
    /// Find root of a tree.
    mutating func findSet(vertex: Vertex) -> Vertex {
        let index = nodes.index(forKey: vertex)!
        let subset = nodes.values[index]
        if subset.parent == vertex {
            return vertex
        }
        
        let parent = findSet(vertex: subset.parent)
        // Compress the path. Speeds up finding the root repeatedly.
        nodes.values[index].parent = parent
        return parent
    }
    
    /// Merge two trees.
    mutating func union(_ vertex1: Vertex, _ vertex2: Vertex) {
        let root1 = findSet(vertex: vertex1)
        let root2 = findSet(vertex: vertex2)
        
        if root1 == root2 {
            return
        }
        
        let index1 = nodes.index(forKey: root1)!
        let index2 = nodes.index(forKey: root2)!
        var subset1 = nodes.values[index1]
        var subset2 = nodes.values[index2]
        
        if subset1.rank < subset2.rank {
            (subset1, subset2) = (subset2, subset1)
        }
        
        subset2.parent = subset1.parent
        
        if subset1.rank == subset2.rank {
            subset1.rank += 1
        }
        
        nodes.values[index1] = subset1
        nodes.values[index2] = subset2
    }
    
}


/// Graph for the Karger-Stein algorithm.
private
struct KargerGraph<Vertex: VertexProtocol, Edge: EdgeProtocol> where Edge.Vertex == Vertex {
    
    /// Number of vertices left to reduce. Does not correspond to the number of vertices in the
    /// edges list.
    var vertexCount: Int
    
    /// Remaining edges.
    var edges: [Edge]
    
    /// Disjoint-set helper structure.
    var unionFind: UnionFind<Vertex>
    
    
    /// Initializer for the original graph.
    init(vertices: any Collection<Vertex>, edges: any Collection<Edge>) {
        self.vertexCount = vertices.count
        self.edges = Array(edges)
        var unionFind: UnionFind<Vertex> = UnionFind()
        for vertex in vertices {
            unionFind.makeSet(vertex: vertex)
        }
        self.unionFind = unionFind
    }
    
    
    /// Returns the edges for the minimum cut of the graph.
    mutating func minimumCut() -> [Edge] {
        var result: [Edge] = []
        for edge in self.edges {
            let root1 = self.unionFind.findSet(vertex: edge.from)
            let root2 = self.unionFind.findSet(vertex: edge.to)
            
            guard root1 != root2 else { continue }
            
            result.append(edge)
        }
        
        return result
    }
    
    
    /// Estimate how "good" a graph is. A lower score is better.
    mutating func estimateScore() -> Int {
        #if false
            // Count the number of minimum cuts.
            // The repeated `findSet` calls are costly, notably the dictionary lookup.
            var count = 0
            for edge in self.edges {
                let root1 = self.unionFind.findSet(vertex: edge.from)
                let root2 = self.unionFind.findSet(vertex: edge.to)
                guard root1 != root2 else { continue }
                
                count += 1
            }
            return count
        #else
            // Try to quickly estimate how "good" a graph is.
            var disconnected: Int = 0
            var ranks: Int = 0
            
            for (key, value) in self.unionFind.nodes {
                if value.parent == key {
                    disconnected += 1
                }
                ranks += value.rank
            }
            
            return disconnected + ranks
        #endif
    }
    
}


/// Minimum cut calculation using Karger's algorithm.
///
/// - note: This algorithm has a high _probability_ of returning the minimum number of cuts, but
///   it doesn't always do so.
public
func minimumCut<Vertex: VertexProtocol, Edge: EdgeProtocol>(
    vertices: any Collection<Vertex>,
    edges: any Collection<Edge>
) -> [Edge] where Edge.Vertex == Vertex {
    // https://en.wikipedia.org/wiki/Karger%27s_algorithm
    // This function is the `fastmincut` of the Karger-Stein algorithm.
    
#if DEBUG
    checkConsistency(vertices: vertices, edges: edges)
#endif
    
    var stack: [KargerGraph<Vertex, Edge>] = []
    stack.append(KargerGraph(vertices: vertices, edges: edges))
    var bestMinimumCut: [Edge] = Array(edges)
    
    while !stack.isEmpty {
        let graph = stack.removeLast()
        if graph.vertexCount <= 6 {
            var finalGraph = contract(graph: graph, size: 2)
            let cut = finalGraph.minimumCut()
            if cut.count < bestMinimumCut.count {
                bestMinimumCut = cut
            }
            continue
        }
        
        let size = Int(1 + (Double(graph.vertexCount) / 2.squareRoot()).rounded(.up))
        
        var candidate1 = contract(graph: graph, size: size)
        var candidate2 = contract(graph: graph, size: size)
        let score1 = candidate1.estimateScore()
        let score2 = candidate2.estimateScore()
        if score1 < score2 {
            stack.append(candidate1)
        } else {
            stack.append(candidate2)
        }
    }
    
    return bestMinimumCut
}

private
func contract<Vertex: VertexProtocol, Edge: EdgeProtocol>(
    graph: KargerGraph<Vertex, Edge>,
    size: Int
) -> KargerGraph<Vertex, Edge> where Edge.Vertex == Vertex {
    var graph = graph
    var rng = SystemRandomNumberGenerator()
    
    while graph.vertexCount > size {
        let index = rng.next(upperBound: UInt(graph.edges.count))
        let edge = graph.edges.remove(at: Int(index))
        let root1 = graph.unionFind.findSet(vertex: edge.from)
        let root2 = graph.unionFind.findSet(vertex: edge.to)
        
        guard root1 != root2 else { continue }
        
        graph.unionFind.union(root1, root2)
        graph.vertexCount -= 1
    }
    
    return graph
}


/// Minimum cut calculation using Karger's algorithm.
///
/// Applies the minimum cut algorithm until a solution with the given upper of cuts was found.
/// Useful if it's known a solution with the given number of cuts exists, and only the edges to
/// cut need to be searched.
public
func minimumCut<Vertex: VertexProtocol, Edge: EdgeProtocol>(
    vertices: any Collection<Vertex>,
    edges: any Collection<Edge>,
    cuts: Int,
    maximumIterations: Int = 1000
) -> [Edge] where Edge.Vertex == Vertex {
    let start = Date()
    for i in 0 ..< maximumIterations {
        let edges = minimumCut(vertices: vertices, edges: edges)
        if edges.count <= cuts {
            let average = Date().timeIntervalSince(start) / Double(i + 1)
            print("Took \(i + 1) attempts, average \(average) seconds per attempt.")
            return edges
        } else {
            print("\(edges.count) cuts")
        }
    }
    
    assertionFailure("No solution found with \(cuts) cuts!")
    return []
}



#if DEBUG
private
func checkConsistency<Vertex: VertexProtocol, Edge: EdgeProtocol>(
    vertices: any Sequence<Vertex>,
    edges: any Sequence<Edge>
) where Edge.Vertex == Vertex {
    var verticesSeen: Set<Vertex> = []
    
    for edge in edges {
        verticesSeen.insert(edge.from)
        verticesSeen.insert(edge.to)
        guard vertices.contains(edge.from) else {
            preconditionFailure("Invalid edge!")
        }
        guard vertices.contains(edge.to) else {
            preconditionFailure("Invalid edge!")
        }
    }
    
    let unknownVertices = Set(vertices).symmetricDifference(verticesSeen)
    precondition(unknownVertices.isEmpty, "Unknown vertex!")
}
#endif
