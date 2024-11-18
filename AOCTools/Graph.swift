//
//  Graph.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-12.
//

import Foundation

/// Protocol for vertices as used by graph algorithms.
public
protocol VertexProtocol: Hashable { }


/// Protocol for graphs algorithms.
///
/// Ideally, I would've like to used a simple tuple (Vertex, Vertex), but you cannot make them
/// conform to the Hashable protocol and thus can't use them in sets.
///
/// There is an accepted Swift Evolution proposal but unfortunately it didn't get implemented as
/// of Xcode 16.1.
///
/// - seealso: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0283-tuples-are-equatable-comparable-hashable.md
public
struct Edge<Vertex: VertexProtocol>: Hashable {
    
    /// from of the edge.
    public
    let from: Vertex
    
    /// to of the edge.
    public
    let to: Vertex
    
    /// Initializer.
    public
    init(from: Vertex, to: Vertex) {
        self.from = from
        self.to = to
    }
    
}


public
extension Edge {
    
    /// Whether the receiver and parameter share a vertex.
    @inlinable
    func isConnected(to other: Self) -> Bool {
        return self.from == other.from || self.to == other.to
            || self.from == other.to || self.to == other.from
    }
    
}


/// Union-Find structure implementation.
/// Also called Disjoint-set data structure.
private
struct UnionFind<Vertex: VertexProtocol> {
    
    /// A node in the forest.
    class Node {
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
    func findSet(vertex: Vertex) -> Vertex {
        let subset = nodes[vertex]!
        if subset.parent == vertex {
            return vertex
        }
        
        let parent = findSet(vertex: subset.parent)
        // Compress the path. Speeds up finding the root repeatedly.
        subset.parent = parent
        return parent
    }
    
    /// Merge two trees.
    mutating func union(_ vertex1: Vertex, _ vertex2: Vertex) {
        let root1 = findSet(vertex: vertex1)
        let root2 = findSet(vertex: vertex2)
        
        if root1 == root2 {
            return
        }
        
        var subset1 = nodes[root1]!
        var subset2 = nodes[root2]!
        
        if subset1.rank < subset2.rank {
            (subset1, subset2) = (subset2, subset1)
        }
        
        subset2.parent = subset1.parent
        
        if subset1.rank == subset2.rank {
            subset1.rank += 1
        }
    }
    
}


/// Minimum cut calculation using Karger's algorithm.
///
/// - note: This algorithm has a high _probability_ of returning the minimum number of cuts, but
///   it doesn't always do so.
public
func minimumCut<Vertex: VertexProtocol>(
    vertices: any Collection<Vertex>,
    edges: any Collection<Edge<Vertex>>
) -> [Edge<Vertex>] {
    // https://en.wikipedia.org/wiki/Karger%27s_algorithm
    
    #if DEBUG
    checkConsistency(vertices: vertices, edges: edges)
    #endif
    
    var remainingVerticesCount = vertices.count
    var unionFind: UnionFind<Vertex> = UnionFind()
    for vertex in vertices {
        unionFind.makeSet(vertex: vertex)
    }
    
    var rng = SystemRandomNumberGenerator()
    while remainingVerticesCount > 2 {
        let edge = edges.randomElement(using: &rng)!
        let root1 = unionFind.findSet(vertex: edge.from)
        let root2 = unionFind.findSet(vertex: edge.to)
        
        guard root1 != root2 else { continue }
        
        unionFind.union(root1, root2)
        remainingVerticesCount -= 1
    }
    
    var result: [Edge<Vertex>] = []
    for edge in edges {
        let root1 = unionFind.findSet(vertex: edge.from)
        let root2 = unionFind.findSet(vertex: edge.to)
        
        guard root1 != root2 else { continue }
        
        result.append(edge)
    }
    
    return result
}


/// Minimum cut calculation using Karger's algorithm.
///
/// Applies the minimum cut algorithm until a solution with the given upper of cuts was found.
/// Useful if it's known a solution with the given number of cuts exists, and only the edges to
/// cut need to be searched.
public
func minimumCut<Vertex: VertexProtocol>(
    vertices: any Collection<Vertex>,
    edges: any Collection<Edge<Vertex>>,
    cuts: Int,
    maximumIterations: Int = 100
) -> [Edge<Vertex>] {
    for i in 0 ..< maximumIterations {
        let edges = minimumCut(vertices: vertices, edges: edges)
        if edges.count <= cuts {
            print("Took \(i + 1) attempts")
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
func checkConsistency<Vertex: VertexProtocol>(
    vertices: any Sequence<Vertex>,
    edges: any Sequence<Edge<Vertex>>
) {
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
