//
//  Fixed2DArray.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-11-24.
//

import Foundation


/// A two-dimensional array of fixed size.
///
/// For a variant with additional features for 2D maps, see ``FieldMap``.
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
    @usableFromInline internal
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
    
}
