//
//  Coord.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

/// Coordinate with integer elements.
public
struct Coord: Hashable, Equatable {
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


public
extension Coord {
    
    /// Returns the coord to the "left" of the receiver.
    var left: Coord { Coord(x: x - 1, y: y) }
    
    /// Returns the coord to the "right" of the receiver.
    var right: Coord { Coord(x: x + 1, y: y) }
    
    /// Returns the coord "above" the receiver.
    var up: Coord { Coord(x: x, y: y - 1) }
    
    /// Returns the coord "below" the receiver.
    var down: Coord { Coord(x: x, y: y + 1) }
    
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
