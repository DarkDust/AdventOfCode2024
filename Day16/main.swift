//
//  main.swift
//  Day16
//
//  Created by Marc Haisenko on 2024-11-23.
//

import Foundation
import AOCTools
import Algorithms

// This is an implementation of Day 16 of 2022

enum DayError: Error {
    case invalidInput
}


struct Valve: Hashable {
    let name: String
    let flowRate: Int
    
    let connections: [String]
    
    static func parse(lines: [Substring]) throws(DayError) -> [Valve] {
        let regex = /Valve (\w+) has flow rate=(\d+); tunnel(?:s)? lead(?:s)? to valve(?:s)? ([\w, ]+)/
        
        var result: [Valve] = []
        do {
            for line in lines {
                guard let match = try regex.wholeMatch(in: line) else {
                    throw DayError.invalidInput
                }
                let name = String(match.output.1)
                let flowRate = Int(match.output.2)!
                let connections = match.output.3.components(separatedBy: ", ")
                
                result.append(Valve(name: name, flowRate: flowRate, connections: connections))
            }
        } catch {
            throw DayError.invalidInput
        }
        return result
    }
}


struct Step {
    let valve: Int
    let timeLeft: Int
    let pressureReleased: Int
    let closed: [Int]
    let path: [Int]
}


struct Cave {
    let valves: [Valve]
    let valveLookup: SymbolMap<Valve>
    let nameLookup: [String: Valve]
    let distances: DistanceMatrix
    let closed: [Int]
    
    init(lines: [Substring]) throws {
        self.valves = try Valve.parse(lines: lines)
        let nameLookup = valves.reduce(into: [:]) { $0[$1.name] = $1 }
        self.nameLookup = nameLookup
        
        var lookup = SymbolMap<Valve>()
        for valve in self.valves {
            lookup.add(valve)
        }
        self.valveLookup = lookup
        
        let edges = valves.flatMap {
            (valve) in
            let from = lookup.lookup(valve)!
            
            return valve.connections.map {
                let target = nameLookup[$0]!
                return WeightedEdge(from: from, to: lookup.lookup(target)!, weight: 1)
            }
        }
        self.distances = distanceMatrix(undirected: true, vertexCount: self.valves.count, edges: edges)
        
        // Only consider valves that aren't stuck.
        self.closed = self.valves.filter { $0.flowRate > 0 }.map { lookup.lookup($0)! }
    }
    
    
    func findSolutions(timeLeft: Int, closed: [Int]) -> [[Int]: Int] {
        let start = self.valveLookup.lookup(self.nameLookup["AA"]!)!
        var stack = [Step(
            valve: start,
            timeLeft: timeLeft,
            pressureReleased: 0,
            closed: closed,
            path: []
        )]
        var paths: [[Int]: Int] = [:]
        
        while !stack.isEmpty {
            let step = stack.removeLast()
            if step.closed.isEmpty {
                continue
            }
            
            for valve in step.closed {
                let distance = self.distances.distance(from: step.valve, to: valve)
                // Opening a valve takes a minute, need to be accounted as well.
                let nextTimeLeft = step.timeLeft - distance - 1
                guard nextTimeLeft >= 0 else {
                    continue
                }
                
                let pressureReleased = self.valveLookup[valve].flowRate * nextTimeLeft
                var nextClosed = step.closed
                let index = nextClosed.firstIndex(of: valve)!
                nextClosed.remove(at: index)
                
                let nextStep = Step(
                    valve: valve,
                    timeLeft: nextTimeLeft,
                    pressureReleased: step.pressureReleased + pressureReleased,
                    closed: nextClosed,
                    path: step.path + [valve]
                )
                
                paths.setMax(key: nextStep.path, value: nextStep.pressureReleased)
                stack.append(nextStep)
            }
        }
        
        return paths
    }
}


runPart(.input) {
    (lines) in
    
    let cave = try Cave(lines: lines)
    let paths = cave.findSolutions(timeLeft: 30, closed: cave.closed)
    let best = paths.map(\.1).max()!
    print("Part 1: \(best)")
}

runPart(.input) {
    (lines) in
    
    let cave = try Cave(lines: lines)
    let paths = cave.findSolutions(timeLeft: 26, closed: cave.closed)
    var best = 0
    
    let optimized: [Set<Int>: Int] = paths.reduce(into: [:]) {
        (result, element) in
        result.setMax(key: Set(element.key), value: element.value)
    }
    
    for combination in optimized.combinations(ofCount: 2) {
        let me = combination[0]
        let elephant = combination[1]
        guard me.key.isDisjoint(with: elephant.key) else { continue }
        
        let total = me.value + elephant.value
        if total > best {
            best = total
        }
    }
    
    print("Part 2: \(best)")
}
