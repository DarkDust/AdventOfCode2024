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
        let edges: [(String, String)] = [
            ("a", "b"),
            ("a", "d"),
            ("a", "e"),
            ("b", "c"),
            ("b", "e"),
            ("c", "e"),
            ("d", "e")
        ]
        
        
        let result = minimumCut(vertices: vertices, edges: edges, cuts: 2)
        let mapped: [[String]] = result.map { [$0.0, $0.1] }.sorted(by: { $0[0] < $1[0] })
        #expect(mapped.count == 2)
        #expect(mapped == [["b", "c"], ["c", "e"]] || mapped == [["a", "d"], ["d", "e"]])
    }
    
}
