//
//  Geometry.swift
//  AOCToolsTest
//
//  Created by Marc Haisenko on 2024-11-11.
//

import AOCTools
import Testing
import Foundation


struct GeometryTests {
    
    @Test
    func lineIntersection() {
        let p1 = CGPoint(x: 0, y: -9)
        let p2 = CGPoint(x: 1, y: -7)
        let p2Alt = CGPoint(x: 5, y: 1)
        let p3 = CGPoint(x: 1, y: -1)
        let p4 = CGPoint(x: 2, y: -2)
        let p4Alt = CGPoint(x: 5, y: -5)
        
        let line1 = FloatLine(start: p1, end: p2)
        let line1Long = FloatLine(start: p1, end: p2Alt)
        let line2 = FloatLine(start: p3, end: p4)
        let line2Long = FloatLine(start: p3, end: p4Alt)
        
        let ip = CGPoint(x: 3, y: -3)
        
        // Lines
        for (a, b) in [(line1, line2), (line1, line2Long), (line1Long, line2), (line1Long, line2Long)] {
            #expect(a.intersection(with: b, segments: false)?.isApproximatelyEqual(to: ip) ?? false)
        }
        
        // Line segments
        #expect(line1Long.intersection(with: line2Long, segments: true)?.isApproximatelyEqual(to: ip) ?? false)
        for (a, b) in [(line1, line2), (line1, line2Long), (line1Long, line2)] {
            #expect(a.intersection(with: b, segments: true) == nil)
        }
        
        // Parallel lines
        let p5 = CGPoint(x: p1.x + 1, y: p1.y)
        let p6 = CGPoint(x: p2.x + 1, y: p2.y)
        let line3 = FloatLine(start: p5, end: p6)
        #expect(line1.intersection(with: line3, segments: false) == nil)
    }
}
