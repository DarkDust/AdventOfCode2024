//
//  Resources.swift
//  AdventOfCode2024
//
//  Created by Marc Haisenko on 2024-11-02.
//

import Foundation

/// Get string resource embedded in the executable binary.
///
/// The resource needs to be embedded by the linker using the flag
/// `-sectcreate __TEXT [name] [path to file]`.
///
/// In this project, the `OTHER_LDFLAGS` is set at the top-level to embed the `input.txt`,
///`sample1.txt`, and `sample2.txt` files of each day. The files are deliberately not included in
/// the Git repository as per https://adventofcode.com/2024/about . You need to copy them into the
/// directory for each day yourself.
func getEmbeddedString(_ name: String) -> String {
    // All of this because `_mh_execute_header` is a `let` instead of a `var`,
    // and `getsectiondata` does not accept copies of this value.
    // See https://stackoverflow.com/a/49438718/400056
    guard let handle = dlopen(nil, RTLD_LAZY) else {
        fatalError("Cannot get handle to executable")
    }
    defer { dlclose(handle) }

    guard let ptr = dlsym(handle, MH_EXECUTE_SYM) else {
        fatalError("Cannot get symbol '\(MH_EXECUTE_SYM)")
    }
    
    let header = ptr.assumingMemoryBound(to: mach_header_64.self)

    
    var size: UInt = 0
    guard let rawData = getsectiondata(header, "__TEXT", name, &size) else {
        fatalError("Cannot find resource '\(name)'")
    }
    let data = Data(bytes: rawData, count: Int(size))
    return String(decoding: data, as: Unicode.UTF8.self)
}
