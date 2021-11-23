//
//  File.swift
//  
//
//  Created by Christian Beer on 21.11.21.
//

import Foundation

func sizeOf<T>(_ value: T) -> Int {
    return MemoryLayout<T>.size
}
