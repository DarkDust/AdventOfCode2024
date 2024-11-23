//
//  Graph.swift
//  AOCToolsTest
//
//  Created by Marc Haisenko on 2024-11-12.
//

import AOCTools
import Testing


struct GraphTests {
    
    @Test
    func minumumCut() {
        let vertices = ["a", "b", "c", "d", "e"]
        let edges: [Edge<String>] = [
            Edge(from: "a", to: "b"),
            Edge(from: "a", to: "d"),
            Edge(from: "a", to: "e"),
            Edge(from: "b", to: "c"),
            Edge(from: "b", to: "e"),
            Edge(from: "c", to: "e"),
            Edge(from: "d", to: "e")
        ]
        
        
        let result = minimumCut(vertices: vertices, edges: edges, cuts: 2)
        let mapped: [[String]] = result.map { [$0.from, $0.to] }.sorted(by: { $0[0] < $1[0] })
        #expect(mapped.count == 2)
        #expect(mapped == [["b", "c"], ["c", "e"]] || mapped == [["a", "d"], ["d", "e"]])
    }
    
    @Test
    func distanceMatrix() {
        // https://en.wikipedia.org/wiki/Floyd–Warshall_algorithm#Example
        // I've replaced the vertex numbers with letters.
        let vertices = ["a", "b", "c", "d"]
        let edges: [WeightedEdge<String>] = [
            WeightedEdge(from: "a", to: "c", weight: -2),
            WeightedEdge(from: "b", to: "a", weight: 4),
            WeightedEdge(from: "b", to: "c", weight: 3),
            WeightedEdge(from: "c", to: "d", weight: 2),
            WeightedEdge(from: "d", to: "b", weight: -1),
        ]
        
        let matrix = AOCTools.distanceMatrix(undirected: false, vertices: vertices, edges: edges)
        #expect(matrix["a"]?["d"] == 0)
        #expect(matrix["d"]?["a"] == 3)
        #expect(matrix["d"]?["d"] == 0)
        #expect(matrix["a"]?["b"] == -1)
        
        
        // A -5- B
        // |     |
        // 3     4
        // |     |
        // C -2- D
        let edges2: [WeightedEdge<String>] = [
            WeightedEdge(from: "a", to: "b", weight: 5),
            WeightedEdge(from: "a", to: "c", weight: 3),
            WeightedEdge(from: "b", to: "d", weight: 4),
            WeightedEdge(from: "c", to: "d", weight: 2),
        ]
        
        let matrix2 = AOCTools.distanceMatrix(undirected: true, vertices: vertices, edges: edges2)
        #expect(matrix2["a"]?["d"] == 5)
        #expect(matrix2["a"]?["c"] == 3)
        #expect(matrix2["c"]?["b"] == 6)
    }
    
}
