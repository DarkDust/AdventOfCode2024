//
//  FieldMap.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-03.
//

/// Protocol for fields in the ``FieldMap``.
public
protocol FieldProtocol {
    static func parse(_ input: Character) -> Self?
}


/// Errors for the ``FieldMap``.
public
enum FieldMapError: Error {
    case invalidInput
}


/// A two-dimensional array of fields.
public
struct FieldMap<Field: FieldProtocol> {
    
    /// Fields as a contiguous array.
    fileprivate
    var fields: [Field]
    
    /// Width of the map.
    public
    let width: Int
    
    /// Height of the map.
    public
    let height: Int
    
    
    /// Initialize the map by parsing the given lines.
    public
    init(_ lines: [any StringProtocol]) throws {
        self.width = lines.first?.count ?? 0
        self.height = lines.count
        var fields: [Field] = []
        
        for line in lines {
            guard line.count == width else {
                throw FieldMapError.invalidInput
            }
            
            for character in line {
                guard let field = Field.parse(character) else {
                    throw FieldMapError.invalidInput
                }
                
                fields.append(field)
            }
        }
        
        self.fields = fields
    }
    
    
    /// Initialize the map with a width, height, and initial value for all fields.
    public
    init(width: Int, height: Int, repeating: Field) {
        self.width = width
        self.height = height
        self.fields = Array(repeating: repeating, count: width * height)
    }
    
}


// MARK: Field access
public
extension FieldMap {
    
    /// Direct, unchecked field access.
    subscript(x: Int, y: Int) -> Field {
        get {
            fields[y * width + x]
        }
        set {
            fields[y * width + x] = newValue
        }
    }
    
    
    /// Direct, unchecked field getter.
    subscript(coord: Coord) -> Field {
        get {
            fields[coord.y * width + coord.x]
        }
        set {
            fields[coord.y * width + coord.x] = newValue
        }
    }
    
    
    /// Wrapping field getter.
    func get(x: Int, y: Int) -> Field {
        fields[y.modulo(height) * width + x.modulo(width)]
    }
    
    
    /// Wrapping field getter.
    func get(_ coord: Coord) -> Field {
        fields[coord.y.modulo(height) * width + coord.x.modulo(width)]
    }
    
    
    /// Wrapping field setter.
    mutating func set(x: Int, y: Int, field: Field) {
        fields[y.modulo(height) * width + x.modulo(width)] = field
    }
    
    
    /// Wrapping field setter.
    mutating func set(_ coord: Coord, field: Field) {
        fields[coord.y.modulo(height) * width + coord.x.modulo(width)] = field
    }
    
    
}


// MARK: Neighbours
public
extension FieldMap {
    
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


// MARK: Raycasting
public
extension FieldMap {
    
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
extension FieldMap: Sequence {
    
    public
    func makeIterator() -> FieldMapIterator<Field> {
        FieldMapIterator(map: self, index: 0)
    }
    
}


public
struct FieldMapIterator<Field: FieldProtocol>: Sequence, IteratorProtocol {
    
    fileprivate
    let map: FieldMap<Field>
    
    fileprivate
    var index: Int
    
    public
    mutating func next() -> (coord: Coord, field: Field)? {
        guard index < map.fields.count else { return nil }
        let coord = Coord(x: index % map.width, y: index / map.width)
        let field = map.fields[index]
        index += 1
        return (coord, field)
    }
    
}


// MARK: Dump
public extension FieldMap where Field: CustomStringConvertible {
    
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

extension FieldMap: Equatable where Field: Equatable { }

extension FieldMap: Hashable where Field: Hashable { }
