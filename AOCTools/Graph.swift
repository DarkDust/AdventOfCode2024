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


/// Protocol for edges as used by graph algorithms.
public
protocol EdgeProtocol: Hashable {
    associatedtype Vertex: VertexProtocol
    
    /// Start of the edge.
    var from: Vertex { get }
    
    /// End of the edge.
    var to: Vertex { get }
}


/// Protocol of weighted edges as used by graph algorithms.
public
protocol WeightedEdgeProtocol: EdgeProtocol {
    
    /// Weight of the edge.
    var weight: Int { get }
}


/// Edge for graph algorithms.
///
/// Ideally, I would've like to used a simple tuple (Vertex, Vertex), but you cannot make them
/// conform to the Hashable protocol and thus can't use them in sets.
///
/// There is an accepted Swift Evolution proposal but unfortunately it didn't get implemented as
/// of Xcode 16.1.
///
/// - seealso: https://github.com/swiftlang/swift-evolution/blob/main/proposals/0283-tuples-are-equatable-comparable-hashable.md
public
struct Edge<Vertex: VertexProtocol>: EdgeProtocol {
    
    /// Start of the edge.
    public
    let from: Vertex
    
    /// End of the edge.
    public
    let to: Vertex
    
    /// Initializer.
    public
    init(from: Vertex, to: Vertex) {
        self.from = from
        self.to = to
    }
    
}


/// Weighted edge for graph algorithms.
public
struct WeightedEdge<Vertex: VertexProtocol>: WeightedEdgeProtocol {
    
    /// Start of the edge.
    public
    let from: Vertex
    
    /// End of the edge.
    public
    let to: Vertex
    
    /// Weight of the edge.
    public
    let weight: Int
    
    /// Initializer.
    public
    init(from: Vertex, to: Vertex, weight: Int) {
        self.from = from
        self.to = to
        self.weight = weight
    }
    
}


public
extension EdgeProtocol {
    
    /// Whether the receiver and parameter share a vertex.
    @inlinable
    func isConnected(to other: Self) -> Bool {
        return self.from == other.from || self.to == other.to
            || self.from == other.to || self.to == other.from
    }
    
}


extension String: VertexProtocol { }
extension Int: VertexProtocol { }
