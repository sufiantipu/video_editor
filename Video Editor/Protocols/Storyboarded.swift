//
//  Storyboarded.swift
//  Video Editor
//
//  Created by Sufian  on 10/07/2025.
//

import UIKit

protocol Storyboarded {
    static var storyboardName: String { get }
    static func instantiate() -> UIViewController
}

extension Storyboarded where Self: UIViewController {
    static var storyboardName: String {
        "Main"
    }
    
    static func instantiate() -> UIViewController {
        let storyboard = UIStoryboard(name: storyboardName, bundle: .main)
        return storyboard.instantiateViewController(withIdentifier: String(describing: Self.self))
    }
}
