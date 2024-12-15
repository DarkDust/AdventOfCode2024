//
//  FieldGrid.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-03.
//

/// Protocol for fields in the ``FieldGrid``.
public
protocol FieldProtocol {
    static func parse(_ input: Character) -> Self?
}


/// Errors for the ``FieldGrid``.
public
enum FieldGridError: Error {
    case invalidInput
}


/// A two-dimensional array of fields.
///
/// For a simpler, generic two-dimensional version see ``Fixed2DArray``.
public
struct FieldGrid<Field: FieldProtocol> {
    
    /// Fields as a contiguous array.
    @usableFromInline internal
    var fields: [Field]
    
    /// Width of the grid.
    public
    let width: Int
    
    /// Height of the grid.
    public
    let height: Int
    
    
    /// Initialize the grid by parsing the given lines.
    public
    init(_ lines: some Collection<some StringProtocol>) throws {
        self.width = lines.first?.count ?? 0
        self.height = lines.count
        var fields: [Field] = []
        fields.reserveCapacity(width * height)
        
        for line in lines {
            guard line.count == width else {
                throw FieldGridError.invalidInput
            }
            
            try line.utf8.withContiguousStorageIfAvailable {
                (buffer) in
                
                for character in buffer {
                    guard let field = Field.parse(Character(Unicode.Scalar(character))) else {
                        throw FieldGridError.invalidInput
                    }
                    
                    fields.append(field)
                }
            }
        }
        
        // The only reason for the `field` to not have the expected size is because
        // `line.utf8.withContiguousStorageIfAvailable` didn't get its storage and thus didn't
        // execute its body.
        assert(fields.count == width * height, "Failed to get continuous storage for input")
        
        self.fields = fields
    }
    
    
    /// Initialize the grid with a width, height, and initial value for all fields.
    public
    init(width: Int, height: Int, repeating: Field) {
        self.width = width
        self.height = height
        self.fields = Array(repeating: repeating, count: width * height)
    }
    
}


// MARK: Field access
public
extension FieldGrid {
    
    /// Direct, unchecked field access.
    @inlinable
    subscript(x: Int, y: Int) -> Field {
        get {
            fields[y * width + x]
        }
        set {
            fields[y * width + x] = newValue
        }
    }
    
    
    /// Direct, unchecked field getter.
    @inlinable
    subscript(coord: Coord) -> Field {
        get {
            fields[coord.y * width + coord.x]
        }
        set {
            fields[coord.y * width + coord.x] = newValue
        }
    }
    
    
    /// Wrapping field getter.
    @inlinable
    func get(x: Int, y: Int) -> Field {
        fields[y.modulo(height) * width + x.modulo(width)]
    }
    
    
    /// Wrapping field getter.
    @inlinable
    func get(_ coord: Coord) -> Field {
        fields[coord.y.modulo(height) * width + coord.x.modulo(width)]
    }
    
    
    /// Wrapping field setter.
    @inlinable
    mutating func set(x: Int, y: Int, field: Field) {
        fields[y.modulo(height) * width + x.modulo(width)] = field
    }
    
    
    /// Wrapping field setter.
    @inlinable
    mutating func set(_ coord: Coord, field: Field) {
        fields[coord.y.modulo(height) * width + coord.x.modulo(width)] = field
    }
    
}


// MARK: Neighbours
public
extension FieldGrid {
    
    /// Get neighouring fields.
    ///
    /// - parameter coord: The field coordinate to get the neighbours for.
    /// - parameter scheme: Which coordinates to consider.
    /// - parameter wrap: Whether to wrap around the edges. If false, coordinates that would be
    ///   out of bounds get discarded.
    @inlinable
    func neighbours(for coord: Coord, scheme: Coord.NeighbourScheme, wrap: Bool)
        -> [(coord: Coord, field: Field)]
    {
        let candidates = coord.neighbours(scheme: scheme)
        
        let coordinates: [Coord]
        if wrap {
            coordinates = candidates.map {
                Coord(x: $0.x.modulo(width), y: $0.y.modulo(height))
            }
        } else {
            coordinates = candidates.filter {
                $0.x >= 0 && $0.x < width && $0.y >= 0 && $0.y < height
            }
        }
        
        return coordinates.map {
            ($0, self[$0])
        }
    }
    
    
    /// Get a neighouring field.
    ///
    /// - parameter coord: The field coordinate to get the neighbours for.
    /// - parameter direction: Direction to move to.
    /// - parameter wrap: Whether to wrap around the edges. If false, coordinates that would be
    ///   out of bounds get discarded.
    @inlinable
    func neighbour(for coord: Coord, direction: Direction, wrap: Bool)
        -> (coord: Coord, field: Field)?
    {
        let candidate = coord.neighbour(direction: direction)
        if wrap {
            let coordinate = candidate.normalized(maxX: self.width, maxY: self.height)
            return (coordinate, self[coordinate])
            
        } else if candidate.x >= 0 && candidate.x < width && candidate.y >= 0 && candidate.y < height {
            return (candidate, self[candidate])
            
        } else {
            return nil
        }
    }
    
}



// MARK: Helpers
public
extension FieldGrid where Field: Equatable {
    
    /// Whether the coordinate is within the array's bounds.
    @inlinable
    func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && x < self.width && y >= 0 && y < self.height
    }
    
    
    /// Whether the coordinate is within the array's bounds.
    @inlinable
    func isInBounds(_ coord: Coord) -> Bool {
        return coord.x >= 0 && coord.x < self.width && coord.y >= 0 && coord.y < self.height
    }
    
    
    /// Find first field of the given value.
    func findFirst(_ field: Field) -> Coord? {
        let index = self.fields.firstIndex(of: field)
        guard let index else { return nil }
        
        return Coord(x: index % self.width, y: index / self.width)
    }
    
    
    /// Get all fields starting at the giving position, moving in the given direction, until the
    /// edge of the grid is reached.
    func fields(from: Coord, direction: Direction) -> [(Coord, Field)] {
        var result: [(Coord, Field)] = []
        var coord = from.neighbour(direction: direction)
        
        while isInBounds(coord) {
            result.append((coord, self[coord]))
            coord = coord.neighbour(direction: direction)
        }
        
        return result
    }
    
}


// MARK: Raycasting
public
extension FieldGrid {
    
    /// Count the fields inside a shape.
    ///
    /// - parameter countBorder: Whether to count the border itself as well.
    /// - parameter isVerticalBorder: Closure returning whether a field is considered a vertical
    ///   border.
    /// - parameter shouldCount: Closure whether a field that seems to be on the inside should be
    ///   counted.
    func horizontalRaycast(
        countBorder: Bool = false,
        isVerticalBorder: (Coord, Field) -> Bool,
        shouldCount: (Coord, Field) -> Bool) -> Int
    {
        var count = 0
        var index = 0
        for y in 0 ..< self.height {
            var isInside = false
            
            for x in 0 ..< self.width {
                let field = self.fields[index]
                let coord = Coord(x: x, y: y)
                if isVerticalBorder(coord, field) {
                    isInside = !isInside
                    if countBorder { count += 1 }
                } else if isInside, shouldCount(coord, field) {
                    count += 1
                }
                
                index += 1
            }
            
        }
        
        return count
    }
    
}


// MARK: Iterators
extension FieldGrid: Sequence {
    
    public
    func makeIterator() -> FieldGridIterator<Field> {
        FieldGridIterator(grid: self, index: 0)
    }
    
}


public
struct FieldGridIterator<Field: FieldProtocol>: Sequence, IteratorProtocol {
    
    fileprivate
    let grid: FieldGrid<Field>
    
    fileprivate
    var index: Int
    
    public
    mutating func next() -> (coord: Coord, field: Field)? {
        guard index < grid.fields.count else { return nil }
        let coord = Coord(x: index % grid.width, y: index / grid.width)
        let field = grid.fields[index]
        index += 1
        return (coord, field)
    }
    
}


// MARK: Dump
public extension FieldGrid where Field: CustomStringConvertible {
    
    /// Convert the field to a string representation.
    func dump() -> String {
        var result: String = ""
        
        for y in 0..<height {
            for x in 0..<width {
                let field = fields[y * width + x]
                result.append(field.description)
            }
            result.append("\n")
        }
        
        return result
    }

}

// MARK: Other protocol conformances

extension FieldGrid: Equatable where Field: Equatable { }

extension FieldGrid: Hashable where Field: Hashable { }

extension FieldGrid: Sendable where Field: Sendable { }


// MARK: Standard field grids

extension Int: FieldProtocol {
    
    public
    static func parse(_ input: Character) -> Int? {
        Int(String(input))
    }
    
}


extension Character: FieldProtocol {
    
    public
    static func parse(_ input: Character) -> Character? {
        return input
    }
    
}

