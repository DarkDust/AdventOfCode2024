//
//  main.swift
//  Day21
//
//  Created by Marc Haisenko on 2024-12-22.
//

import Foundation
import AOCTools
import Algorithms


enum Button: Int, CustomDebugStringConvertible {
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


class State {
    let button: Button
    let nextButtons: any Collection<Button>
    let childState: State?
    let recorded: [Button]
    
    init(button: Button, nextButtons: any Collection<Button>, childState: State) {
        self.button = button
        self.nextButtons = nextButtons
        self.childState = childState
        self.recorded = []
    }
    
    init(button: Button, nextButtons: any Collection<Button>, recorded: [Button]) {
        self.button = button
        self.nextButtons = nextButtons
        self.childState = nil
        self.recorded = recorded
    }
    
    
    var canAdvance: Bool {
        !nextButtons.isEmpty || (childState?.canAdvance ?? false)
    }
    
    func advance(buttonMap: ButtonMap) -> [State] {
        guard let childState else {
            guard let nextButton = nextButtons.first else {
                assertionFailure("Must not get called when cannot advance")
                return []
            }
            
            return [State(
                button: nextButton,
                nextButtons: nextButtons.dropFirst(),
                recorded: recorded + [nextButton]
            )]
        }
        
        if childState.canAdvance {
            let nextStates = childState.advance(buttonMap: buttonMap)
            return nextStates.map {
                State(button: button, nextButtons: nextButtons, childState: $0)
            }
        }
        
        guard let nextButton = nextButtons.first else {
            assertionFailure("Must not get called when cannot advance")
            return []
        }
        
        let nextNextButtons = nextButtons.dropFirst()
        let movements = buttonMap[button]![nextButton]!
        var result: [State] = []
        for movement in movements {
            let nextState = childState.withNewMovements(movement + [.A])
            for cascaded in nextState.advance(buttonMap: buttonMap) {
                result.append(State(
                    button: nextButton,
                    nextButtons: nextNextButtons,
                    childState: cascaded
                ))
            }
        }
        return result
    }
    
    func withNewMovements(_ movements: [Button]) -> State {
        assert(nextButtons.isEmpty)
        if let childState {
            return State(button: button, nextButtons: movements, childState: childState)
        } else {
            return State(button: button, nextButtons: movements, recorded: recorded)
        }
    }
    
    func getRecorded() -> [Button] {
        if let childState {
            return childState.getRecorded()
        } else {
            return recorded
        }
    }
}


func calculateBestMovement(buttonMap: ButtonMap, buttons: [Button]) -> Int {
    let start = State(
        button: .A,
        nextButtons: buttons,
        childState: State(
            button: .A, nextButtons: [], childState: State(
                button: .A, nextButtons: [], childState: State(
                    button: .A, nextButtons: [], recorded: []
                )
            )
        )
    )
    var fewestMoves: Int?
    var movesString = ""
    var stack: [State] = [start]
    while let state = stack.popLast() {
        guard state.canAdvance else {
            let moves = state.getRecorded()
            if moves.count < fewestMoves ?? .max {
                fewestMoves = moves.count
                movesString = moves.map { $0.debugDescription }.joined()
            }
            fewestMoves = min(fewestMoves ?? .max, moves.count)
            continue
        }
        
        if let fewestMoves, state.getRecorded().count >= fewestMoves {
            // Not worth exploring this option further
            continue
        }
        
        let nextStates = state.advance(buttonMap: buttonMap)
        stack.append(contentsOf: nextStates)
    }
    
    print(movesString)
    return fewestMoves!
}


func calculateMultiplicator(sequence: [Button]) -> Int {
    var multi: Int = 0
    
    for button in sequence {
        let value = button.rawValue
        guard value < 10 else { continue }
        
        multi *= 10
        multi += value
    }
    
    return multi
}

runPart(.input) {
    (lines) in
    
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
    
    let sequences = lines.map { $0.compactMap { Button($0) } }
    var total = 0
    for sequence in sequences {
        let fewestMoves = calculateBestMovement(buttonMap: combinedMap, buttons: sequence)
        let multiplicator = calculateMultiplicator(sequence: sequence)
        total += multiplicator * fewestMoves
    }
    
    print("Part 1: \(total)")
}
