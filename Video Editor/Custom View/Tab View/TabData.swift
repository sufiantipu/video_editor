//
//  TabData.swift
//  Video Editor
//
//  Created by Sufian  on 10/07/2025.
//

import UIKit

protocol TabDataProtocol {
    
}

struct TabData {
    var iconName: String
    var selectedIconName: String
    var name: String
    
    init(_ iconName: String, selectedIcon: String, name: String) {
        self.iconName = iconName
        self.selectedIconName = selectedIcon
        self.name = name
    }
}
