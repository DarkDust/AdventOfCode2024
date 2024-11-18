//
//  Graph.swift
//  AOCToolsTest
//
//  Created by Marc Haisenko on 2024-11-12.
//

import AOCTools
import Testing

extension String: @retroactive VertexProtocol { }


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
    
}
