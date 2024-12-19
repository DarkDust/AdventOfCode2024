//
//  main.swift
//  Day17
//
//  Created by Marc Haisenko on 2024-12-19.
//

import Foundation
import AOCTools
import RegexBuilder


enum VMError: Error {
    case invalidOpcode
    case invalidOperand
    case abort
}

struct VM {
    var rom: [Int] = []
    
    var instructionPointer: Int = 0
    var registerA: Int64 = 0
    var registerB: Int64 = 0
    var registerC: Int64 = 0
    
    var print: (Int) throws(VMError) -> Void
    
    func comboOperand(_ operand: Int) throws(VMError) -> Int64 {
        switch operand {
        case 0, 1, 2, 3: return Int64(operand)
        case 4: return registerA
        case 5: return registerB
        case 6: return registerC
        default: throw .invalidOperand
        }
    }
    
    mutating func run() throws(VMError) {
        while self.instructionPointer >= 0, self.instructionPointer < rom.count - 1 {
            let opcode = rom[self.instructionPointer]
            let operand = rom[self.instructionPointer + 1]
            
            try Opcode(opcode).execute(operand: operand, vm: &self)
        }
    }
    
}

enum OperandType {
    case literal
    case combo
}

struct Opcode {
    let rawValue: Int
    
    init(_ rawValue: Int) {
        self.rawValue = rawValue
    }
    
    var name: String {
        switch rawValue {
        case 0: return "adv"
        case 1: return "bxl"
        case 2: return "bst"
        case 3: return "jnz"
        case 4: return "bxc"
        case 5: return "out"
        case 6: return "bdv"
        case 7: return "cdv"
        default: return "invalid(\(self))"
        }
    }
    
    func execute(operand: Int, vm: inout VM) throws(VMError) {
        switch rawValue {
        case 0:
            let numerator = vm.registerA
            let denominator = Int64(pow(2, Double(try vm.comboOperand(operand))))
            vm.registerA = numerator / denominator
            
        case 1:
            vm.registerB = Int64(operand) ^ vm.registerB
            
        case 2:
            vm.registerB = try vm.comboOperand(operand) & 0b111
            
        case 3:
            if vm.registerA == 0 {
                // Do nothing, but DO increase the IP.
                break
            }
            
            vm.instructionPointer = operand
            // Do NOT increase the IP.
            return
            
        case 4:
            vm.registerB = vm.registerB ^ vm.registerC
            
        case 5:
            try vm.print(Int(try vm.comboOperand(operand) & 0b111))
            
        case 6:
            let numerator = vm.registerA
            let denominator = Int64(pow(2, Double(try vm.comboOperand(operand))))
            vm.registerB = numerator / denominator
            
        case 7:
            let numerator = vm.registerA
            let denominator = Int64(pow(2, Double(try vm.comboOperand(operand))))
            vm.registerC = numerator / denominator
            
        default:
            throw .invalidOpcode
        }
        
        vm.instructionPointer += 2
    }
}


func parse(_ lines: [Substring], print: @escaping (Int) -> Void) throws -> VM {
    var vm = VM(print: print)
    for line in lines {
        if let match = try /Register A: (\d+)/.firstMatch(in: line) {
            vm.registerA = Int64(match.output.1)!
        } else if let match = try /Register B: (\d+)/.firstMatch(in: line) {
            vm.registerB = Int64(match.output.1)!
        } else if let match = try /Register C: (\d+)/.firstMatch(in: line) {
            vm.registerC = Int64(match.output.1)!
        } else if let match = try /Program: ([0-9,]+)/.firstMatch(in: line) {
            let program = match.output.1.split(separator: ",").map { Int($0)! }
            vm.rom = program
        }
    }
    return vm
}


runPart(.input) {
    (lines) in
    
    var output: [Int] = []
    var vm = try parse(lines) {
        output.append($0)
    }
    try vm.run()
    
    print("Part 1: \(output.map { String($0) }.joined(separator: ","))")
}


runPart(.input) {
    (lines) in
    
    let originalVM = try parse(lines) { _ in }
    
    // Analyzing the input program revealed some patterns. It forms a loop until A = 0, and on each
    // iteration A = A / 8. So we can try to feed in inputs in three-bit blocks. BUT, the actual
    // output depends on more bits of `A`. Trying to use first match, shifting, then finding the
    // next does not work.
    //
    // I also tried an iterative approach where each time another valid part of the output was
    // produced, `A` got increased by a new increment didn't work (although I quickly managed to
    // reach 8 digits using this approach so it might work with some tweaks). Didn't manage to make
    // that approach work, though. Then I tried a completely different way (see below). Didn't work
    // either.
    //
    // So use a search. Create candidates for each output digit, shift it, try until we get a
    // little more valid output, remember that and repeat. That finally works, and is pretty fast.
    
    typealias Candidate = (registerA: Int64, outputLength: Int)
    var candidates: [Candidate] = [(0, 1)]
    var solutions: [Int64] = []
    
    while let candidate = candidates.popLast() {
        let partialProgram = Array(originalVM.rom.suffix(candidate.outputLength))

        for i: Int64 in 0 ... 7 {
            var output: [Int] = []
            var vm = originalVM
            vm.print = { output.append($0) }
            
            let value = candidate.registerA << 3 | i
            vm.registerA = value
            try vm.run()
            
            guard output == partialProgram else {
                continue
            }
            
            if candidate.outputLength == originalVM.rom.count {
                solutions.append(value)
            } else {
                candidates.append((value, candidate.outputLength + 1))
            }
        }
    }
    
    guard let best = solutions.min() else {
        fatalError("No Solution found")
    }
    
    print("Part 2: \(best)")
}

// Attempt to find byte patterns and recreate the program from the output.
// I was _almost_ there, was able to correctly output the last 8 numbers… but didn't manage to
// create the output for the first 8. :-( Gave up as I was working several hours on this without
// a result.
#if false
runPart(.input) {
    (lines) in
    
    let originalVM = try parse(lines) { _ in }
    
    // Build a map of output patterns and the necessary input to generate this number.
    // Analyzing the input program revealed some patterns. It forms a loop until A = 0, and on each
    // iteration A = A / 8.
    var map: [[Int]: Int64] = [:]
    for j: Int64 in 0 ..< 16_777_216 /* 2**24 */ {
        var output: [Int] = []
        var vm = originalVM
        vm.registerA = j
        vm.print = {
            output.append($0)
        }
        try vm.run()
        
        if map[output] == nil {
            // If there is already a pattern -> bytes mapping, it's value is smaller and thus more
            // desirable.
            map[output] = j
        }
    }
    
    // Using that map, analyze the existing program an build an input that produces an output equal
    // to the program: a quine.
    var program = Array(originalVM.rom)
    var input: Int64 = 0
    
    while !program.isEmpty {
        var length = min(program.count, 8)
        var pattern = program[0 ..< length]
        
        if let bytes = map[Array(pattern)] {
            input <<= 3*length
            input |= bytes
        } else {
            // Try to find shorter pattern.
            length = min(program.count, 4)
            pattern = program[0 ..< length]
            
            if let bytes = map[Array(pattern)] {
                input <<= 3*length
                input |= bytes
            } else {
                fatalError("Cannot find suitable pattern")
            }
        }
        
        program.removeFirst(length)
    }
    
    var output: [Int] = []
    var vm = originalVM
    vm.registerA = input
    vm.print = {
        output.append($0)
    }
    try vm.run()
    
    precondition(output == originalVM.rom)
    
    print("Part 2: \(input) -> \(output.map { String($0) }.joined(separator: ","))")
    
}
#endif
