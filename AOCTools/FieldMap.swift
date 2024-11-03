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
class FieldMap<Field: FieldProtocol> {
    
    /// Fields as a contiguous array.
    fileprivate
    var fields: [Field]
    
    /// Width of the map.
    public
    let width: Int
    
    /// Height of the map.
    public
    let height: Int
    
    
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
    
    
    private
    init (width: Int, height: Int, fields: [Field]) {
        self.width = width
        self.height = height
        self.fields = fields
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
    subscript(point: Point) -> Field {
        get {
            fields[point.y * width + point.x]
        }
        set {
            fields[point.y * width + point.x] = newValue
        }
    }
    
    
    /// Wrapping field getter.
    func get(x: Int, y: Int) -> Field {
        fields[y.modulo(height) * width + x.modulo(width)]
    }
    
    
    /// Wrapping field getter.
    func get(point: Point) -> Field {
        fields[point.y.modulo(height) * width + point.x.modulo(width)]
    }
    
    
    /// Wrapping field setter.
    func set(x: Int, y: Int, field: Field) {
        fields[y.modulo(height) * width + x.modulo(width)] = field
    }
    
    
    /// Wrapping field setter.
    func set(point: Point, field: Field) {
        fields[point.y.modulo(height) * width + point.x.modulo(width)] = field
    }
    
    
}


// MARK: Neighbours
public
extension FieldMap {
    
    /// How to calculate neighbouring field coordinates.
    enum NeighbourScheme {
        /// Only consider the four neighours to the north, east, south, and west.
        case cross
        
        /// Consider the eight neighbours to the N, NE, E, SE, S, SW, W, and NW.
        case box
    }
    
    
    /// Get neighouring fields.
    ///
    /// - parameter point: The field coordinate to get the neighbours for.
    /// - parameter scheme: Which coordinates to consider.
    /// - parameter wrap: Whether to wrap around the edges. If false, coordinates that would be
    ///   out of bounds get discarded.
    func neighbours(for point: Point, scheme: NeighbourScheme, wrap: Bool) -> [(Point, Field)] {
        let candidates: [Point]
        
        switch scheme {
        case .cross:
            candidates = [
                Point(x: point.x, y: point.y - 1),
                Point(x: point.x + 1, y: point.y),
                Point(x: point.x, y: point.y + 1),
                Point(x: point.x - 1, y: point.y),
            ]
            
        case .box:
            candidates = [
                Point(x: point.x,     y: point.y - 1),
                Point(x: point.x + 1, y: point.y - 1),
                Point(x: point.x + 1, y: point.y),
                Point(x: point.x + 1, y: point.y + 1),
                Point(x: point.x,     y: point.y + 1),
                Point(x: point.x - 1, y: point.y + 1),
                Point(x: point.x - 1, y: point.y),
                Point(x: point.x - 1, y: point.y - 1),
            ]
        }
        
        let coordinates: [Point]
        if wrap {
            coordinates = candidates.map {
                Point(x: $0.x.modulo(width), y: $0.y.modulo(height))
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
    
}


// MARK: Miscellaneous
public
extension FieldMap {
    
    /// Create a copy for the receiver.
    func copy() -> FieldMap {
        FieldMap(width: width, height: height, fields: fields)
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
    mutating func next() -> (Point, Field)? {
        guard index < map.fields.count else { return nil }
        let point = Point(x: index % map.width, y: index / map.width)
        let field = map.fields[index]
        index += 1
        return (point, field)
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
