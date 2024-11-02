//
//  Point.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

/// A point with integer coordinates.
public
struct Point: Hashable, Equatable {
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
extension Point {
    
    /// Returns the point to the "left" of the receiver.
    var left: Point { Point(x: x - 1, y: y) }
    
    /// Returns the point to the "right" of the receiver.
    var right: Point { Point(x: x + 1, y: y) }
    
    /// Returns the point "above" the receiver.
    var up: Point { Point(x: x, y: y - 1) }
    
    /// Returns the point "below" the receiver.
    var down: Point { Point(x: x, y: y + 1) }
    
    /// Normalize coordinates given some maximum values.
    /// The resulting coordinates are thus within the range `0 ..< maxX` and `0 ..< maxY`.
    func normalized(maxX: Int, maxY: Int) -> Point {
        Point(x: self.x.modulo(maxX), y: self.y.modulo(maxY))
    }
    
    /// Normalize coordinates given some maximum values.
    /// The resulting coordinates are thus within the range `0 ..< maxX` and `0 ..< maxY`.
    func normalized(point: Point) -> Point {
        Point(x: self.x.modulo(point.x), y: self.y.modulo(point.y))
    }
}
