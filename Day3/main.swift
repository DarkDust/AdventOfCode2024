//
//  main.swift
//  Day3
//
//  Created by Marc Haisenko on 2024-11-03.
//

import Foundation
import AOCTools

// Day 3 from 2023 for testing

enum Field: FieldProtocol, Equatable {
    case empty
    case star
    case otherSymbol
    case digit(Int)
    
    static func parse(_ input: Character) -> Field? {
        switch input {
        case ".": return .empty
        case "*": return .star
        case "0", "1", "2", "3", "4", "5", "6", "7", "8", "9": return .digit(Int(String(input)) ?? 0)
        default : return .otherSymbol
        }
    }
    
}

extension Field: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty: return "."
        case .star: return "*"
        case .otherSymbol: return "#"
        case .digit(let digit): return String(digit)
        }
    }
}


runPart(.input) {
    (lines) in
    
    let map: FieldMap<Field> = try FieldMap(lines)
    var number = 0
    var hasSymbolNeighbour = false
    var numbers: [Int] = []
    
    for (coord, field) in map {
        switch field {
        case .empty, .star, .otherSymbol:
            if number > 0, hasSymbolNeighbour {
                numbers.append(number)
            }
            number = 0
            hasSymbolNeighbour = false
            
        case .digit(let digit):
            number *= 10
            number += digit
            
            hasSymbolNeighbour = hasSymbolNeighbour
                || map.neighbours(for: coord, scheme: .box, wrap: false)
                    .contains(where: { $0.1 == .star || $0.1 == .otherSymbol })
        }
    }
    
    if number > 0, hasSymbolNeighbour {
        numbers.append(number)
    }
    print("Part 1: \(numbers.reduce(0, +))")
}

runPart(.input) {
    (lines) in
    
    let map: FieldMap<Field> = try FieldMap(lines)
    var number = 0
    var starCoordinates: Coord?
    var gears: [Coord: [Int]] = [:]
    
    for (coord, field) in map {
        switch field {
        case .empty, .star, .otherSymbol:
            if number > 0, let starCoordinates {
                gears[starCoordinates, default: []].append(number)
            }
            
            number = 0
            starCoordinates = nil
            
        case .digit(let digit):
            number *= 10
            number += digit
            
            starCoordinates = starCoordinates
                ?? map.neighbours(for: coord, scheme: .box, wrap: false)
                    .first(where: { $0.1 == .star })
                    .map { $0.0 }
        }
    }
    
    if number > 0, let starCoordinates {
        gears[starCoordinates, default: []].append(number)
    }
    
    let ratios = gears.values.map {
        $0.count == 2 ? $0.reduce(1, *) : 0
    }
    
    print("Part 2: \(ratios.reduce(0, +))")
}
