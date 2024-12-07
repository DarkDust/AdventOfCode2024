//
//  Async.swift
//  AOCTools
//
//  Created by Marc Haisenko on 2024-12-07.
//

import Foundation


public
extension Sequence where Element: Sendable {
    
    /// Iterate the receiver in parallel, mapping its values to intermediate values, and then
    /// reduces those intermadiates into a final result.
    ///
    /// - parameter into: The value to reduce the intermediates into.
    /// - parameter map: Closure transforming a receiver element into an intermediate value.
    /// - parameter reduce: Closure combining an intermediate value with the result value.
    func mapAndReduce<Intermediate: Sendable, Result>(
        into: Result,
        map: @Sendable @escaping (Element) async -> Intermediate,
        reduce: @Sendable (inout Result, Intermediate) -> Void
    ) async -> Result {
        return await withTaskGroup(of: Intermediate.self, returning: Result.self) {
            (group) in
            
            for element in self {
                group.addTask {
                    await map(element)
                }
            }
            
            var result: Result = into
            for await intermediate in group {
                reduce(&result, intermediate)
            }
            return result
        }
    }
    
    
    /// Iterate the receiver in parallel, mapping its values to intermediate values, and then
    /// reduces those intermadiates into a final result.
    ///
    /// - parameter into: The value to reduce the intermediates into.
    /// - parameter map: Closure transforming a receiver element into an intermediate value.
    /// - parameter reduce: Closure combining an intermediate value with the result value.
    func mapAndReduce<Intermediate: Sendable, Result>(
        _ initial: Result,
        map: @Sendable @escaping (Element) async -> Intermediate,
        reduce: @Sendable (Result, Intermediate) -> Result
    ) async -> Result {
        return await withTaskGroup(of: Intermediate.self, returning: Result.self) {
            (group) in
            
            for element in self {
                group.addTask {
                    await map(element)
                }
            }
            
            var result: Result = initial
            for await intermediate in group {
                result = reduce(result, intermediate)
            }
            return result
        }
    }
}
