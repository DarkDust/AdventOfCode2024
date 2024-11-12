//
//  Geometry.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-10.
//

import Foundation


public
extension CGPoint {
    
    /// Initialize using a ``Coord``.
    @inlinable
    init(coord: Coord) {
        self.init(x: Double(coord.x), y: Double(coord.y))
    }
    
    /// Tests whether the coordinates of two points are equal within a given accuracy.
    @inlinable
    func isApproximatelyEqual(to other: CGPoint, accuracy: CGFloat = 0.0001) -> Bool {
        return abs(x - other.x) < accuracy && abs(y - other.y) < accuracy
    }
    
}


public
extension Coord {
    
    /// Initialize using a `CGPoint`.
    ///
    /// - parameter point: The point to convert.
    /// - parameter rule: How to round the point values.
    @inlinable
    init(_ point: CGPoint, rounding rule: FloatingPointRoundingRule) {
        self.init(
            x: Int(point.x.rounded(rule)),
            y: Int(point.x.rounded(rule))
        )
    }
    
}


/// A line with floating point coordinates.
public
struct FloatLine {
    
    /// Start point of the line.
    public
    let start: CGPoint
    
    /// End point of the line.
    public
    let end: CGPoint
    
    
    /// Initialize with two points.
    public
    init(start: CGPoint, end: CGPoint) {
        self.start = start
        self.end = end
    }
    
    
    /// Initialize with the integer coordinates.
    public
    init(start: Coord, end: Coord) {
        self.start = CGPoint(coord: start)
        self.end = CGPoint(coord: end)
    }
    
}


public
extension FloatLine {
    
    /// Calculate the intersection of the receiver and another line.
    ///
    /// - parameter other: Line to calculate intersection with.
    /// - parameter segments: Whether to consider the two lines to be infinite (`false`) or to be
    ///   line segments (`true`).
    func intersection(with other: FloatLine, segments: Bool) -> CGPoint? {
        let x1Mx2 = self.start.x - self.end.x
        let x3Mx4 = other.start.x - other.end.x
        let y1My2 = self.start.y - self.end.y
        let y3My4 = other.start.y - other.end.y
        
        let denom = (x1Mx2 * y3My4) - (y1My2 * x3Mx4)
        guard denom != 0 else {
            // Lines are parallel.
            return nil
        }
        
        if segments {
            // Line segments.
            // https://en.wikipedia.org/wiki/Line–line_intersection#Given_two_points_on_each_line_segment
            let x1Mx3 = self.start.x - other.start.x
            let y1My3 = self.start.y - other.start.y
            
            let tNum = (x1Mx3 * y3My4) - (y1My3 * x3Mx4)
            let t = tNum / denom
            
            let uNum = (x1Mx2 * y1My3) - (y1My2 * x1Mx3)
            let u = -(uNum / denom)
            
            guard t >= 0, t <= 1, u >= 0, u <= 1 else {
                return nil
            }
            
            return CGPoint(
                x: self.start.x + (t * (self.end.x - self.start.x)),
                y: self.start.y + (t * (self.end.y - self.start.y))
            )
            
        } else {
            // Infinite lines.
            // https://en.wikipedia.org/wiki/Line–line_intersection#Given_two_points_on_each_line
            let partSelf = (self.start.x * self.end.y) - (self.start.y * self.end.x)
            let partOther = (other.start.x * other.end.y) - (other.start.y * other.end.x)
            
            let px = (partSelf * x3Mx4) - (partOther * x1Mx2)
            let py = (partSelf * y3My4) - (partOther * y1My2)
            return CGPoint(x: px / denom, y: py / denom)
        }
    }
    
}

