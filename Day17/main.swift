//
//  main.swift
//  Day17
//
//  Created by Marc Haisenko on 2024-11-04.
//

import Foundation
import AOCTools

extension Int: @retroactive FieldProtocol {
    
    public
    static func parse(_ input: Character) -> Self? {
        Int(String(input))
    }
    
}


struct Crucible: Hashable {
    let coord: Coord
    let direction: Direction
    let steps: Int
}


enum HeatLossError: Error {
    case noPathFound
}


struct HeatLossMap {
    typealias AdvanceCrucible = (HeatLossMap, Crucible, Direction) -> Crucible?
    
    let temperatures: FieldMap<Int>
    let start: Coord
    let end: Coord
    let advance: AdvanceCrucible
    
    init(lines: [any StringProtocol], advance: @escaping AdvanceCrucible) throws {
        self.temperatures = try FieldMap<Int>(lines)
        self.start = Coord(x: 0, y: 0)
        self.end = Coord(x: temperatures.width - 1, y: temperatures.height - 1)
        self.advance = advance
    }
    
    func getNeighbours(for crucible: Crucible) -> [Crucible] {
        var neighbours: [Crucible] = []
        
        if let next = self.advance(self, crucible, crucible.direction) {
            neighbours.append(next)
        }
        
        switch crucible.direction {
        case .north, .south:
            if let next = self.advance(self, crucible, .east) {
                neighbours.append(next)
            }
            
            if let next = self.advance(self, crucible, .west) {
                neighbours.append(next)
            }
        case .east, .west:
            if let next = self.advance(self, crucible, .north) {
                neighbours.append(next)
            }
            
            if let next = self.advance(self, crucible, .south) {
                neighbours.append(next)
            }
        default:
            fatalError("Invalid direction")
        }
        
        return neighbours
    }
    
    func estimateCost(for crucible: Crucible) -> Int {
        crucible.coord.rightAngledDistance(to: self.end)
    }
    
    func cost(from: Crucible, to: Crucible) -> Int {
        self.temperatures[to.coord]
    }
    
    func evaluate() throws -> Int {
        let astar = AStar(
            neighbours: self.getNeighbours,
            estimateCost: self.estimateCost(for:),
            cost: self.cost
        )
        
        let start1 = Crucible(coord: self.start, direction: .east, steps: 0)
        let start2 = Crucible(coord: self.start, direction: .south, steps: 0)
        
        let score = astar.findPathScore(starts: [start1, start2], isGoal: { $0.coord == self.end })
        guard let score else {
            throw HeatLossError.noPathFound
        }
        
        return score
    }
    
}


runPart(.input) {
    (lines) in
    
    let map = try HeatLossMap(lines: lines) {
        (map, crucible, direction) in
        
        if crucible.direction == direction, crucible.steps >= 2 {
            return nil
        }
        
        let neighbour = map.temperatures.neighbour(for: crucible.coord, direction: direction, wrap: false)
        guard let neighbour else {
            return nil
        }
        
        return Crucible(
            coord: neighbour.coord,
            direction: direction,
            steps: crucible.direction == direction ? crucible.steps + 1 : 0
        )
    }
    
    print("Part 1: \(try map.evaluate())")
}

runPart(.input) {
    (lines) in
    
    let map = try HeatLossMap(lines: lines) {
        (map, crucible, direction) in
        
        if direction == crucible.direction, crucible.steps >= 9 {
            return nil
        }
        
        if direction != crucible.direction, crucible.steps < 3 {
            return nil
        }
        
        let neighbour = map.temperatures.neighbour(for: crucible.coord, direction: direction, wrap: false)
        guard let neighbour else {
            return nil
        }
        
        let steps = direction == crucible.direction ? crucible.steps + 1 : 0
        if neighbour.coord == map.end, steps < 4 {
            return nil
        }
        
        return Crucible(coord: neighbour.coord, direction: direction, steps: steps)
    }
    
    print("Part 2: \(try map.evaluate())")
}
