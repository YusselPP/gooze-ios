//
//  Array+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

extension Array {
    
    @discardableResult
    mutating func upsert(_ newElement: Element, prepend: Bool = false, comparator: ((Element) -> Bool)) -> (Bool, Int) {

        if let index = self.index(where: comparator) {
            log.debug("Object already in array, replacing it")
            self[index] = newElement
            return (false, index)
        } else {
            log.debug("Element not found, it will be inserted")
            if prepend {
                self.insert(newElement, at: 0)
                return (true, 0)
            } else {
                self.append(newElement)
                return (true, self.count - 1)
            }
        }
    }
    
    mutating func upsert<S>(contentsOf collection: S, prepend: Bool = false, comparator: (Element, Element) -> Bool) where S: Collection, Element == S.Element {
        var newArray = self
        
        for element in collection {
            newArray.upsert(element, prepend: prepend) { comparator($0, element) }
        }
        
        self = newArray
    }
}
