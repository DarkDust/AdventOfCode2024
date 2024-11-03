//
//  Coord.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-03.
//

import Testing
import AOCTools

struct CoordTests {
    
    @Test
    func neighbourInDirection() {
        let coord = Coord(x: 0, y: 0)
        #expect(coord.neighbour(direction: .north) == Coord(x: 0, y: -1))
        #expect(coord.north == Coord(x: 0, y: -1))
        #expect(coord.neighbour(direction: .northEast) == Coord(x: 1, y: -1))
        #expect(coord.northEast == Coord(x: 1, y: -1))
        #expect(coord.neighbour(direction: .east) == Coord(x: 1, y: 0))
        #expect(coord.east == Coord(x: 1, y: 0))
        #expect(coord.neighbour(direction: .southEast) == Coord(x: 1, y: 1))
        #expect(coord.southEast == Coord(x: 1, y: 1))
        #expect(coord.neighbour(direction: .south) == Coord(x: 0, y: 1))
        #expect(coord.south == Coord(x: 0, y: 1))
        #expect(coord.neighbour(direction: .southWest) == Coord(x: -1, y: 1))
        #expect(coord.southWest == Coord(x: -1, y: 1))
        #expect(coord.neighbour(direction: .west) == Coord(x: -1, y: 0))
        #expect(coord.west == Coord(x: -1, y: 0))
        #expect(coord.neighbour(direction: .northWest) == Coord(x: -1, y: -1))
        #expect(coord.northWest == Coord(x: -1, y: -1))
    }
    
    @Test
    func neighbours() {
        let coord = Coord(x: 0, y: 0)
        #expect(coord.neighbours(scheme: .cross)
                == [coord.north, coord.east, coord.south, coord.west])
        #expect(coord.neighbours(scheme: .diagonal)
                == [coord.northEast, coord.southEast, coord.southWest, coord.northWest])
        #expect(coord.neighbours(scheme: .box)
                == [coord.north, coord.northEast, coord.east, coord.southEast,
                    coord.south, coord.southWest, coord.west, coord.northWest])
    }
    
}
