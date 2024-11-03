//
//  Coord.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

/// Coordinate with integer elements.
public
struct Coord: Hashable {
    public let x: Int
    public let y: Int
    
    public
    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
    
    public
    func _rawHashValue(seed: Int) -> Int {
        // This can have a huge impact on runtime performance of Set operations! Some runtime
        // durations from my system with AOC 2023 Day 21, part 2:
        //
        // * Swift compiler generated `Hashable`: ~2.2s
        // * x ^ y: ~1160s (!)
        // * (x * 10_000) + y: ~0.7s
        // * (x * 8_192) + y: probably >1000s
        //
        // In general, it looks like a multiplicator that's a power of 2 or is near one is bad.
        seed + (x * 1_000_000) + y
    }
    
}


// MARK: Normalization
public
extension Coord {
    
    /// Normalize coordinates given some maximum values.
    /// The resulting coordinates are thus within the range `0 ..< maxX` and `0 ..< maxY`.
    func normalized(maxX: Int, maxY: Int) -> Coord {
        Coord(x: self.x.modulo(maxX), y: self.y.modulo(maxY))
    }
    
    /// Normalize coordinates given some maximum values.
    /// The resulting coordinates are thus within the range `0 ..< maxX` and `0 ..< maxY`.
    func normalized(maximum: Coord) -> Coord {
        Coord(x: self.x.modulo(maximum.x), y: self.y.modulo(maximum.y))
    }
    
}


// MARK: Neighbours
public
extension Coord {
    
    /// How to calculate neighbouring field coordinates.
    enum NeighbourScheme {
        /// Only consider the four neighours to the north, east, south, and west.
        case cross
        
        /// Only consider the four neighours to the NE, SE, SW, and NW.
        case diagonal
        
        /// Consider the eight neighbours to the N, NE, E, SE, S, SW, W, and NW.
        case box
    }
    
    /// Get neighouring coordinates.
    ///
    /// - parameter scheme: Which coordinates to consider.
    func neighbours(scheme: NeighbourScheme) -> [Coord] {
        switch scheme {
        case .cross:
            return [
                Coord(x: self.x,     y: self.y - 1),
                Coord(x: self.x + 1, y: self.y),
                Coord(x: self.x,     y: self.y + 1),
                Coord(x: self.x - 1, y: self.y),
            ]
            
        case .diagonal:
            return [
                Coord(x: self.x + 1, y: self.y - 1),
                Coord(x: self.x + 1, y: self.y + 1),
                Coord(x: self.x - 1, y: self.y + 1),
                Coord(x: self.x - 1, y: self.y - 1),
            ]
            
        case .box:
            return [
                Coord(x: self.x,     y: self.y - 1),
                Coord(x: self.x + 1, y: self.y - 1),
                Coord(x: self.x + 1, y: self.y),
                Coord(x: self.x + 1, y: self.y + 1),
                Coord(x: self.x,     y: self.y + 1),
                Coord(x: self.x - 1, y: self.y + 1),
                Coord(x: self.x - 1, y: self.y),
                Coord(x: self.x - 1, y: self.y - 1),
            ]
        }
    }
    
    
    /// Returns the neighbour in the given direction.
    func neighbour(direction: Direction) -> Coord {
        switch direction {
        case .north: return north
        case .northEast: return northEast
        case .east: return east
        case .southEast: return southEast
        case .south: return south
        case .southWest: return southWest
        case .west: return west
        case .northWest: return northWest
        }
    }
    
    
    /// Returns the coord "above" the receiver.
    var north: Coord { Coord(x: x, y: y - 1) }
    
    /// Returns the coord "above and to the right" of the receiver.
    var northEast: Coord { Coord(x: x + 1, y: y - 1) }
    
    /// Returns the coord to the "right" of the receiver.
    var east: Coord { Coord(x: x + 1, y: y) }
    
    /// Returns the coord "below and to the right" of the receiver.
    var southEast: Coord { Coord(x: x + 1, y: y + 1) }
    
    /// Returns the coord "below" the receiver.
    var south: Coord { Coord(x: x, y: y + 1) }
    
    /// Returns the coord "below" the receiver.
    var southWest: Coord { Coord(x: x - 1, y: y + 1) }
    
    /// Returns the coord to the "left" of the receiver.
    var west: Coord { Coord(x: x - 1, y: y) }
    
    /// Returns the coord "above and to the left" of the receiver.
    var northWest: Coord { Coord(x: x - 1, y: y - 1) }

}
