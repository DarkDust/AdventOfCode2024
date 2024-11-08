import Testing
import AOCTools

struct RedBlackTreeTests {
    
    @Test
    func basic() {
        let tree = RedBlackTree<Int, String>()
        
        tree.insert(10, value: "Ten")
        tree.insert(30, value: "Thirty")
        tree.insert(20, value: "Twenty")
        tree.insert(40, value: "Fourty")
        tree.insert(15, value: "Fifteen")
        tree.insert(16, value: "Sixteen")
        tree.insert(100, value: "Hundred")
        tree.insert(25, value: "Twentyfive")
        
        let keys = tree.map(\.key)
        #expect(keys == [10, 15, 16, 20, 25, 30, 40, 100])
        
        #expect(tree.minimum?.key == 10)
        #expect(tree.removeMinimum()?.key == 10)
        #expect(tree.removeMinimum()?.key == 15)
        #expect(tree.removeMinimum()?.key == 16)
        #expect(tree.removeMinimum()?.key == 20)
        #expect(tree.removeMinimum()?.key == 25)
        #expect(tree.removeMinimum()?.key == 30)
        #expect(tree.removeMinimum()?.key == 40)
        #expect(tree.removeMinimum()?.key == 100)
        #expect(tree.removeMinimum() == nil)
    }
    
    
    @Test
    func delete() {
        let tree = RedBlackTree<Int, String>()
        
        tree.insert(10, value: "Ten")
        tree.insert(30, value: "Thirty")
        tree.insert(20, value: "Twenty")
        tree.insert(40, value: "Fourty")
        tree.insert(15, value: "Fifteen")
        tree.insert(16, value: "Sixteen")
        tree.insert(100, value: "Hundred")
        tree.insert(25, value: "Twentyfive")
        
        // 20 should be the root now.
        #expect(tree.removeFirst(key: 20)?.key == 20)
        #expect(tree.map(\.key) == [10, 15, 16, 25, 30, 40, 100])
        #expect(tree.removeFirst(key: 20) == nil)
        
        #expect(tree.removeFirst(key: 25)?.key == 25)
        #expect(tree.map(\.key) == [10, 15, 16, 30, 40, 100])
    }
    
    
    @Test
    func multipleEntries1() {
        let tree = RedBlackTree<Int, String>()
        
        tree.insert(10, value: "Ten")
        tree.insert(30, value: "Thirty")
        tree.insert(20, value: "A")
        tree.insert(20, value: "B")
        tree.insert(20, value: "C")
        tree.insert(40, value: "Fourty")
        tree.insert(15, value: "Fifteen")
        tree.insert(16, value: "Sixteen")
        tree.insert(100, value: "Hundred")
        tree.insert(25, value: "Twentyfive")
        
        let element = tree.first(key: 20)
        #expect(element != nil)
        #expect(["A", "B", "C"].contains(element!.value))
        
        #expect(["A", "B", "C"].contains(tree.removeFirst(key: 20)!.value))
        #expect(["A", "B", "C"].contains(tree.removeFirst(key: 20)!.value))
        #expect(["A", "B", "C"].contains(tree.removeFirst(key: 20)!.value))
        #expect(tree.removeFirst(key: 20) == nil)
    }
    
    
    @Test
    func multipleEntries2() {
        let tree = RedBlackTree<Int, String>()
        
        tree.insert(10, value: "Ten")
        tree.insert(30, value: "Thirty")
        tree.insert(20, value: "A")
        tree.insert(20, value: "B")
        tree.insert(20, value: "C")
        tree.insert(40, value: "Fourty")
        tree.insert(15, value: "Fifteen")
        tree.insert(16, value: "Sixteen")
        tree.insert(100, value: "Hundred")
        tree.insert(25, value: "Twentyfive")
        
        #expect(tree.remove(key: 20, value: "A")?.value == "A")
        #expect(tree.remove(key: 20, value: "A") == nil)
        #expect(tree.remove(key: 20, value: "B")?.value == "B")
        #expect(tree.remove(key: 20, value: "C")?.value == "C")
        #expect(tree.removeFirst(key: 20) == nil)
    }
    
}
