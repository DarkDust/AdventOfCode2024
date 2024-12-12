//
//  main.swift
//  Day12
//
//  Created by Marc Haisenko on 2024-12-12.
//

import Foundation
import AOCTools

struct Corner: OptionSet {
    let rawValue: Int
    
    static let topLeft = Corner(rawValue: 1 << 0)
    static let bottomLeft = Corner(rawValue: 1 << 1)
    static let bottomRight = Corner(rawValue: 1 << 2)
    static let topRight = Corner(rawValue: 1 << 3)
}


struct Shape {
    let field: Character
    var coords: Set<Coord> = []
    var perimeter: Int = 0
    
    var price: Int {
        coords.count * perimeter
    }
    
    var discoutedPrice: Int {
        coords.count * countSides()
    }
    
    mutating func add(_ coord: Coord) {
        guard !coords.contains(coord) else { return }
        
        coords.insert(coord)
        perimeter += 4
        for neighbour in coord.neighbours(scheme: .cross) where coords.contains(neighbour) {
            perimeter -= 2
        }
    }
    
    func countSides() -> Int {
        var corners: [Coord: Corner] = [:]
        
        // For each coordinate, determine the corners. Treats each coordinates as a rectangle
        // (x, y) to (x + 1, y + 1).
        for coordinate in coords {
            corners[coordinate, default: []].insert(.topLeft)
            corners[coordinate.east, default: []].insert(.topRight)
            corners[coordinate.south, default: []].insert(.bottomLeft)
            corners[coordinate.south.east, default: []].insert(.bottomRight)
        }
        
        // Count all corners that are not part of a straight line or an inner part.
        let mapped = corners.map {
            switch $0.value {
            case [.topLeft, .bottomLeft, .bottomRight, .topRight]:
                // Inner
                return 0
                
            case [.topLeft, .bottomLeft]:
                // Straight left
                return 0
                
            case [.topLeft, .topRight]:
                // Straight top
                return 0
                
            case [.topRight, .bottomRight]:
                // Straight right
                return 0
                
            case [.bottomLeft, .bottomRight]:
                // Straight bottom
                return 0
                
            case [.topLeft, .bottomRight]:
                // Diagonal
                return 2
                
            case [.topRight, .bottomLeft]:
                // Diagonal
                return 2
                
            default:
                return 1
            }
        }
        
        return mapped.reduce(0, +)
    }
    
    func countSidesAlt() -> Int {
        // This was my first solution. It works on all samples, but not on the actual input. 😡
        let horizontal = countSides(directions: { ($0.east, $0.west) }, consecutive: { ($0.north, $0.south) })
        let vertical = countSides(directions: { ($0.north, $0.south) }, consecutive: { ($0.east, $0.west) })
        return horizontal + vertical
    }
    
    private
    func countSides(directions: (Coord) -> (Coord, Coord), consecutive: (Coord) -> (Coord, Coord)) -> Int {
        var outsides: [Coord: Int] = [:]
        var sides: Int = 0
        
        func increase(_ coord: Coord) {
            outsides[coord, default: 0] += 1
        }
        func decrease(_ coord: Coord, count: Int = 1) {
            outsides[coord, default: 0] -= count
            if outsides[coord, default: 0] <= 0 {
                outsides.removeValue(forKey: coord)
            }
        }
        
        // Add all coordinates next to each shape coordinate in one direction.
        for coord in coords {
            let next = directions(coord)
            increase(next.0)
            increase(next.1)
        }
        // Remove the shape coordinates themselves again.
        for coord in coords {
            decrease(coord, count: 2)
        }
        
        while let start = outsides.keys.first {
            sides += 1
            
            var candidates: [Coord] = []
            var visited: Set<Coord> = [start]
            let next = consecutive(start)
            candidates.append(next.0)
            candidates.append(next.1)
            
            // Find all consecutive coordinates of the outline.
            while let candidate = candidates.popLast() {
                guard outsides[candidate, default: 0] > 0, !visited.contains(candidate) else {
                    continue
                }
                
                visited.insert(candidate)
                
                let next = consecutive(candidate)
                candidates.append(next.0)
                candidates.append(next.1)
            }
            
            // Decrease/remove all of those consecutive coordinates.
            for coord in visited {
                decrease(coord)
            }
        }
        
        return sides
    }
}


func parse(_ lines: [Substring]) throws -> [Shape] {
    let map = try FieldMap<Character>(lines)
    var processed: Set<Coord> = []
    var shapes: [Shape] = []
    
    for (coord, field) in map {
        if processed.contains(coord) { continue }
        
        var shape = Shape(field: field)
        
        var candidates = [coord]
        while let candidate = candidates.popLast() {
            guard map.isInBounds(candidate), !shape.coords.contains(candidate), map[candidate] == field else {
                continue
            }
            shape.add(candidate)
            candidates.append(contentsOf: candidate.neighbours(scheme: .cross))
        }
        
        processed.formUnion(shape.coords)
        shapes.append(shape)
    }
    
    return shapes
}


runPart(.input) {
    (lines) in
    
    let shapes = try parse(lines)
    let sum = shapes.reduce(0) { $0 + $1.price }
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    let shapes = try parse(lines)
    let sum = shapes.reduce(0) { $0 + $1.discoutedPrice }
    print("Part 2: \(sum)")
}
