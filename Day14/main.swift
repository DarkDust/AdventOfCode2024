//
//  main.swift
//  Day14
//
//  Created by Marc Haisenko on 2024-12-14.
//

import Foundation
import AOCTools

enum DayError: Error {
    case invalidInput
}

struct Robot {
    let position: Coord
    let velocity: Coord
    
    func isInQuadrant(_ quadrant: Quadrant) -> Bool {
        return self.position.x >= quadrant.start.x
            && self.position.x < quadrant.end.x
            && self.position.y >= quadrant.start.y
            && self.position.y < quadrant.end.y
    }
}

struct Quadrant {
    let start: Coord
    let end: Coord
    
    init(start: Coord, dimensions: Coord) {
        self.start = start
        self.end = start + dimensions
    }
}

struct Grid {
    let dimensions: Coord
    let robots: [Robot]
    
    func move(robot: Robot, steps: Int) -> Robot {
        let newPosition = robot.position + robot.velocity * steps
        return Robot(position: newPosition.normalized(maximum: self.dimensions), velocity: robot.velocity)
    }
    
    func dump() -> Bool {
        let occupied: Set<Coord> = self.robots.reduce(into: []) { $0.insert($1.position) }
        // After wasting a lot of time hunting for (non-existing) bugs in my code, I turned to
        // Reddit to quickly learn that:
        // a) Apart from part 1, there is no constraint on the number of steps in part 2! I was
        //    assuming that the image forms withing the 100 steps.
        // b) And that's the spoiler: when the image forms, each robot is in a unique position.
        guard occupied.count == self.robots.count else {
            return false
        }
        
        for y in 0..<self.dimensions.y {
            for x in 0..<self.dimensions.x {
                print(occupied.contains(Coord(x: x, y: y)) ? "#" : ".", terminator: "")
            }
            print()
        }
        return true
    }
}


func parse(lines: [Substring], width: Int, height: Int) throws -> Grid {
    let regex = /p=(-?\d+),(-?\d+) v=(-?\d+),(-?\d+)/
    let robots = try lines.map {
        guard
            let match = try regex.firstMatch(in: $0),
            let x = Int(match.output.1),
            let y = Int(match.output.2),
            let vx = Int(match.output.3),
            let vy = Int(match.output.4)
        else {
            throw DayError.invalidInput
        }
        
        return Robot(position: Coord(x: x, y: y), velocity: Coord(x: vx, y: vy))
    }
    
    return Grid(dimensions: Coord(x: width, y: height), robots: robots)
}


runPart(.input) {
    (lines) in
    
    let steps = 100
    let grid = try parse(lines: lines, width: 101, height: 103)
    let futureGrid = Grid(
        dimensions: grid.dimensions,
        robots: grid.robots.map { grid.move(robot: $0, steps: steps) }
    )
    
    let quadrantSize = Coord(x: grid.dimensions.x / 2, y: grid.dimensions.y / 2)
    let quadrant1 = Quadrant(start: Coord(x: 0, y: 0), dimensions: quadrantSize)
    let quadrant2 = Quadrant(start: Coord(x: grid.dimensions.x - quadrantSize.x, y: 0), dimensions: quadrantSize)
    let quadrant3 = Quadrant(start: Coord(x: 0, y: grid.dimensions.y - quadrantSize.y), dimensions: quadrantSize)
    let quadrant4 = Quadrant(start: Coord(
        x: grid.dimensions.x - quadrantSize.x,
        y: grid.dimensions.y - quadrantSize.y
    ), dimensions: quadrantSize)
    
    let quadrants: [Quadrant] = [quadrant1, quadrant2, quadrant3, quadrant4]
    let safetyScore = quadrants.map {
        (quadrant) in
        return futureGrid.robots.filter { $0.isInQuadrant(quadrant) }.count
    }.reduce(1, *)
    
    print("Part 1: \(safetyScore)")
}

runPart(.input) {
    (lines) in
    
    let steps = 100_000
    let grid = try parse(lines: lines, width: 101, height: 103)
    
    for i in 1...steps {
        let futureGrid = Grid(
            dimensions: grid.dimensions,
            robots: grid.robots.map { grid.move(robot: $0, steps: i) }
        )

        if futureGrid.dump() {
            print("Step \(i):")
            return
        }
    }
    
}
