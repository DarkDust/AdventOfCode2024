//
//  Fixed2DArray.swift
//  AOCToolsTest
//
//  Created by Marc Haisenko on 2024-12-22.
//

import Testing
import AOCTools

struct Fixed2DArrayTests {
    
    @Test
    func enumeration() throws {
        var array = Fixed2DArray<Int>(rows: 3, columns: 2, repeating: 0)
        array[0, 0] = 1
        array[1, 0] = 2
        array[0, 1] = 3
        array[1, 1] = 4
        array[0, 2] = 5
        array[1, 2] = 6
        
        for (coord, num) in array.enumerated() {
            switch num {
            case 1: #expect(coord == Coord(x: 0, y: 0))
            case 2: #expect(coord == Coord(x: 1, y: 0))
            case 3: #expect(coord == Coord(x: 0, y: 1))
            case 4: #expect(coord == Coord(x: 1, y: 1))
            case 5: #expect(coord == Coord(x: 0, y: 2))
            case 6: #expect(coord == Coord(x: 1, y: 2))
            default: fatalError("Invalid value")
            }
        }
    }
    
}
