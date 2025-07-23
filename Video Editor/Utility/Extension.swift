//
//  Extension.swift
//  Video Editor
//
//  Created by Sufian  on 15/07/2025.
//

import UIKit
import AVKit

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(
            in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a: UInt64
        let r: UInt64
        let g: UInt64
        let b: UInt64
        switch hex.count {
        case 3:  // RGB (12-bit)
            (a, r, g, b) = (
                255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17
            )
        case 6:  // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:  // ARGB (32-bit)
            (a, r, g, b) = (
                int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF
            )
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            red: CGFloat(r) / 255, green: CGFloat(g) / 255,
            blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

extension UIView {
    @objc func fixInView(_ container: UIView!) -> Void{
        self.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(self);
        NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: container, attribute: .leading, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: container, attribute: .trailing, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: container, attribute: .top, multiplier: 1.0, constant: 0).isActive = true
        NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: container, attribute: .bottom, multiplier: 1.0, constant: 0).isActive = true
        self.layoutIfNeeded()
    }
}

extension AVAsset {
    
    var trackDuration: CGFloat? {
        get async {
            guard let cmTime = try? await self.load(.duration) else { return nil }
            return cmTime.isNumeric ? CGFloat(cmTime.seconds) : nil
        }
    }
    
    var videoTrack: AVAssetTrack? {
        get async {
            try? await self.loadTracks(withMediaType: .video).first
        }
    }
    
    var presentationVideoSize: CGSize? {
        get async {
            guard let videoTrack = await videoTrack,
                  let transform = try? await videoTrack.load(.preferredTransform),
                  let size = try? await videoTrack.load(.naturalSize).applying(transform) else {
                return nil
            }
            return CGSize(width: abs(size.width), height: abs(size.height))
        }
    }

    var naturalVideoSize: CGSize? {
        get async {
            guard let videoTrack = await videoTrack,
                  let size = try? await videoTrack.load(.naturalSize) else {
                return nil
            }
            return size
        }
    }
}
