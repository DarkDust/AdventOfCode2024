//
//  Input.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

/// Defines which input to process.
public
enum Input: Sendable {
    /// Main puzzle input. Given via `input.txt` in the day's source directory.
    case input
    
    /// Sample input for party 1. Given via `sample1.txt` in the day's source directory.
    case sample1
    
    /// Sample input for party 2. Given via `sample2.txt` in the day's source directory.
    case sample2
}


internal
extension Input {
    
    /// String value of the input.
    var string: String {
        switch self {
        case .input: return getEmbeddedString("aocinput")
        case .sample1: return getEmbeddedString("aocsample1")
        case .sample2: return getEmbeddedString("aocsample2")
        }
    }
    
}
