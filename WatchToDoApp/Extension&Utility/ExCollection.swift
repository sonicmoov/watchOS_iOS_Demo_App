//
//  ExCollection.swift
//  WatchToDoApp
//
//  Created by L_0019 on 2024/08/13.
//

import UIKit

extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
