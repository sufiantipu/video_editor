//
//  VideoView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class TrimmerVideoPlayerView: VideoView {
    
    deinit {
        print("deinit: TrimmerVideoPlayerView")
    }
    
    func setupWithAsset(_ asset: AVAsset) {
        if let url = (asset as? AVURLAsset)?.url {
            setUrl(url)
        }
    }
    
    func setTimesAndPlay(_ startTime: CGFloat, endTime: CGFloat) {
        super.setTimes(startTime, endTime: endTime)
        play()
    }
}
