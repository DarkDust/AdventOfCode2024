//
//  Graph.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-12.
//

import Foundation

public
protocol VertexProtocol: Hashable { }


/// Edge for use with minimum cut Karger's algorithm.
private
struct MergableEdge<Vertex: VertexProtocol> {
    
    var edge: (Vertex, Vertex)
    let original: (Vertex, Vertex)
    
    init(edge: (Vertex, Vertex)) {
        self.edge = edge
        self.original = edge
    }
    
    init(edge: (Vertex, Vertex), original: (Vertex, Vertex)) {
        self.edge = edge
        self.original = original
    }
    
    func replace(victim: Vertex, survivor: Vertex) -> MergableEdge<Vertex> {
        if edge.0 == victim {
            return .init(edge: (survivor, edge.1), original: original)
        } else if edge.1 == victim {
            return .init(edge: (edge.0, survivor), original: original)
        } else {
            preconditionFailure("Invalid replacement!")
        }
    }
    
}


/// Minimum cut calculation using Karger's algorithm.
///
/// - note: This algorithm has a high _probability_ of returning the minimum number of cuts, but
///   it doesn't do so.
public
func minimumCut<Vertex: VertexProtocol>(
    vertices: any Sequence<Vertex>,
    edges: any Sequence<(Vertex, Vertex)>
) -> [(Vertex, Vertex)] {
    // https://en.wikipedia.org/wiki/Karger%27s_algorithm
    var remainingEdges = edges.map(MergableEdge.init)
    var remainingVertices = Array(vertices)
    
#if DEBUG
    checkConsistency(vertices: remainingVertices, edges: remainingEdges)
#endif
    
    var rng = SystemRandomNumberGenerator()
    while remainingVertices.count > 2 {
        let index = rng.next(upperBound: UInt(remainingEdges.count))
        contract(edgeIndex: Int(index), vertices: &remainingVertices, edges: &remainingEdges)
    }
    
    return remainingEdges.map(\.original)
}


/// Minimum cut calculation using Karger's algorithm.
///
/// Applies the minimum cut algorithm until a solution with the given upper of cuts was found.
/// Useful if it's known a solution with the given number of cuts exists, and only the edges to
/// cut need to be searched.
public
func minimumCut<Vertex: VertexProtocol>(
    vertices: any Sequence<Vertex>,
    edges: any Sequence<(Vertex, Vertex)>,
    cuts: Int,
    maximumIterations: Int = 100
) -> [(Vertex, Vertex)] {
    for _ in 0 ..< maximumIterations {
        let edges = minimumCut(vertices: vertices, edges: edges)
        if edges.count <= cuts {
            return edges
        }
    }
    
    assertionFailure("No solution found with \(cuts) cuts!")
    return []
}


#if DEBUG
private
func checkConsistency<Vertex: VertexProtocol>(
    vertices: [Vertex],
    edges: [MergableEdge<Vertex>]
) {
    var verticesSeen: Set<Vertex> = []
    
    for edge in edges {
        verticesSeen.insert(edge.edge.0)
        verticesSeen.insert(edge.edge.1)
        guard vertices.contains(edge.edge.0) else {
            preconditionFailure("Invalid edge!")
        }
        guard vertices.contains(edge.edge.1) else {
            preconditionFailure("Invalid edge!")
        }
    }
    
    let unknownVertices = Set(vertices).subtracting(verticesSeen)
    precondition(unknownVertices.isEmpty, "Unknown vertex!")
}
#endif


private
func contract<Vertex: VertexProtocol>(
    edgeIndex: Int,
    vertices: inout [Vertex],
    edges: inout [MergableEdge<Vertex>]
) {
    let edge = edges.remove(at: edgeIndex)
    let survivor = edge.edge.0
    let victim = edge.edge.1
    
    guard let victimIndex = vertices.firstIndex(of: victim) else {
        preconditionFailure("Invalid victim!")
    }
    vertices.remove(at: victimIndex)
    
    // Need to patch all connections involving the victim. If replacing the connection would
    // result in a connection from the survivor to the survivor, the connection needs to be
    // removed.
    var needReplacement: [Int] = []
    var selfReferencing: [Int] = []
    for (index, candidate) in edges.enumerated()
        where candidate.edge.0 == victim || candidate.edge.1 == victim
    {
        if candidate.edge.0 == survivor || candidate.edge.1 == survivor {
            selfReferencing.append(index)
        } else {
            needReplacement.append(index)
        }
    }
    
    for index in needReplacement {
        let replacement = edges[index].replace(victim: victim, survivor: survivor)
        edges[index] = replacement
    }
    
    for index in selfReferencing.sorted(by: >) {
        edges.remove(at: index)
    }
}
