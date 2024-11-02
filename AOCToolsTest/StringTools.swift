//
//  StringTools.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

import Testing
import AOCTools

struct StringToolsTests {
    
    @Test
    func droppingFromStart() {
        let result = "abcd".droppingFromStart()
        #expect(result.map { $0 } == ["abcd", "bcd", "cd", "d"])
    }
    
}
