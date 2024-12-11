//
//  NumberAlgorithms.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

import _math


public
extension FixedWidthInteger {
    
    /// Calculates the Greatest Common Divisor (GCD) of the receiver and another number.
    @inlinable
    func greatestCommonDivisor(with other: Self) -> Self {
        let remainder = self % other
        guard remainder != 0 else { return other }
        return other.greatestCommonDivisor(with: remainder)
    }
    
    /// Calculates the Least Common Multiple (LCM) of the receiver and another number.
    @inlinable
    func leastCommonMultiple(with other: Self) -> Self {
        self * (other / self.greatestCommonDivisor(with: other))
    }
    
    /// Calculate true modulo (euclidean remainder).
    ///
    /// Swift's `%` operator returns the remainder. The difference affects negative quotients:
    /// * `-7 % 3 == -1`
    /// * `(-7).modulo(3) == 2`
    @inlinable
    func modulo(_ other: Self) -> Self {
        let r = self % other
        if r >= 0 {
            return r
        }
        if other >= 0 {
            return r + other
        }
        return r - other
    }
    
    /// The number of digits in base 10.
    @inlinable
    var numberOfDigits: Int {
        // Unsigned variant
        Int(log10(Double(self))) + 1
    }
    
    /// Combines the receiver and argument as if they were strings.
    ///
    /// For example, `12.concatenate(34) == 1234`.
    @inlinable
    func concatenate(_ other: Self) -> Self {
        let digits = other.numberOfDigits
        return (self * Self(pow(10, Double(digits)))) + other
    }
}


public
extension FixedWidthInteger where Self: SignedNumeric {
    
    /// The number of digits in base 10. Not including the sign.
    @inlinable
    var numberOfDigits: Int {
        if self == 0 { return 1 }
        return Int(log10(Double(abs(self)))) + 1
    }
    
}


public
struct NumberAlgorithms {
    
    private init() { }
    
}


public
extension NumberAlgorithms {
    
    /// Calculate a Lagrange interpolation of a given input sequence.
    static func interpolate<T: FixedWidthInteger, S: Sequence<(T, T)>>(sequence: S, step: T) -> T {
        var result: Double = 0
        let xi = Double(step)
        
        for (outerIndex, (outerX, outerY)) in sequence.enumerated() {
            var term = Double(outerY)

            for (innerIndex, (innerX, _)) in sequence.enumerated() where innerIndex != outerIndex {
                term *= (xi - Double(innerX)) / (Double(outerX) - Double(innerX))
            }
            
            result += term
        }
        
        return T(result)
    }
    
    /// Calculate a Lagrange interpolation of a given input sequence.
    static func interpolate(sequence: some Sequence<Coord>, step: Int) -> Int {
        var result: Double = 0
        let xi = Double(step)
        
        for (outerIndex, outer) in sequence.enumerated() {
            var term = Double(outer.y)

            for (innerIndex, inner) in sequence.enumerated() where innerIndex != outerIndex {
                term *= (xi - Double(inner.x)) / (Double(outer.x) - Double(inner.x))
            }
            
            result += term
        }
        
        return Int(result)
    }
    
}
