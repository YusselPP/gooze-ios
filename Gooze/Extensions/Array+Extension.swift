//
//  Array+Extension.swift
//  Gooze
//
//  Created by Yussel Paredes Perez on 4/1/18.
//  Copyright © 2018 Gooze. All rights reserved.
//

import Foundation

extension Array {
    
    mutating func upsert(_ newElement: Element, comparator: ((Element) -> Bool)) {

        if let index = self.index(where: comparator) {
            log.debug("Object already in array, replacing it")
            self[index] = newElement
        } else {
            log.debug("Element not found, it will be inserted")
            self.append(newElement)
        }
    }
    
    mutating func upsert<S>(contentsOf collection: S, comparator: ((Element) -> Bool)) where S: Collection, Element == S.Element {
        
        for element in collection {
            self.upsert(element, comparator: comparator)
        }
    }
}
