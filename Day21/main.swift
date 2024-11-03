//
//  main.swift
//  Day21
//
//  Created by Marc Haisenko on 2024-11-02.
//

import Foundation
import AOCTools

// Day 21 from 2023 for testing

struct Map {
    let positions: Set<Coord>
    let rocks: Set<Coord>
    let xLen: Int
    let yLen: Int
    
    init(lines: [some StringProtocol]) {
        var rocks: Set<Coord> = []
        var positions: Set<Coord> = []
        var xLen: Int = 0
        var yLen: Int = 0
        
        for (y, line) in lines.enumerated() {
            xLen = line.count
            yLen += 1
            
            for (x, char) in line.enumerated() {
                switch char {
                case "#": rocks.insert(Coord(x: x, y: y))
                case "S": positions.insert(Coord(x: x, y: y))
                default: break
                }
            }
        }
        
        self.xLen = xLen
        self.yLen = yLen
        self.rocks = rocks
        self.positions = positions
    }
    
    init (positions: Set<Coord>, rocks: Set<Coord>, xLen: Int, yLen: Int) {
        self.positions = positions
        self.rocks = rocks
        self.xLen = xLen
        self.yLen = yLen
    }
    
    func step(nextSteps: (Coord, (Coord) -> Void) -> Void) -> Map {
        var newPositions: Set<Coord> = Set(minimumCapacity: self.positions.count * 4)
        
        for position in self.positions {
            nextSteps(position) {
                let normalizedPosition = $0.normalized(maxX: self.xLen, maxY: self.yLen)
                if !self.rocks.contains(normalizedPosition) {
                    newPositions.insert($0)
                }
            }
        }
        
        return Map(positions: newPositions, rocks: rocks, xLen: xLen, yLen: yLen)
    }
    
}

runPart(.input) {
    (lines) in
    
    var map = Map(lines: lines)
    for _ in 0 ..< 64 {
        map = map.step {
            (position, push) in
            if position.x > 0 {
                push(position.left)
            }
            if position.x + 1 < map.xLen {
                push(position.right)
            }
            if position.y > 0 {
                push(position.up)
            }
            if position.y + 1 < map.yLen {
                push(position.down)
            }
        }
    }
    
    print("Part 1: \(map.positions.count)")
}

runPart(.input) {
    (lines) in
    
    var map = Map(lines: lines)
    let x1 = map.xLen / 2
    let x2 = x1 + map.xLen
    let x3 = x2 + map.xLen
    var y1 = 0
    var y2 = 0
    var y3 = 0
    
    for i in 1 ... x3 {
        map = map.step {
            (position, push) in
            push(position.left)
            push(position.right)
            push(position.up)
            push(position.down)
        }
        
        switch i {
        case x1: y1 = map.positions.count
        case x2: y2 = map.positions.count
        case x3: y3 = map.positions.count
        default: break
        }
    }
    
    let values: [(Int64, Int64)] = [(Int64(x1), Int64(y1)), (Int64(x2), Int64(y2)), (Int64(x3), Int64(y3))]
    print("Part 2: \(NumberAlgorithms.interpolate(sequence: values, step: 26501365))")
}
