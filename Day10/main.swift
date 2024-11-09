//
//  main.swift
//  Day10
//
//  Created by Marc Haisenko on 2024-11-03.
//

import Foundation
import AOCTools

// Day 10 from 2023 for testing

struct Field: OptionSet, FieldProtocol {
    let rawValue: Int
    
    static let start = Field(rawValue: 1 << 0)
    static let north = Field(rawValue: 1 << 1)
    static let east = Field(rawValue: 1 << 2)
    static let south = Field(rawValue: 1 << 3)
    static let west = Field(rawValue: 1 << 4)
    
    static func parse(_ input: Character) -> Field? {
        switch input {
        case "S": return .start
        case "|": return [.north, .south]
        case "-": return [.east, .west]
        case "L": return [.north, .east]
        case "J": return [.north, .west]
        case "7": return [.south, .west]
        case "F": return [.south, .east]
        case ".": return []
        default: return nil
        }
    }
}

extension Coord {
    
    func neighbours(for field: Field) -> [Coord] {
        if field.contains(.start) { return [] }
        var result: [Coord] = []
        if field.contains(.north) { result.append(self.north) }
        if field.contains(.east) { result.append(self.east) }
        if field.contains(.south) { result.append(self.south) }
        if field.contains(.west) { result.append(self.west) }
        return result
    }
    
}

extension FieldMap<Field> {
    
    func findStart() throws -> Coord {
        guard let start = self.first(where: { $1.contains(.start) }) else {
            throw DayError.invalidInput
        }
        
        return start.coord
    }
    
    func findPath(coord: Coord, from: Coord, path: inout [Coord]) -> Bool {
        let field = self[coord]
        
        if field.contains(.start) {
            path.append(coord)
            return true
        }
        
        for next in coord.neighbours(for: field) {
            if next == from { continue }
            
            if self.findPath(coord: next, from: coord, path: &path) {
                path.append(coord)
                return true
            }
        }
        
        return false
    }
    
}

enum DayError: Error {
    case invalidInput
}


runPart(.input) {
    (lines) in
    
    let map: FieldMap<Field> = try FieldMap(lines)
    let start = try map.findStart()
    
    for candidate in map.neighbours(for: start, scheme: .cross, wrap: false) {
        var path: [Coord] = []
        if map.findPath(coord: candidate.coord, from: start, path: &path) {
            print("Part 1: \((path.count + 1) / 2)")
            break
        }
    }
}

runPart(.input) {
    (lines) in
    
    let map: FieldMap<Field> = try FieldMap(lines)
    let start = try map.findStart()
    
    for candidate in map.neighbours(for: start, scheme: .cross, wrap: false) {
        var path: [Coord] = []
        if map.findPath(coord: candidate.coord, from: start, path: &path) {
            let pathLookup = Set(path)
            let inside = map.horizontalRaycast(countBorder: false) {
                (coord, field) in field.contains(.south) && pathLookup.contains(coord)
            } shouldCount: {
                (coord, field) in !pathLookup.contains(coord)
            }
            print("Part 2: \(inside)")
            break
        }
    }
}
