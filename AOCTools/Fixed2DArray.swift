//
//  Fixed2DArray.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-24.
//

import Foundation


/// A two-dimensional array of fixed size.
///
/// For a variant with additional features for 2D maps, see ``FieldGrid``.
public
struct Fixed2DArray<T> {
    
    /// Number of columns.
    public
    let columns: Int
    
    /// Number of rows.
    public
    let rows: Int
    
    /// Storage.
    @usableFromInline internal
    var data: [T]
    
    
    /// Designated initializer.
    @inlinable public
    init(rows: Int, columns: Int, repeating: T) {
        self.rows = rows
        self.columns = columns
        self.data = Array(repeating: repeating, count: rows * columns)
    }
    
}


// MARK: Accessors
public
extension Fixed2DArray {
    
    /// Access by `x` and `y` (row and column).
    @inlinable
    subscript (x: Int, y: Int) -> T {
        get { data[y * columns + x] }
        set { data[y * columns + x] = newValue }
    }
    
    
    /// Access by coordinate.
    @inlinable
    subscript (coord: Coord) -> T {
        get { data[coord.y * columns + coord.x] }
        set { data[coord.y * columns + coord.x] = newValue }
    }
    
    /// Wrapping field getter.
    @inlinable
    func get(x: Int, y: Int) -> T {
        data[y.modulo(rows) * columns + x.modulo(columns)]
    }
    
    
    /// Wrapping field getter.
    @inlinable
    func get(_ coord: Coord) -> T {
        data[coord.y.modulo(rows) * columns + coord.x.modulo(columns)]
    }
    
    
    /// Wrapping field setter.
    @inlinable
    mutating func set(x: Int, y: Int, value: T) {
        data[y.modulo(rows) * columns + x.modulo(columns)] = value
    }
    
    
    /// Wrapping field setter.
    @inlinable
    mutating func set(_ coord: Coord, value: T) {
        data[coord.y.modulo(rows) * columns + coord.x.modulo(columns)] = value
    }
    
}

// MARK: Helper
public
extension Fixed2DArray {
    
    /// Whether the coordinate is within the array's bounds.
    @inlinable
    func isInBounds(x: Int, y: Int) -> Bool {
        return x >= 0 && x < columns && y >= 0 && y < rows
    }
    
    /// Whether the coordinate is within the array's bounds.
    @inlinable
    func isInBounds(_ coord: Coord) -> Bool {
        return coord.x >= 0 && coord.x < columns && coord.y >= 0 && coord.y < rows
    }
    
}


// MARK: Collection protocol
extension Fixed2DArray: Collection {
    
    @inlinable public
    subscript(index: Int) -> T {
        get { data[index] }
        set { data[index] = newValue }
    }
    
    
    @inlinable public
    var startIndex: Int { 0 }
    
    @inlinable public
    var endIndex: Int { rows * columns }
    
    @inlinable public
    func index(after i: Int) -> Int { i + 1 }
    
    @inlinable public
    func index(x: Int, y: Int) -> Int { y * columns + x }
    
    @inlinable public
    func makeIterator() -> IndexingIterator<[T]> { data.makeIterator() }
    
    /// Enumerate the grid in (Coord, T) tuples.
    public
    func enumerated() -> Fixed2DArrayEnumerator<T> {
        Fixed2DArrayEnumerator(grid: self, index: 0)
    }
    
}


// MARK: Enumeration

public
struct Fixed2DArrayEnumerator<T>: Sequence, IteratorProtocol {
    
    fileprivate
    let grid: Fixed2DArray<T>
    
    fileprivate
    var index: Int
    
    public
    mutating func next() -> (coord: Coord, value: T)? {
        guard index < grid.data.count else { return nil }
        let coord = Coord(x: index % grid.columns, y: index / grid.columns)
        let field = grid.data[index]
        index += 1
        return (coord, field)
    }
    
}


// MARK: Common convenience initializer
public
extension Fixed2DArray where T == Character {
    
    /// Initialize from a list of lines of equal length.
    @inlinable
    init(lines: [any StringProtocol]) {
        guard !lines.isEmpty else {
            self.data = []
            self.rows = 0
            self.columns = 0
            return
        }
        
        self.rows = lines.count
        self.columns = lines[0].count
        
#if DEBUG
        for line in lines {
            assert(line.count == self.columns)
        }
#endif
        
        var data: [Character] = []
        for line in lines {
            data.append(contentsOf: line)
        }
        
        self.data = data
    }
    
}
