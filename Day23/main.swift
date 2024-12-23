//
//  main.swift
//  Day23
//
//  Created by Marc Haisenko on 2024-12-23.
//

import Foundation
import AOCTools

runPart(.input) {
    (lines) in
    
    var computers: [String: Set<String>] = [:]
    
    for line in lines {
        let parts = line.split(separator: "-")
        let computer1 = String(parts[0])
        let computer2 = String(parts[1])
        
        computers[computer1, default: []].insert(computer2)
        computers[computer2, default: []].insert(computer1)
    }
    
    var triples: Set<Set<String>> = []
    for (computer, connections) in computers {
        for two in connections {
            for three in computers[two] ?? [] where connections.contains(three) {
                triples.insert([computer, two, three])
            }
        }
    }
    
    let candidates = triples.filter {
        $0.contains(where: { $0.hasPrefix("t") })
    }
    
    print("Part 1: \(candidates.count)")
}


class Group: Hashable {
    let id = UUID()
    var members: Set<String> = []
    
    init(members: Set<String>) {
        self.members = members
    }
    
    static func == (lhs: Group, rhs: Group) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}


func mergeGroups(_ groups: [String: Group]) -> [Group] {
    var mergedGroups = groups
    
    for (_, group) in groups {
        for member in group.members {
            guard let otherGroup = mergedGroups[member] else {
                assertionFailure("Every computer must have a group")
                continue
            }
            
            guard otherGroup !== group else {
                continue
            }
            
            if otherGroup.members.isSubset(of: group.members) {
                group.members.formUnion(otherGroup.members)
                mergedGroups[member] = group
            }
        }
    }
    
    let groups = Set(mergedGroups.values)
    return Array(groups)
}

runPart(.input) {
    (lines) in
    
    var computers: [String: Set<String>] = [:]
    
    for line in lines {
        let parts = line.split(separator: "-")
        let computer1 = String(parts[0])
        let computer2 = String(parts[1])
        
        computers[computer1, default: []].insert(computer2)
        computers[computer2, default: []].insert(computer1)
    }
    
    var groups: [String: Set<Group>] = [:]
    var didGroup: Set<Set<String>> = []
    for (computer, connections) in computers {
        for two in connections {
            let check = Set([computer, two])
            guard !didGroup.contains(check) else {
                continue
            }
            
            didGroup.insert(check)
            let group = Group(members: [computer, two])
            groups[computer, default: []].insert(group)
            groups[two, default: []].insert(group)
        }
    }
    
    for (computer, connections) in computers {
        for two in connections {
            for group in groups[two] ?? [] {
                if group.members.intersection(connections).count == group.members.count {
                    group.members.insert(computer)
                    groups[computer, default: []].insert(group)
                }
            }
        }
    }
    
    let flatGroups = groups.values.flatMap { $0 }
    let largestGroup = flatGroups.max { $0.members.count < $1.members.count }!
    let password = largestGroup.members.sorted().joined(separator: ",")
    print("Part 2: \(password)")
}
