//
//  Array+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func upsert(_ newElement: Element, prepend: Bool = false, comparator: ((Element) -> Bool)) {

        if let index = self.index(where: comparator) {
            log.debug("Object already in array, replacing it")
            self[index] = newElement
        } else {
            log.debug("Element not found, it will be inserted")
            if prepend {
                self.insert(newElement, at: 0)
            } else {
                self.append(newElement)
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
