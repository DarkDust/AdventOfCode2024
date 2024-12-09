//
//  main.swift
//  Day9
//
//  Created by Marc Haisenko on 2024-12-09.
//

import Foundation
import AOCTools

struct FileChunk {
    let id: Int
    let start: Int
    let length: Int
}

func parse(_ line: Substring) -> ([FileChunk], [FileChunk]) {
    var chunks: [FileChunk] = []
    var freeSpace: [FileChunk] = []
    
    var nextId: Int = 0
    var nextIndex: Int = 0
    for (index, char) in line.enumerated() {
        let length: Int = Int(String(char))!
        if index % 2 == 0 {
            chunks.append(FileChunk(id: nextId, start: nextIndex, length: length))
            nextId += 1
        } else if length > 0 {
            freeSpace.append(FileChunk(id: -1, start: nextIndex, length: length))
        }
        
        nextIndex += length
    }
    
    return (chunks, freeSpace)
}


func checksum(_ chunks: [FileChunk]) -> Int {
    return chunks.reduce(0) {
        // Calculate sum of consecutive numbers (the indices covered by the chunk).
        let multiplier = (($1.start + ($1.start + $1.length - 1)) * $1.length) / 2
        let sum = multiplier * $1.id
        return $0 + sum
    }
}


runPart(.input) {
    (lines) in
    
    var (chunks, freeSpace) = parse(lines[0])
    
    freeSpace = freeSpace.reversed()
    while !freeSpace.isEmpty, !chunks.isEmpty {
        let nextFree = freeSpace.removeLast()
        let lastChunk = chunks.removeLast()
        
        if nextFree.start > lastChunk.start {
            chunks.append(lastChunk)
            break
        }
        
        if nextFree.length >= lastChunk.length {
            // File fits into the free space completely.
            let moved = FileChunk(id: lastChunk.id, start: nextFree.start, length: lastChunk.length)
            let insertIndex = chunks.binarySearch(predicate: { $0.start < moved.start })
//            let insertIndex = chunks.firstIndex(where: { $0.start > moved.start }) ?? chunks.endIndex
            chunks.insert(moved, at: insertIndex)
            
            if nextFree.length > lastChunk.length {
                freeSpace.append(FileChunk(id: -1, start: nextFree.start + lastChunk.length, length: nextFree.length - lastChunk.length))
            }
            
        } else {
            // Need to split the file.
            let movedPart = FileChunk(id: lastChunk.id, start: nextFree.start, length: nextFree.length)
            let remainingPart = FileChunk(id: lastChunk.id, start: lastChunk.start, length: lastChunk.length - nextFree.length)
            
            let insertIndex = chunks.firstIndex(where: { $0.start > movedPart.start }) ?? chunks.endIndex
            chunks.insert(movedPart, at: insertIndex)
            chunks.append(remainingPart)
        }
    }
    
    print("Part 1: \(checksum(chunks))")
}

runPart(.input) {
    (lines) in
    
    var (chunks, freeSpace) = parse(lines[0])
    
    var movedChunks: [FileChunk] = []
    var movedIdentifiers: Set<Int> = []
    for chunk in chunks.reversed() {
        guard let freeIndex = freeSpace.firstIndex(where: { $0.length >= chunk.length }) else {
            continue
        }
        
        let free = freeSpace[freeIndex]
        guard free.start < chunk.start else {
            continue
        }
        movedChunks.append(FileChunk(id: chunk.id, start: free.start, length: chunk.length))
        movedIdentifiers.insert(chunk.id)
        
        if free.length == chunk.length {
            freeSpace.remove(at: freeIndex)
        } else {
            freeSpace[freeIndex] = FileChunk(id: -1, start: free.start + chunk.length, length: free.length - chunk.length)
        }
    }
    
    chunks.removeAll(where: { movedIdentifiers.contains($0.id) })
    // Chunks isn't sorted now, but that doesn't matter for checksum algorithm.
    chunks.append(contentsOf: movedChunks)
    
    print("Part 2: \(checksum(chunks))")
}
