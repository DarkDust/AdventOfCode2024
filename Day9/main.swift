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


func checksum(_ chunks: any Sequence<FileChunk>) -> Int {
    return chunks.reduce(0) {
        // Calculate sum of consecutive numbers (the indices covered by the chunk).
        let multiplier = (($1.start + ($1.start + $1.length - 1)) * $1.length) / 2
        let sum = multiplier * $1.id
        return $0 + sum
    }
}


runPart(.input) {
    (lines) in
    
    var (chunksList, freeSpace) = parse(lines[0])
    
    let chunks = RedBlackTree<Int, FileChunk>()
    for chunk in chunksList {
        chunks.insert(chunk.start, value: chunk)
    }
    
    freeSpace = freeSpace.reversed()
    while !freeSpace.isEmpty, let (_, lastChunk) = chunks.removeMaximum() {
        let nextFree = freeSpace.removeLast()
        
        if nextFree.start > lastChunk.start {
            // No more suitable free space, need to re-add the just removed chunk and stop.
            chunks.insert(lastChunk.start, value: lastChunk)
            break
        }
        
        if nextFree.length >= lastChunk.length {
            // File fits into the free space completely.
            let moved = FileChunk(id: lastChunk.id, start: nextFree.start, length: lastChunk.length)
            chunks.insert(moved.start, value: moved)
            
            if nextFree.length > lastChunk.length {
                freeSpace.append(FileChunk(id: -1, start: nextFree.start + lastChunk.length, length: nextFree.length - lastChunk.length))
            }
            
        } else {
            // Need to split the file.
            let movedPart = FileChunk(id: lastChunk.id, start: nextFree.start, length: nextFree.length)
            let remainingPart = FileChunk(id: lastChunk.id, start: lastChunk.start, length: lastChunk.length - nextFree.length)
            
            chunks.insert(movedPart.start, value: movedPart)
            chunks.insert(remainingPart.start, value: remainingPart)
        }
    }
    
    print("Part 1: \(checksum(chunks.values))")
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
