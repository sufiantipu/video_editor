//
//  Utility.swift
//  Video Editor
//
//  Created by Sufian  on 13/07/2025.
//

import UIKit

typealias defaultBlock = (() -> Void)

// Colors

let THEM_COLOR = UIColor(hexString: "121212")
let SCREEN_BACKGROUND_COLOR = UIColor(hexString: "15161A")
let NAV_BAR_COLOR = UIColor(hexString: "15161A")
let BRIGHT_COLOR = UIColor(hexString: "EA335F")

// Global Methods

func createAlertWithAction(title: String, message: String, action: UIAlertAction, showCancel: Bool = true) -> UIAlertController {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    if showCancel {
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    }
    alert.addAction(action)
    return alert
}

func topMostViewController() -> UIViewController {
    let keyWindow = getKeyWindow()
    guard let rootViewController = keyWindow.rootViewController else {
        let controller = UIViewController()
        keyWindow.rootViewController = controller
        return controller
    }

    var topmostViewController = rootViewController
    while let presentedViewController = topmostViewController.presentedViewController {
        topmostViewController = presentedViewController
    }
    if let navigationController = topmostViewController as? UINavigationController {
        topmostViewController = navigationController.topViewController ?? topmostViewController
    } else if let tabBarController = topmostViewController as? UITabBarController {
        topmostViewController = tabBarController.selectedViewController ?? topmostViewController
    }
    return topmostViewController
}

func getKeyWindow() -> UIWindow {
    if let keyWindow = UIApplication.shared.connectedScenes
        .compactMap({ $0 as? UIWindowScene })
        .flatMap({ $0.windows })
        .first(where: { $0.isKeyWindow }) {
        return keyWindow
    } else {
        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        return window
    }
}
