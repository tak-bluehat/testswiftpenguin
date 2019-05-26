//
//  Linkedlist.swift
//  testswiftpenguin
//
//  Created by tak on 2016/09/10.
//  Copyright © 2016年 tak. All rights reserved.
//

import Foundation

public class LinkedListNode<T,S,x,y,z> {
    var value: T
    var view: S
    var move_x: x
    var move_y: y
    var move_z: z
    var next: LinkedListNode?
    weak var previous: LinkedListNode?
    
    public init(value: T, view: S, move_x: x, move_y: y, move_z: z) {
        self.value = value
        self.view = view
        self.move_x = move_x
        self.move_y = move_y
        self.move_z = move_z
        self.next = nil
    }
}

public class LinkedList<T,S,x,y,z> {
    public typealias Node = LinkedListNode<T,S,x,y,z>
    
    private var head: Node?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node? {
        return head
    }
    
    public var last: Node? {
        if var node = head {
            while case let next? = node.next {
                node = next
            }
            return node
        } else {
            return nil
        }
    }
    
    public var count: Int {
        if var node = head {
            var c = 1
            while case let next? = node.next {
                node = next
                c += 1
            }
            return c
        } else {
            return 0
        }
    }
    
    public func nodeAtIndex(index: Int) -> Node? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 { return node }
                i -= 1
                node = node!.next
            }
        }
        return nil
    }
    
    public subscript(index: Int) -> T {
        let node = nodeAtIndex(index: index)
        assert(node != nil)
        return node!.value
    }
    
    public func append(value: T, view: S, move_x: x, move_y: y, move_z: z) {
        let newNode = Node(value: value, view: view, move_x: move_x, move_y: move_y, move_z: move_z)
        if let lastNode = last {
            newNode.previous = lastNode
            lastNode.next = newNode
        } else {
            head = newNode
        }
    }
    
    private func nodesBeforeAndAfter(index: Int) -> (Node?, Node?) {
        assert(index >= 0)
        
        var i = index
        var next = head
        var prev: Node?
        
        while next != nil && i > 0 {
            i -= 1
            prev = next
            next = next!.next
        }
        assert(i == 0)  // if > 0, then specified index was too large
        
        return (prev, next)
    }
    
    public func insert(value: T, view: S, move_x: x, move_y: y, move_z: z, atIndex index: Int) {
        let (prev, next) = nodesBeforeAndAfter(index: index)
        
        let newNode = Node(value: value, view: view, move_x: move_x, move_y: move_y, move_z: move_z)
        newNode.previous = prev
        newNode.next = next
        prev?.next = newNode
        next?.previous = newNode
        
        if prev == nil {
            head = newNode
        }
    }
    
    public func removeAll() {
        head = nil
    }
    
    public func removeNode(node: Node) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        node.previous = nil
        node.next = nil
        return node.value
    }
    
    public func removeLast() -> T {
        assert(!isEmpty)
        return removeNode(node: last!)
    }
    
    public func removeAtIndex(index: Int) -> T {
        let node = nodeAtIndex(index: index)
        assert(node != nil)
        return removeNode(node: node!)
    }
}

