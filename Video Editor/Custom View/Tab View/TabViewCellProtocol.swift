//
//  TabViewCellProtocol.swift
//  Video Editor
//
//  Created by Sufian  on 10/07/2025.
//

import UIKit

protocol TabViewCellProtocol {
    var reuseIdentifier: String { get }
    func setSelected(_ value: Bool)
    func getClass() -> AnyClass
    func setData(_ data: TabData)
}

extension TabViewCellProtocol {
    var reuseIdentifier: String {
        String.init(describing: self.getClass())
    }
}
