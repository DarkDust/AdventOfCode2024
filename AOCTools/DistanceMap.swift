//
//  DistanceMap.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-23.
//

import Foundation

/// Calculates the distances between all vertices in a directed weighted graph and returns a
/// lookup "matrix".
///
/// - parameter undirected: If true, the graph is considered to be undirected and each edge is
///   treated as going both ways.
/// - parameter vertices: List of vertices.
/// - parameter edges: List of edges.
public
func distanceMatrix<Vertex: VertexProtocol, Edge: WeightedEdgeProtocol>(
    undirected: Bool,
    vertices: any Sequence<Vertex>,
    edges: any Sequence<Edge>
) -> [Vertex: [Vertex: Int]] where Edge.Vertex == Vertex {
    var distance: [Vertex: [Vertex: Int]] = [:]
    
    // Floyd–Warshall algorithm
    for edge in edges {
        let w = edge.weight
        distance[edge.from, default: [:]][edge.to] = w
        if undirected {
            distance[edge.to, default: [:]][edge.from] = w
        }
    }
    for vertex in vertices {
        distance[vertex, default: [:]][vertex] = 0
    }
    
    for k in vertices {
        for i in vertices {
            for j in vertices {
                guard let d1 = distance[i]?[k], let d2 = distance[k]?[j] else { continue }
                let length = d1 + d2
                if distance[i]?[j] ?? .max > length {
                    distance[i, default: [:]][j] = length
                }
            }
        }
    }
    
    return distance
}


/// An integer-based distance matrix.
public
struct DistanceMatrix {
    public
    let width: Int
    
    @usableFromInline internal
    let distances: [Int]
    
    /// Get the distance between two vertices.
    @inlinable public
    func distance(from: Int, to: Int) -> Int {
        return distances[(from * width) + to]
    }
}


/// Calculates the distances between all vertices in a directed weighted graph and returns a
/// lookup "matrix".
///
/// - parameter undirected: If true, the graph is considered to be undirected and each edge is
///   treated as going both ways.
/// - parameter vertexCount: Number of vertices in the graph.
/// - parameter edges: List of edges. These must reference vertices in the range from 0 to
///   `vertexCount - 1`.
public
func distanceMatrix<Edge: WeightedEdgeProtocol>(
    undirected: Bool,
    vertexCount: Int,
    edges: any Collection<Edge>
) -> DistanceMatrix where Edge.Vertex == Int {
    let width = vertexCount
    var distance = Array(repeating: Int.max, count: width * width)
    
    // Floyd–Warshall algorithm
    for edge in edges {
        let w = edge.weight
        distance[(edge.from * width) + edge.to] = w
        if undirected {
            distance[(edge.to * width) + edge.from] = w
        }
    }
    for vertex in 0 ..< width {
        distance[(vertex * width) + vertex] = 0
    }
    
    for k in 0 ..< width {
        for i in 0 ..< width {
            for j in 0 ..< width {
                let d1 = distance[(i * width) + k]
                let d2 = distance[(k * width) + j]
                guard d1 != .max, d2 != .max else { continue }
                
                let index = (i * width) + j
                let length = d1 + d2
                if distance[index] > length {
                    distance[index] = length
                }
            }
        }
    }
    
    return DistanceMatrix(width: width, distances: distance)
}
