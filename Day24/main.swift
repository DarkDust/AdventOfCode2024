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


enum DayError: Error {
    case invalidInput(String)
    case invalidGate(String)
    case invalidGateName(String)
    case wireHasNoValue(String)
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


class Wire {
    
    let name: String
    let output: PassthroughSubject<Bool, Never> = PassthroughSubject()
    var value: Bool?
    
    var connection: AnyCancellable?
    
    
    init(name: String) {
        self.name = name
    }
    
    func connect(_ gate: Gate) {
        self.connection = gate.output.sink {
            self.value = $0
            self.output.send($0)
        }
    }
    
    func send(_ value: Bool) {
        self.value = value
        self.output.send(value)
    }
    
}


class Gate {
    
    let operation: Operation
    let output: PassthroughSubject<Bool, Never> = PassthroughSubject()
    
    var input1: PassthroughSubject<Bool, Never>?
    var input2: PassthroughSubject<Bool, Never>?
    var connection: AnyCancellable?
    
    
    init(operation: Operation) {
        self.operation = operation
    }
    
    
    func connect(_ wire: Wire) {
        if let input1 {
            input2 = wire.output
            
            let operation = self.operation
            self.connection = input1.combineLatest(wire.output) {
                operation.execute($0, $1)
            }.sink {
                self.output.send($0)
            }
            
        } else {
            input1 = wire.output
        }
    }
    
}


runPart(.input) {
    (lines) in
    
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
    var gates: [Gate] = []
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
        
        let gate = Gate(operation: operation)
        gate.connect(in1Wire)
        gate.connect(in2Wire)
        getWire(out).connect(gate)
        gates.append(gate)
    }
    
    for (name, value) in wireValues {
        getWire(name).send(value)
    }
    
    var result = 0
    for (name, wire) in wires {
        guard name.hasPrefix("z") else { continue }
        
        guard let digit = Int(name.dropFirst()) else {
            throw DayError.invalidGateName(name)
        }
        guard let value = wire.value else {
            throw DayError.wireHasNoValue(name)
        }
        
        if value {
            result |= 1 << digit
        }
    }
    
    print("Part 1: \(result)")
}
