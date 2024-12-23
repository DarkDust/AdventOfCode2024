//
//  main.swift
//  Day21
//
//  Created by Marc Haisenko on 2024-12-22.
//

import Foundation
import AOCTools
import Algorithms


enum Button: Int8, CustomDebugStringConvertible {
    case num0
    case num1
    case num2
    case num3
    case num4
    case num5
    case num6
    case num7
    case num8
    case num9
    case A
    case up
    case down
    case left
    case right
    
    
    init?(_ character: Character) {
        switch character {
        case "0": self = .num0
        case "1": self = .num1
        case "2": self = .num2
        case "3": self = .num3
        case "4": self = .num4
        case "5": self = .num5
        case "6": self = .num6
        case "7": self = .num7
        case "8": self = .num8
        case "9": self = .num9
        case "A": self = .A
        default: return nil
        }
    }
    
    
    var debugDescription: String {
        switch self {
        case .num0: return "0"
        case .num1: return "1"
        case .num2: return "2"
        case .num3: return "3"
        case .num4: return "4"
        case .num5: return "5"
        case .num6: return "6"
        case .num7: return "7"
        case .num8: return "8"
        case .num9: return "9"
        case .A: return "A"
        case .up: return "^"
        case .down: return "v"
        case .left: return "<"
        case .right: return">"
        }
    }
}


/// Map of button sequences to press to navigate from one button to another.
typealias ButtonMap = [Button: [Button: [[Button]]]]


/// Build a map of directional buttons to push when moving from one button to another.
func buildButtonMap(layout: [[Button?]]) -> ButtonMap {
    var result: ButtonMap = [:]
    var grid = Fixed2DArray<Button?>(
        rows: layout.count,
        columns: layout.first?.count ?? 0,
        repeating: nil
    )
    
    for (rowNumber, row) in layout.enumerated() {
        for (columnNumber, button) in row.enumerated() {
            grid[columnNumber, rowNumber] = button
        }
    }
    
    for (fromCoord, fromButton) in grid.enumerated() {
        guard let fromButton else { continue }
        
        for (toCoord, toButton) in grid.enumerated() {
            guard let toButton else { continue }
            
            result[fromButton, default: [:]][toButton] =
                determineButtonSequences(grid: grid, from: fromCoord, to: toCoord)
        }
    }
    
    return result
}


struct ButtonMovement: Hashable {
    let coord: Coord
    let button: Button?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coord)
        hasher.combine(button)
    }
    
    static func == (lhs: ButtonMovement, rhs: ButtonMovement) -> Bool {
        lhs.coord == rhs.coord && lhs.button == rhs.button
    }
}


func determineButtonSequences(grid: Fixed2DArray<Button?>, from: Coord, to: Coord) -> [[Button]] {
    if from == to {
        return [[]]
    }
    
    let start = ButtonMovement(coord: from, button: nil)
    var stack: [ButtonMovement] = [start]
    var cameFrom: [ButtonMovement: ButtonMovement] = [:]
    var result: [[Button]] = []
    
    while let current = stack.popLast() {
        if current.coord == to {
            var path: [Button] = []
            var cursor = current
            while let button = cursor.button {
                path.append(button)
                cursor = cameFrom[cursor]!
            }
            
            result.append(path.reversed())
            continue
        }
        
        if grid[current.coord] == nil {
            continue
        }
        
        func addCandidate(direction: Direction, button: Button) {
            let candidate = ButtonMovement(
                coord: current.coord.neighbour(direction: direction),
                button: button
            )
            cameFrom[candidate] = current
            stack.append(candidate)
        }
        
        if current.coord.x < to.x {
            addCandidate(direction: .east, button: .right)
        } else if current.coord.x > to.x {
            addCandidate(direction: .west, button: .left)
        }
        if current.coord.y < to.y {
            addCandidate(direction: .south, button: .down)
        } else if current.coord.y > to.y {
            addCandidate(direction: .north, button: .up)
        }
    }
    
    return result
}


class StateCache {
    
    private
    struct StateKey: Hashable {
        let layer: Int
        let from: Button
        let to: Button
    }
    
    
    // Don't care about data isolation in AoC.
    nonisolated(unsafe)
    static let shared = StateCache()
    
    
    private
    var cache: [StateKey: [Button]] = [:]
    
    
    func snapshot(state: State, previousButton: Button) -> Int {
        let key = StateKey(layer: state.layer, from: previousButton, to: state.button)
        let recorded = state.getRecorded()
        let addition = recorded[state.lastCacheOffset...]
        
        cache[key] = Array(addition)
        
        return recorded.count
    }
    
    
    func lookup(state: State, nextButton: Button) -> [Button]? {
        let key = StateKey(layer: state.layer, from: state.button, to: nextButton)
        return cache[key]
    }
    
    
    func clear() {
        cache.removeAll()
    }
    
}


class State {
    let layer: Int
    let button: Button
    let nextButtons: any Collection<Button>
    let childState: State?
    let recorded: [Button]?
    var lastCacheOffset: Int
    
    
    init(layer: Int, nextButtons: any Collection<Button> = [], childState: State) {
        self.layer = layer
        self.button = .A
        self.nextButtons = nextButtons
        self.childState = childState
        self.recorded = nil
        self.lastCacheOffset = 0
    }
    
    
    init(layer: Int) {
        self.layer = layer
        self.button = .A
        self.nextButtons = []
        self.childState = nil
        self.recorded = []
        self.lastCacheOffset = 0
    }
    
    
    private
    init(
        layer: Int,
        button: Button,
        nextButtons: any Collection<Button>,
        childState: State?,
        recorded: [Button]?,
        lastCacheOffset: Int
    ) {
        self.layer = layer
        self.button = button
        self.nextButtons = nextButtons
        self.childState = childState
        self.recorded = recorded
        self.lastCacheOffset = lastCacheOffset
    }
    
    
    var canAdvance: Bool {
        !nextButtons.isEmpty || (childState?.canAdvance ?? false)
    }
    
    
    func advance(buttonMap: ButtonMap) -> State {
        guard let childState else {
            guard let nextButton = nextButtons.first else {
                fatalError("Must not get called when cannot advance")
            }
            
            return self.withRecord(nextButton)
        }
        
        if childState.canAdvance {
            let nextState = childState.advance(buttonMap: buttonMap)
            return self.withChildState(nextState)
        }
        
        guard let nextButton = nextButtons.first else {
            fatalError("Must not get called when cannot advance")
        }
        
        let cache = StateCache.shared
        if let cached = cache.lookup(state: self, nextButton: nextButton) {
            let (state, offset) = childState.applyCached(cached)
            return State(
                layer: self.layer,
                button: nextButton,
                nextButtons: self.nextButtons.dropFirst(),
                childState: state,
                recorded: self.recorded,
                lastCacheOffset: offset
            )
        }
        
        let nextNextButtons = nextButtons.dropFirst()
        let movements = buttonMap[button]![nextButton]!
        
        var bestResult: State?
        var bestResultLength: Int?
        
        labelMovement: for movement in movements {
            var nextState = childState.withNextButtons(movement + [.A])
            while nextState.canAdvance {
                if let bestResultLength, nextState.getRecorded().count >= bestResultLength {
                    // Not worth exploring this option further
                    continue labelMovement
                }
                
                nextState = nextState.advance(buttonMap: buttonMap)
            }
            
            let moves = nextState.getRecorded()
            if moves.count < bestResultLength ?? .max {
                bestResultLength = moves.count
                bestResult = nextState
            }
        }
        
        let newState = State(
            layer: self.layer,
            button: nextButton,
            nextButtons: nextNextButtons,
            childState: bestResult!,
            recorded: self.recorded,
            lastCacheOffset: self.lastCacheOffset
        )
        newState.lastCacheOffset = cache.snapshot(state: newState, previousButton: self.button)
        return newState
    }
    
    
    func getRecorded() -> [Button] {
        if let childState {
            return childState.getRecorded()
        } else {
            return recorded ?? []
        }
    }
    
    
    private
    func withNextButtons(_ buttons: [Button]) -> State {
        assert(nextButtons.isEmpty)
        return State(
            layer: self.layer,
            button: self.button,
            nextButtons: buttons,
            childState: self.childState,
            recorded: self.recorded,
            lastCacheOffset: self.lastCacheOffset
        )
    }
    
    
    private
    func withChildState(_ childState: State) -> State {
        return State(
            layer: self.layer,
            button: self.button,
            nextButtons: self.nextButtons,
            childState: childState,
            recorded: self.recorded,
            lastCacheOffset: self.lastCacheOffset
        )
    }
    
    
    private
    func withRecord(_ button: Button) -> State {
        assert(self.childState == nil)
        assert(self.nextButtons.first == button)
        return State(
            layer: self.layer,
            button: button,
            nextButtons: self.nextButtons.dropFirst(),
            childState: nil,
            recorded: (self.recorded ?? []) + [button],
            lastCacheOffset: self.lastCacheOffset
        )
    }
    
    private
    func applyCached(_ buttons: [Button]) -> (State, Int) {
        if let childState {
            let (state, offset) = childState.applyCached(buttons)
            return (State(
                layer: self.layer,
                button: self.button,
                nextButtons: self.nextButtons,
                childState: state,
                recorded: self.recorded,
                lastCacheOffset: offset
            ), offset)
            
        } else {
            let combined = (self.recorded ?? []) + buttons
            return (State(
                layer: self.layer,
                button: self.button,
                nextButtons: self.nextButtons,
                childState: nil,
                recorded: combined,
                lastCacheOffset: combined.count
            ), combined.count)
        }
    }
    
}


func generateStartState(buttons: [Button], robots: Int) -> State {
    let leaf = State(layer: robots + 1)
    var intermediate: State = leaf
    
    for i in stride(from: robots, through: 1, by: -1) {
        let state = State(layer: i, childState: intermediate)
        intermediate = state
    }
    
    return State(layer: 0, nextButtons: buttons, childState: intermediate)
}


func calculateBestMovement(buttonMap: ButtonMap, buttons: [Button], robots: Int) -> Int {
    let start = generateStartState(buttons: buttons, robots: robots)
    var fewestMoves: Int?
    var stack: [State] = [start]
    while let state = stack.popLast() {
        guard state.canAdvance else {
            let moves = state.getRecorded()
            if moves.count < fewestMoves ?? .max {
                fewestMoves = moves.count
            }
            fewestMoves = min(fewestMoves ?? .max, moves.count)
            continue
        }
        
        if let fewestMoves, state.getRecorded().count >= fewestMoves {
            // Not worth exploring this option further
            continue
        }
        
        stack.append(state.advance(buttonMap: buttonMap))
    }
    
    print(fewestMoves!)
    return fewestMoves!
}


func calculateMultiplicator(sequence: [Button]) -> Int {
    var multi: Int = 0
    
    for button in sequence {
        let value = button.rawValue
        guard value < 10 else { continue }
        
        multi *= 10
        multi += Int(value)
    }
    
    return multi
}


func calculateKeyPresses(lines: [Substring], robots: Int) -> Int {
    let numPadMap = buildButtonMap(layout: [
        [.num7, .num8, .num9],
        [.num4, .num5, .num6],
        [.num1, .num2, .num3],
        [nil  , .num0, .A   ],
    ])
    let directionPadMap = buildButtonMap(layout: [
        [nil  , .up  , .A    ],
        [.left, .down, .right],
    ])
    // Merge both maps into one. Needs to account for the duplicate "A".
    var combinedMap = numPadMap
    for (from, toMap) in directionPadMap {
        var combinedToMap = combinedMap[from] ?? [:]
        
        for (to, instructions) in toMap {
            combinedToMap[to] = instructions
        }
        combinedMap[from] = combinedToMap
    }
    
    StateCache.shared.clear()
    
    let sequences = lines.map { $0.compactMap { Button($0) } }
    var total = 0
    for sequence in sequences {
        let fewestMoves = calculateBestMovement(buttonMap: combinedMap, buttons: sequence, robots: robots)
        let multiplicator = calculateMultiplicator(sequence: sequence)
        total += multiplicator * fewestMoves
    }
    
    return total
}


runPart(.input) {
    let total = calculateKeyPresses(lines: $0, robots: 2)
    print("Part 1: \(total)")
}

// Still too slow, runs out of memory.
#if false
runPart(.input) {
    let total = calculateKeyPresses(lines: $0, robots: 25)
    print("Part 2: \(total)")
}
#endif
