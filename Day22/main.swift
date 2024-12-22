//
//  main.swift
//  Day22
//
//  Created by Marc Haisenko on 2024-12-22.
//

import Foundation
import AOCTools
import Algorithms


struct PseudoRandom: Sequence, IteratorProtocol {
    var current: Int
    
    mutating func next() -> Int? {
        var secret = current
        let intermediate1 = secret * 64
        secret ^= intermediate1
        secret = secret.modulo(16_777_216)
        let intermediate2 = secret / 32
        secret ^= intermediate2
        secret = secret.modulo(16_777_216)
        let intermediate3 = secret * 2048
        secret ^= intermediate3
        secret = secret.modulo(16_777_216)
        
        self.current = secret
        return secret
    }
}


func getSecret(seed: Int, nth: Int) -> Int {
    // I thought there might be cycles and the initial versions of this function and
    // `getSecretSequence(seed:maxLength:)` searched for them. Premature optimization…
    assert(nth > 0, "nth must be positive")
    
    var i = 0
    for secret in PseudoRandom(current: seed) {
        if nth == i + 1 {
            return secret
        }
        
        i += 1
    }
    fatalError("Cannot be reached")
}


func getSecretSequence(seed: Int, maxLength: Int) -> [Int] {
    assert(maxLength > 0, "nth must be positive")
    return [seed] + PseudoRandom(current: seed).prefix(maxLength - 1)
}


runPart(.input) {
    (lines) in
    
    let seeds = lines.compactMap { Int($0) }
    let sum = seeds.reduce(0) { $0 + getSecret(seed: $1, nth: 2000) }
    print("Part 1: \(sum)")
}

runPart(.input) {
    (lines) in
    
    // This solution is inefficient and takes a few minutes to run, but gets the job done.
    // That's all I care about at this point.
    
    let seeds = lines.compactMap { Int($0) }
    var knownSeeds: Set<Int> = []
    var diffSequences: [[Int]: [(secrets: [Int], diffs: [Int])]] = [:]
    
    for seed in seeds {
        assert(!knownSeeds.contains(seed), "Duplicate seed found")
        knownSeeds.insert(seed)
        
        let secrets = getSecretSequence(seed: seed, maxLength: 2000)
        let diffs = secrets
            .adjacentPairs()
            .map { ($1 % 10) - ($0 % 10) }
        
        // Eliminate duplicates in the sequences by collecting into a set first.
        var deduplicatedSequences: Set<[Int]> = []
        for diffSequence in diffs.windows(ofCount: 4) {
            deduplicatedSequences.insert(Array(diffSequence))
        }
        
        for diffSequence in deduplicatedSequences {
            diffSequences[diffSequence, default: []].append((secrets, diffs))
        }
    }
    
    let sortedDiffSequences = diffSequences.sorted(by: { $0.value.count > $1.value.count })
    let mostMatches = sortedDiffSequences.first!.value.count
    var mostBananas = 0
    for (matchSequence, candidates) in sortedDiffSequences {
        guard candidates.count > mostMatches / 2 else {
            break
        }
        
        var bananas = 0
        
        for (secretSequence, diffSequence) in candidates {
            guard let range = diffSequence.firstRange(of: matchSequence) else {
                fatalError("Subsequence must be found")
            }
            
            bananas += secretSequence[range.startIndex + 4] % 10
        }
        
        mostBananas = max(mostBananas, bananas)
    }
    
    print("Part 2: \(mostBananas)")
}
