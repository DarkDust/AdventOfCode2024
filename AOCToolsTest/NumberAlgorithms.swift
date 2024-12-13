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
        
        let data2: [Coord] = [
            Coord(x: 0, y: 2), Coord(x: 1, y: 3), Coord(x: 2, y: 12), Coord(x: 5, y: 147)
        ]
        #expect(NumberAlgorithms.interpolate(sequence: data2, step: 3) == 35)
    }
    
    @Test
    func digits() {
        #expect(0.numberOfDigits == 1)
        #expect(12.numberOfDigits == 2)
        #expect(123_456.numberOfDigits == 6)
        #expect(12.concatenate(34) == 1234)
        #expect(123_456.concatenate(789) == 123456789)
    }
    
    @Test
    func cramersRule() {
        #expect(NumberAlgorithms.cramersRule(a1: 94, b1: 22, c1: 8400, a2: 34, b2: 67, c2: 5400)! == (80, 40))
    }
    
}
