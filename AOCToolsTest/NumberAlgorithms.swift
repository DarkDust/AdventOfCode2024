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
    
}
