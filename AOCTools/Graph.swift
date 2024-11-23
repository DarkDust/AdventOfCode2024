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
