//
//  Direction.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-03.
//

/// Movement direction.
public
enum Direction: Hashable, CaseIterable {
    
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest
    
}


public
extension Direction {
    
    /// Get all directions matching a neighbouring scheme.
    @inlinable
    static func directions(_ scheme: Coord.NeighbourScheme) -> [Direction] {
        switch scheme {
        case .cross: return [.north, .east, .south, .west]
        case .diagonal: return [.northEast, .southEast, .southWest, .northWest]
        case .box: return Direction.allCases
        }
    }
    
    /// Offset each direction is associated with.
    var stepOffset: Coord {
        switch self {
        case .north:        return Coord(x: 0, y: -1)
        case .northEast:    return Coord(x: 1, y: -1)
        case .east:         return Coord(x: 1, y: 0)
        case .southEast:    return Coord(x: 1, y: 1)
        case .south:        return Coord(x: 0, y: 1)
        case .southWest:    return Coord(x: -1, y: 1)
        case .west:         return Coord(x: -1, y: 0)
        case .northWest:    return Coord(x: -1, y: -1)
        }
    }
    
}
