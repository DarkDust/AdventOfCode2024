//
//  NumberAlgorithms.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

public
extension FixedWidthInteger {
    
    /// Calculates the Greatest Common Divisor (GCD) of the receiver and another number.
    func greatestCommonDivisor(with other: Self) -> Self {
        let remainder = self % other
        guard remainder != 0 else { return other }
        return other.greatestCommonDivisor(with: remainder)
    }
    
    /// Calculates the Least Common Multiple (LCM) of the receiver and another number.
    func leastCommonMultiple(with other: Self) -> Self {
        self * (other / self.greatestCommonDivisor(with: other))
    }
    
}
