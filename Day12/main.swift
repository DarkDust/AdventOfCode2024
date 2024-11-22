//
//  main.swift
//  Day12
//
//  Created by Marc Haisenko on 2024-11-21.
//

import Foundation
import AOCTools


enum DayError: Error {
    case invalidInput
}


enum SpringCondition {
    case unknown
    case operational
    case damaged
}

struct Row {
    let conditions: [SpringCondition]
    let conditionsCount: Int
    let damagedGroups: [Int]
    let damagedGroupsCount: Int
    
    init(conditions: [SpringCondition], damagedGroups: [Int]) {
        self.conditions = conditions
        self.conditionsCount = conditions.count
        self.damagedGroups = damagedGroups
        self.damagedGroupsCount = damagedGroups.count
    }
    
    init(_ input: any StringProtocol) throws {
        let parts = input.split(separator: " ")
        guard parts.count == 2 else { throw DayError.invalidInput }
        
        self.conditions = try parts[0].map {
            switch $0 {
            case ".": .operational
            case "#": .damaged
            case "?": .unknown
            default: throw DayError.invalidInput
            }
        }
        self.conditionsCount = self.conditions.count
        self.damagedGroups = try parts[1].split(separator: ",").map {
            let int = Int($0)
            guard let int else { throw DayError.invalidInput }
            return int
        }
        self.damagedGroupsCount = self.damagedGroups.count
    }
    
    var unfolded: Row {
        let unfoldedConditions = repeatElement(self.conditions, count: 5)
            .joined(separator: [.unknown])
            .compactMap(\.self)
        let unfoldedDamagedGroups = repeatElement(self.damagedGroups, count: 5)
            .flatMap(\.self)
        return Row(conditions: unfoldedConditions, damagedGroups: unfoldedDamagedGroups)
    }
    
    func countArrangements() -> Int {
        var cache: [Int: Int] = [:]
        return countArrangements(
            conditions: conditions,
            conditionsIndex: 0,
            groupIndex: 0,
            runningGroupCount: 0,
            cache: &cache
        )
    }
    
    func countArrangements(
        conditions: [SpringCondition],
        conditionsIndex: Int,
        groupIndex: Int,
        runningGroupCount: Int,
        cache: inout [Int: Int]
    ) -> Int {
        var conditionsIndex = conditionsIndex
        var groupIndex = groupIndex
        var runningGroupCount = runningGroupCount
        
        while conditionsIndex < conditionsCount {
            switch conditions[conditionsIndex] {
            case .operational:
                if runningGroupCount > 0 {
                    guard runningGroupCount == self.damagedGroups[groupIndex] else {
                        // Wrong group size, can abort this branch.
                        return 0
                    }
                    
                    // Group size matched, advance to next group.
                    runningGroupCount = 0
                    groupIndex += 1
                }
                
            case .damaged:
                runningGroupCount += 1
                if groupIndex >= self.damagedGroupsCount
                    || runningGroupCount > self.damagedGroups[groupIndex]
                {
                    // Either a damaged spring was found even though we've run out of groups, or
                    // the current group is already bigger than what's expected. Either way, the
                    // branch can be aborted.
                    return 0
                }
                
            case .unknown:
                let lookupKey = conditionsIndex * 10_000
                    + groupIndex * 100
                    + runningGroupCount
                
                if let cached = cache[lookupKey] {
                    // Have encountered this branch before, can use the cached solution.
                    return cached
                }
                
                var patched = conditions
                
                if runningGroupCount > 0, runningGroupCount == self.damagedGroups[groupIndex] {
                    // Group complete, the unknown can only be operational. Can directly
                    // advance both condition and group index.
                    patched[conditionsIndex] = .operational
                    return countArrangements(
                        conditions: patched,
                        conditionsIndex: conditionsIndex + 1,
                        groupIndex: groupIndex + 1,
                        runningGroupCount: 0,
                        cache: &cache
                    )
                    
                } else if groupIndex >= self.damagedGroupsCount {
                    // All groups complete, the unknown can only be operational. Can directly
                    // advance both condition and group index.
                    patched[conditionsIndex] = .operational
                    return countArrangements(
                        conditions: patched,
                        conditionsIndex: conditionsIndex + 1,
                        groupIndex: groupIndex + 1,
                        runningGroupCount: 0,
                        cache: &cache
                    )
                }
                
                // Both options are possible.
                var arrangements = 0
                
                patched[conditionsIndex] = .damaged
                arrangements += countArrangements(
                    conditions: patched,
                    conditionsIndex: conditionsIndex,
                    groupIndex: groupIndex,
                    runningGroupCount: runningGroupCount,
                    cache: &cache
                )
                
                patched[conditionsIndex] = .operational
                arrangements += countArrangements(
                    conditions: patched,
                    conditionsIndex: conditionsIndex,
                    groupIndex: groupIndex,
                    runningGroupCount: runningGroupCount,
                    cache: &cache
                )
                
                // Cache the branching result.
                cache[lookupKey] = arrangements
                return arrangements
            }
            
            conditionsIndex += 1
        }
        
        if runningGroupCount > 0 {
            guard runningGroupCount == self.damagedGroups[groupIndex] else {
                return 0
            }
            
            groupIndex += 1
        }
        
        if groupIndex < self.damagedGroupsCount {
            return 0
        }
        
        return 1
    }
    
}


runPart(.input) {
    (lines) in
    
    let rows = try lines.map(Row.init)
    let arrangements = rows.reduce(0, { $0 + $1.countArrangements() })
    print("Part 1: \(arrangements)")
}

runPart(.input) {
    (lines) in
    
    let rows = try lines.map { try Row($0).unfolded }
    let arrangements = rows.reduce(0, { $0 + $1.countArrangements() })
    print("Part 2: \(arrangements)")
}

