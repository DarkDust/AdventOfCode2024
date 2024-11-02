//
//  AOCToolsTest.swift
//  AOCToolsTest
//
//  Created by Marc Haisenko on 2024-11-02.
//

import Testing
import AOCTools

struct NumberAlgorithmsTests {

    @Test
    func greatestCommonDivisor() {
        #expect(3819.greatestCommonDivisor(with: 51357) == 57)
        #expect(841.greatestCommonDivisor(with: 299) == 1)
    }

    @Test
    func leastCommonMultiple() {
        #expect(10.leastCommonMultiple(with: 8) == 40)
    }
    
    @Test
    func modulo() {
        #expect(-7 % 3 == -1)
        #expect((-7).modulo(3) == 2)
        
        let a = 7
        let b = 4
        
        #expect(a.modulo(b) == 3)
        #expect((-a).modulo(b) == 1)
        #expect(a.modulo(-b) == 3)
        #expect((-a).modulo(-b) == 1)
    }
    
    @Test
    func lagrangeInterpolation() {
        let data: [(Int, Int)] = [
            (0, 2), (1, 3), (2, 12), (5, 147)
        ]
        #expect(NumberAlgorithms.interpolate(sequence: data, step: 3) == 35)
        
        let data2: [Point] = [
            Point(x: 0, y: 2), Point(x: 1, y: 3), Point(x: 2, y: 12), Point(x: 5, y: 147)
        ]
        #expect(NumberAlgorithms.interpolate(sequence: data2, step: 3) == 35)
    }
    
}
