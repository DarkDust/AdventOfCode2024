# Advent Of Code 2024

These are my solutions for [Advent Of Code](https://adventofcode.com) 2024, written in Swift. 

In each day's directory, you need to place the corresponding `input.txt`, `sample1.txt`, and
`sample2.txt`, otherwise the days won't compile (or rather, link). Even if only one sample is
provided, both a `sample1.txt` _and_ `sample2.txt` are required.

The Xcode project linker flags `OTHER_LDFLAGS` are set up in such a way that they embed these three
files as Mach-O sections into each day's executable:

```
-sectcreate __TEXT aocinput "$(SRCROOT)/$(PRODUCT_NAME)/input.txt"
-sectcreate __TEXT aocsample1 "$(SRCROOT)/$(PRODUCT_NAME)/sample1.txt"
-sectcreate __TEXT aocsample2 "$(SRCROOT)/$(PRODUCT_NAME)/sample2.txt"
```

The function [`getEmbeddedString(_:)`](AOCTools/Resources.swift) is then used to read those
sections.
