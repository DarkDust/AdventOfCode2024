//
//  main.swift
//  Day8
//
//  Created by Marc Haisenko on 2024-12-08.
//

import Foundation
import AOCTools
import Algorithms

func parse(lines: [Substring]) -> (width: Int, height: Int, antennas: [Character: [Coord]]) {
    let width = lines[0].count
    let height = lines.count
    
    var antennas: [Character: [Coord]] = [:]
    for (y, line) in lines.enumerated() {
        for (x, char) in line.enumerated() {
            guard char.isNumber || char.isLetter else { continue }
            antennas[char, default: []].append(Coord(x: x, y: y))
        }
    }
    
    return (width, height, antennas)
}


runPart(.input) {
    let (width, height, antennas) = parse(lines: $0)

    var antinodes: Set<Coord> = []
    for (_, antennaCoords) in antennas {
        for coords in antennaCoords.permutations(ofCount: 2) {
            let alpha = coords[0]
            let beta = coords[1]
            let diff = beta - alpha
            antinodes.insert(beta + diff)
            antinodes.insert(alpha - diff)
        }
    }
    
    let valid = antinodes.filter {
        $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height
    }
    
    print("Part 1: \(valid.count)")
}

runPart(.input) {
    let (width, height, antennas) = parse(lines: $0)

    var antinodes: Set<Coord> = []
    func isInBounds(_ coord: Coord) -> Bool {
        return coord.x >= 0 && coord.x < width && coord.y >= 0 && coord.y < height
    }
    
    for (_, antennaCoords) in antennas {
        for coords in antennaCoords.permutations(ofCount: 2) {
            let alpha = coords[0]
            let beta = coords[1]
            let diff = beta - alpha
            
            var cursor = alpha
            while isInBounds(cursor) {
                antinodes.insert(cursor)
                cursor += diff
            }
            cursor = alpha
            while isInBounds(cursor) {
                antinodes.insert(cursor)
                cursor -= diff
            }
        }
    }
    
    print("Part 2: \(antinodes.count)")
}
