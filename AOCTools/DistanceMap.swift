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
