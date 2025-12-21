//
//  Item.swift
//  CityBus
//
//  Created by Rohan Rathee on 21/12/25.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
