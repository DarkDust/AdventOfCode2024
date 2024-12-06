//
//  Coord.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

import Foundation


/// Coordinate with integer elements.
public
struct Coord: Hashable {
    public var x: Int
    public var y: Int
    
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
    @inlinable
    func normalized(maxX: Int, maxY: Int) -> Coord {
        Coord(x: self.x.modulo(maxX), y: self.y.modulo(maxY))
    }
    
    /// Normalize coordinates given some maximum values.
    /// The resulting coordinates are thus within the range `0 ..< maxX` and `0 ..< maxY`.
    @inlinable
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
    @inlinable
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
    @inlinable
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
    @inlinable
    var north: Coord { Coord(x: x, y: y - 1) }
    
    /// Returns the coord "above and to the right" of the receiver.
    @inlinable
    var northEast: Coord { Coord(x: x + 1, y: y - 1) }
    
    /// Returns the coord to the "right" of the receiver.
    @inlinable
    var east: Coord { Coord(x: x + 1, y: y) }
    
    /// Returns the coord "below and to the right" of the receiver.
    @inlinable
    var southEast: Coord { Coord(x: x + 1, y: y + 1) }
    
    /// Returns the coord "below" the receiver.
    @inlinable
    var south: Coord { Coord(x: x, y: y + 1) }
    
    /// Returns the coord "below" the receiver.
    @inlinable
    var southWest: Coord { Coord(x: x - 1, y: y + 1) }
    
    /// Returns the coord to the "left" of the receiver.
    @inlinable
    var west: Coord { Coord(x: x - 1, y: y) }
    
    /// Returns the coord "above and to the left" of the receiver.
    @inlinable
    var northWest: Coord { Coord(x: x - 1, y: y - 1) }

}


// MARK: Distance
public
extension Coord {
    
    /// Calculate the distance between coordinates with only right-angled moves from one coordinate
    /// to the other.
    /// In other words, calculate the distance with only north, east, south, and west movements.
    @inlinable
    func rightAngledDistance(to other: Coord) -> Int {
        (max(self.x, other.x) - min(self.x, other.x)) + (max(self.y, other.y) - min(self.y, other.y))
    }
    
}


// MARK: Area
public
extension RandomAccessCollection where Element == Coord {
    
    /// Interpret the sequence as a closed polygon and calculate its area.
    /// Only works correctly for polygons with right-angles.
    func integerPolygonArea() -> Int {
        // This only works correctly for polygons with right-angles. It already fails with this
        // polygon: https://commons.wikimedia.org/wiki/File:Pick_theorem_simple.svg
        
        var area = 0
        var perimeter = 0
        let count = self.count
        for i in 0 ..< count {
            let j = (i + 1) % count
            let n1 = self[self.index(self.startIndex, offsetBy: i)]
            let n2 = self[self.index(self.startIndex, offsetBy: j)]
            area += n1.x * n2.y
            area -= n1.y * n2.x
            perimeter +=
                Int((pow(Double(n1.x - n2.x), 2) + pow(Double(n1.y - n2.y), 2)).squareRoot())
        }

        area = abs(area) / 2 // Until here, it's the Shoelace formula.
        
        // Apply Pick's theorem to get the actual area.
        area += (perimeter / 2) + 1
        return area
    }
    
}


// MARK: Arithmetic
public
extension Coord {
    
    static func + (lhs: Coord, rhs: Coord) -> Coord {
        Coord(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }
    
    static func += (lhs: inout Coord, rhs: Coord) {
        lhs.x += rhs.x
        lhs.y += rhs.y
    }
    
    static func - (lhs: Coord, rhs: Coord) -> Coord {
        Coord(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
    
    static func -= (lhs: inout Coord, rhs: Coord) {
        lhs.x -= rhs.x
        lhs.y -= rhs.y
    }
    
    static func + (lhs: Coord, rhs: Direction) -> Coord {
        lhs + rhs.stepOffset
    }
    
    static func += (lhs: inout Coord, rhs: Direction) {
        lhs += rhs.stepOffset
    }
}


// MARK: Debugging
@DebugDescription
extension Coord: CustomDebugStringConvertible {
    
    public
    var debugDescription: String {
        "(\(x), \(y))"
    }
    
}
