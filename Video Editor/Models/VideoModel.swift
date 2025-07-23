//
//  VideoModel.swift
//  Video Editor
//
//  Created by Sufian on 15/07/2025.
//

import UIKit
import AVKit

struct VideoModel {
    var asset: AVAsset?
    var url: URL
    var startTime: Double
    var endTime: Double
    var videoSize: CGSize
    var frame: CGRect
    var cropRect: CGRect?
    var filterName: String = ""
    var stickers = [StickerModel]()
}

struct StickerModel {
    var url: URL
    var frame: CGRect
    var angle: CGFloat
}
