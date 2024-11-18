//
//  main.swift
//  Day25
//
//  Created by Marc Haisenko on 2024-11-18.
//

import Foundation
import AOCTools

extension String: @retroactive VertexProtocol { }


func countGroups(in edges: Set<Edge<String>>) -> [Int] {
    var edgesToCheck = edges
    var groupLengths: [Int] = []
    
    while !edgesToCheck.isEmpty {
        let edge = edgesToCheck.removeFirst()
        var stack: [Edge<String>] = [edge]
        var group: Set<String> = []
        
        while !stack.isEmpty {
            let edge = stack.removeLast()
            edgesToCheck.remove(edge)
            
            group.insert(edge.from)
            group.insert(edge.to)
            
            for candidate in edgesToCheck where candidate.isConnected(to: edge) {
                stack.append(candidate)
            }
        }
        
        groupLengths.append(group.count)
    }
    
    return groupLengths
}


runPart(.input) {
    (lines) in
    
    var vertices: Set<String> = []
    var edges: Set<Edge<String>> = []
    
    func addEdge(from: String, to: String) {
        vertices.insert(from)
        vertices.insert(to)
        if from < to {
            edges.insert(Edge(from: from, to: to))
        } else {
            edges.insert(Edge(from: to, to: from))
        }
    }
    
    for line in lines {
        let parts = line.split(separator: ": ")
        let from = String(parts[0])
        for to in parts[1].split(separator: .whitespace) {
            addEdge(from: from, to: String(to))
        }
    }
    
    let cuts = minimumCut(vertices: Array(vertices), edges: Array(edges), cuts: 3)
    edges.subtract(cuts)
    let groupLengths = countGroups(in: edges)
    let score = groupLengths.reduce(1, *)
    print("Part 1: \(score)")
}

