//
//  main.swift
//  Day24
//
//  Created by Marc Haisenko on 2024-12-24.
//

import Foundation
import AOCTools
import RegexBuilder
import Combine
import Algorithms


enum DayError: Error {
    case invalidInput(String)
    case invalidGate(String)
    case fetchCycle
}


enum Operation {
    case and
    case or
    case xor
    
    init(_ string: some StringProtocol) throws(DayError) {
        switch string {
        case "AND": self = .and
        case "OR": self = .or
        case "XOR": self = .xor
        default: throw .invalidGate(String(string))
        }
    }
    
    func execute(_ input1: Bool, _ input2: Bool) -> Bool {
        switch self {
        case .and: return input1 && input2
        case .or: return input1 || input2
        case .xor: return input1 != input2
        }
    }
}


class Wire: Hashable, CustomDebugStringConvertible {
    let name: String
    let digit: Int
    var value = false
    var gate: Gate?
    
    
    init(name: String) {
        self.name = name
        
        if let digit = Int(name.dropFirst()) {
            self.digit = digit
        } else {
            self.digit = -1
        }
    }
    
    func connect(_ gate: Gate) {
        self.gate = gate
    }
    
    func fetch(depth: Int) throws(DayError) -> Bool {
        guard depth < 1000 else {
            throw .fetchCycle
        }
        
        guard let gate else { return self.value }
        self.value = try gate.fetch(depth: depth + 1)
        return self.value
    }
    
    static func == (lhs: Wire, rhs: Wire) -> Bool {
        lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var debugDescription: String {
        name
    }
}


class Gate {
    let operation: Operation
    let input1: Wire
    let input2: Wire
    
    
    init(operation: Operation, input1: Wire, input2: Wire) {
        self.operation = operation
        self.input1 = input1
        self.input2 = input2
    }
    
    func fetch(depth: Int) throws(DayError) -> Bool {
        operation.execute(
            try input1.fetch(depth: depth + 1),
            try input2.fetch(depth: depth + 1)
        )
    }
}

func getResult(wires: any Sequence<Wire>) throws(DayError) -> Int {
    var result = 0
    for wire in wires {
        if try wire.fetch(depth: 0) {
            result |= 1 << wire.digit
        }
    }
    return result
}

func determineAddition(wireValues: [String: Bool]) -> (Int, Int, Int) {
    var x = 0
    var y = 0
    
    for (name, value) in wireValues {
        guard let digit = Int(name.dropFirst()) else {
            continue
        }
        
        guard value else {
            continue
        }
        
        if name.hasPrefix("x") {
            x |= 1 << digit
        } else if name.hasPrefix("y") {
            y |= 1 << digit
        }
    }
    
    return (x, y, x+y)
}

func swapGates(_ wire1: Wire, _ wire2: Wire) {
    guard let gate1 = wire1.gate, let gate2 = wire2.gate else {
        return
    }
    
    wire1.connect(gate2)
    wire2.connect(gate1)
}

func swapUntilMatch(wires: [Wire], candidates: Set<Wire>, pairs: Int, expectedValue: Int) throws {
    let output = wires.filter { $0.name.hasPrefix("z") }
    
    for combinations in candidates.permutations(ofCount: pairs * 2) {
        for i in 0 ..< pairs {
            let wire1 = combinations[i * 2]
            let wire2 = combinations[i * 2 + 1]
            
            swapGates(wire1, wire2)
        }
        
        do {
            let result = try getResult(wires: output)
            if result == expectedValue {
                let names = combinations.map { $0.name }.sorted()
                print("Fixed   : " + String(result, radix: 2))
                print("Part 2  : " + names.joined(separator: ","))
                return
            }
        } catch { }
        
        for i in 0 ..< pairs {
            let wire1 = combinations[i * 2]
            let wire2 = combinations[i * 2 + 1]
            
            swapGates(wire1, wire2)
        }
        
    }
}


func parse(lines: [Substring]) throws -> ([String: Wire], [String: Bool]) {
    let refWire1 = Reference<Substring>()
    let refWire2 = Reference<Substring>()
    let refOperation = Reference<Operation>()
    let refWireOut = Reference<Substring>()
    let refWireValue = Reference<Bool>()
    
    let gateRegex = Regex {
        Capture(as: refWire1) {
            OneOrMore(.word.union(.digit))
        }
        
        OneOrMore(.whitespace)
        
        Capture(as: refOperation) {
            OneOrMore(.word)
        } transform: {
            try Operation($0)
        }
        
        OneOrMore(.whitespace)
        
        Capture(as: refWire2) {
            OneOrMore(.word.union(.digit))
        }
        
        OneOrMore(.whitespace)
        "->"
        OneOrMore(.whitespace)
        
        Capture(as: refWireOut) {
            OneOrMore(.word.union(.digit))
        }
    }
    let wireRegex = Regex {
        Capture(as: refWireOut) {
            OneOrMore(.word.union(.digit))
        }
        
        ": "
        
        Capture(as: refWireValue) {
            One(.digit)
        } transform: {
            $0 == "1"
        }
    }
    
    var wireValues: [String: Bool] = [:]
    var gateValues: [(String, String, Operation, String)] = []
    var processGates = false
    for line in lines {
        if processGates {
            guard let match = try gateRegex.firstMatch(in: line) else {
                throw DayError.invalidInput(String(line))
            }
            gateValues.append((
                String(match[refWire1]),
                String(match[refWire2]),
                match[refOperation],
                String(match[refWireOut])
            ))
            
        } else if line.isEmpty {
            processGates = true
            
        } else {
            guard let match = try wireRegex.firstMatch(in: line) else {
                throw DayError.invalidInput(String(line))
            }
            wireValues[String(match[refWireOut])] = match[refWireValue]
        }
    }
    
    var wires: [String: Wire] = [:]
    func getWire(_ name: String) -> Wire {
        if let wire = wires[name] {
            return wire
        }
        let wire = Wire(name: name)
        wires[name] = wire
        return wire
    }
    
    for (in1, in2, operation, out) in gateValues {
        let in1Wire = getWire(in1)
        let in2Wire = getWire(in2)
        
        let gate = Gate(operation: operation, input1: in1Wire, input2: in2Wire)
        getWire(out).connect(gate)
    }
    
    for (name, value) in wireValues {
        getWire(name).value = value
    }
    
    return (wires, wireValues)
}


runPart(.input) {
    (lines) in
    
    let (wires, _) = try parse(lines: lines)
    let result = try getResult(wires: wires.values.filter { $0.name.hasPrefix("z") })
    print("Part 1: \(result)")
}


runPart(.input) {
    (lines) in
    
    let (wires, wireValues) = try parse(lines: lines)
    let outputWires = wires.values.filter { $0.name.hasPrefix("z") }
    
    let (x, y, sum) = determineAddition(wireValues: wireValues)
    print("Expected: \(x) + \(y) = \(sum)")
    print("Expected: \(String(sum, radix: 2))")
        
    let result = try getResult(wires: outputWires)
    print("Have    : \(String(result, radix: 2))")
    
    // I tried to solve this programmatically but simply trying all combinations is of course much
    // too expensive. Tried to find some heuristic to reduce the wires to investigate but didn't
    // manage to reduce the numbers enough.
    //
    // In the end, I plotted the graph of the input using GraphViz, manually looking for incorrectly
    // wired logic. Managed to identify three wrong connections this way. Then found the last one
    // by printing the expected bit pattern, the output bit pattern, and the partially fixed bit
    // pattern. This way I was able to narrow down where to search in the graph, finally indentified
    // the last wrong connection.
    //
    // Verified that I got it right using the two code paths below (the later was part of an attempt
    // to solve this problem programmatically.)
    
#if false
    swapGates(wires["z12"]!, wires["kth"]!)
    swapGates(wires["z26"]!, wires["gsd"]!)
    swapGates(wires["z32"]!, wires["tbt"]!)
    swapGates(wires["qnf"]!, wires["vpm"]!)
    let result2 = try getResult(wires: outputWires)
    print("Fixed   : \(String(result2, radix: 2))")
#else
    let check = ["z12", "kth", "z26", "gsd", "z32", "tbt", "qnf", "vpm"].map {
        wires[$0]!
    }
    try swapUntilMatch(
        wires: Array(wires.values),
        candidates: Set(check),
        pairs: 4,
        expectedValue: sum
    )
#endif
}
