
private
class RedBlackNode<Key: Comparable, Value> {
    enum Color {
        case red
        case black
    }
    
    let key: Key
    let value: Value
    
    var color: Color
    weak var parent: RedBlackNode?
    var leftChild: RedBlackNode?
    var rightChild: RedBlackNode?
    
    init(
        key: Key, value: Value, color: Color = .red,
        parent: RedBlackNode? = nil, leftChild: RedBlackNode? = nil, rightChild: RedBlackNode? = nil
    ) {
        self.key = key
        self.value = value
        self.color = color
        self.parent = parent
        self.leftChild = leftChild
        self.rightChild = rightChild
    }
    
    /// Find the left-most subnode (including the receiver).
    var minimum: RedBlackNode<Key, Value> {
        var cursor = self
        while let current = cursor.leftChild {
            cursor = current
        }
        return cursor
    }
    
    /// Find the right-most subnode (including the receiver).
    var maximum: RedBlackNode<Key, Value> {
        var cursor = self
        while let current = cursor.rightChild {
            cursor = current
        }
        return cursor
    }
    
}


// MARK: -
// MARK: Main class

/// A red-black tree implementation.
public final
class RedBlackTree<Key: Comparable, Value> {
    
    /// Tuple with key and value.
    public
    typealias Element = (key: Key, value: Value)
    
    
    /// Direction for subtree rotation operations.
    private
    enum Rotation {
        case left
        case right
    }
    
    
    /// Tree root node.
    private
    var root: RedBlackNode<Key, Value>?
    
    
    public
    init() {}
    
}


// MARK: Public methods
public
extension RedBlackTree {
    
    /// Insert a value for a key.
    /// Multiple values for the same key may exist. Their order is undefined.
    func insert(_ key: Key, value: Value) {
        let node = RedBlackNode(key: key, value: value)
        guard let root else {
            node.color = .black
            self.root = node
            return
        }
        
        var parent: RedBlackNode<Key, Value> = root
        var cursor = self.root
        while let cursorNode = cursor {
            parent = cursorNode
            if key < cursorNode.key {
                cursor = cursorNode.leftChild
            } else {
                cursor = cursorNode.rightChild
            }
        }
        
        node.parent = parent
        if key < parent.key {
            parent.leftChild = node
        } else {
            parent.rightChild = node
        }
        
        fixTreeAfterInset(at: node)
    }
    
    
    /// Return the entry with the smallest key.
    var minimum: Element? {
        guard let node = root?.minimum else { return nil }
        return (node.key, node.value)
    }
    
    
    /// Remove and return the entry with smallest key.
    func removeMinimum() -> Element? {
        guard let root else { return nil }
        
        let node = root.minimum
        self.delete(node: node)
        return (node.key, node.value)
    }
    
    
    /// Find the first entry with the given key.
    /// There can be multiple entries with the same key.
    func first(key: Key) -> Element? {
        var cursor = self.root
        
        while let node = cursor {
            if node.key == key {
                return (node.key, node.value)
            }
            
            if key < node.key {
                cursor = node.leftChild
            } else {
                cursor = node.rightChild
            }
        }
        
        return nil
    }
    
    
    /// Find the first entry with the given key.
    /// There can be multiple entries with the same key.
    @discardableResult
    func removeFirst(key: Key) -> Element? {
        var cursor = self.root
        
        while let node = cursor {
            if node.key == key {
                delete(node: node)
                return (node.key, node.value)
            }
            
            if key < node.key {
                cursor = node.leftChild
            } else {
                cursor = node.rightChild
            }
        }
        
        return nil
    }
    
}


// MARK: Private methods
private
extension RedBlackTree {
    
    typealias Node = RedBlackNode<Key, Value>
    
    @discardableResult private
    func rotate(_ node: Node, direction: Rotation) -> Node {
        switch direction {
        case .left:
            guard let rightChild = node.rightChild else {
                assertionFailure("Cannot rotate left on a node with no right child.")
                return node
            }
            
            node.rightChild = rightChild.leftChild
            rightChild.leftChild?.parent = node
            rightChild.parent = node.parent
            if node.parent == nil {
                root = rightChild
            } else if node === node.parent?.leftChild {
                node.parent?.leftChild = rightChild
            } else {
                node.parent?.rightChild = rightChild
            }
            rightChild.leftChild = node
            node.parent = rightChild
            return rightChild
            
        case .right:
            guard let leftChild = node.leftChild else {
                assertionFailure("Cannot rotate right on a node with no left child.")
                return node
            }
            
            node.leftChild = leftChild.rightChild
            leftChild.rightChild?.parent = node
            leftChild.parent = node.parent
            if node.parent == nil {
                root = leftChild
            } else if node === node.parent?.rightChild {
                node.parent?.rightChild = leftChild
            } else {
                node.parent?.leftChild = leftChild
            }
            leftChild.rightChild = node
            node.parent = leftChild
            return leftChild
        }
    }
    
    
    func fixTreeAfterInset(at _node: Node) {
        var node = _node
        while node !== self.root, node.parent?.color == .red {
            guard var parent = node.parent else {
                fatalError("Degenerated tree: missing parent")
            }
            guard let grandparent = parent.parent else {
                parent.color = .black
                break
            }
            
            if parent === grandparent.leftChild {
                let uncle = grandparent.rightChild
                if uncle?.color == .red {
                    parent.color = .black
                    uncle?.color = .black
                    grandparent.color = .red
                    node = grandparent
                } else {
                    if node === parent.rightChild {
                        self.rotate(parent, direction: .left)
                        parent = node
                    }
                    
                    parent.color = .black
                    grandparent.color = .red
                    self.rotate(grandparent, direction: .right)
                }
            } else {
                let uncle = grandparent.leftChild
                if uncle?.color == .red {
                    parent.color = .black
                    uncle?.color = .black
                    grandparent.color = .red
                    node = grandparent
                } else {
                    if node === parent.leftChild {
                        self.rotate(parent, direction: .right)
                        parent = node
                    }
                    
                    parent.color = .black
                    grandparent.color = .red
                    self.rotate(grandparent, direction: .left)
                }
            }
        }
        
        self.root?.color = .black
    }
    
    
    func moveUp(via parent: Node, node: Node?) {
        let grandparent = parent.parent
        guard let grandparent else {
            node?.parent = nil
            self.root = node
            return
        }
        
        node?.parent = grandparent
        if grandparent.leftChild === parent {
            grandparent.leftChild = node
        } else {
            assert(grandparent.rightChild === parent)
            grandparent.rightChild = node
        }
    }
    
    
    func delete(node: Node) {
        let deletedColor: RedBlackNode<Key, Value>.Color
        let fixupNode: Node?
        
        switch (node.leftChild, node.rightChild) {
        case (.none, .none):
            moveUp(via: node, node: nil)
            fixupNode = nil
            deletedColor = node.color
            
        case (.some(let child), .none), (.none, .some(let child)):
            moveUp(via: node, node: child)
            fixupNode = child
            deletedColor = node.color
            
        case (.some, .some(let right)):
            let successor = right.minimum
            deletedColor = successor.color
            fixupNode = right
            
            if successor.parent === node {
                fixupNode?.parent = successor
            } else {
                moveUp(via: successor, node: successor.rightChild)
                successor.rightChild = node.rightChild
                successor.rightChild?.parent = successor
            }
            
            moveUp(via: node, node: successor)
            successor.leftChild = node.leftChild
            successor.leftChild?.parent = successor
            successor.color = node.color
        }
        
        guard deletedColor == .black, let fixupNode else {
            return
        }
        
        fixTreeAfterDeletion(at: fixupNode)
    }
    
    
    func fixTreeAfterDeletion(at _node: Node) {
        guard let root else {
            preconditionFailure("Missing root node")
        }
        var node = _node
        
        if node === root {
            node.color = .black
            return
        }
        
        while node !== root, node.color == .black {
            guard let parent = node.parent else {
                preconditionFailure("Node without a parent found")
            }
            
            if node === parent.leftChild {
                var sibling = parent.rightChild
                if sibling?.color == .red {
                    sibling?.color = .black
                    parent.color = .red
                    self.rotate(parent, direction: .left)
                    sibling = parent.rightChild
                }
                
                if sibling?.leftChild?.color == .black, sibling?.rightChild?.color == .black {
                    sibling?.color = .red
                    node = parent
                    continue
                }
                
                if sibling?.rightChild?.color == .black {
                    sibling?.leftChild?.color = .black
                    sibling?.color = .red
                    if let sibling {
                        self.rotate(sibling, direction: .right)
                    }
                    sibling = parent.rightChild
                }
                
                sibling?.color = parent.color
                parent.color = .black
                sibling?.rightChild?.color = .black
                self.rotate(parent, direction: .left)
                node = root
                
            } else {
                var sibling = parent.leftChild
                if sibling?.color == .red {
                    sibling?.color = .black
                    parent.color = .red
                    self.rotate(parent, direction: .right)
                    sibling = parent.leftChild
                }
                
                if sibling?.leftChild?.color == .black, sibling?.rightChild?.color == .black {
                    sibling?.color = .red
                    node = parent
                    continue
                }
                
                if sibling?.leftChild?.color == .black {
                    sibling?.rightChild?.color = .black
                    sibling?.color = .red
                    if let sibling {
                        self.rotate(sibling, direction: .left)
                    }
                    sibling = parent.leftChild
                }
                
                sibling?.color = parent.color
                parent.color = .black
                sibling?.leftChild?.color = .black
                self.rotate(parent, direction: .right)
                node = root
            }
        }
    }
}


// MARK: -

// MARK: Iteration
extension RedBlackTree: Sequence {
    
    public
    func makeIterator() -> Iterator {
        Iterator(self.root)
    }
    
}


public
extension RedBlackTree {
    
    struct Iterator: IteratorProtocol {
        public typealias Element = (key: Key, value: Value)
        
        private
        var stack: [RedBlackNode<Key, Value>] = []
        
        fileprivate
        init(_ root: RedBlackNode<Key, Value>?) {
            var cursor = root
            while let current = cursor {
                self.stack.append(current)
                cursor = current.leftChild
            }
        }
        
        public
        mutating func next() -> Element? {
            guard !self.stack.isEmpty else { return nil }
            let top = self.stack.removeLast()
            var cursor = top.rightChild
            while let current = cursor {
                self.stack.append(current)
                cursor = current.leftChild
            }
            return (key: top.key, value: top.value)
        }
    }
    
}


// MARK: ExpressibleByArrayLiteral

extension RedBlackTree: ExpressibleByArrayLiteral {
    
    public convenience
    init(arrayLiteral elements: Element...) {
        self.init()
        for element in elements {
            self.insert(element.key, value: element.value)
        }
    }
    
}
