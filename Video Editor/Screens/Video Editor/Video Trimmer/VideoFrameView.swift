//
//  VideoFrameView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class VideoFrameView: UIView {
    
    var videoAsset: AVAsset!
    
    var imageArray = [UIImageView]()
    var totalFrameCount = 0
    var frameDuration: CGFloat!
    
    var isScrolling: ((Bool) -> Void)?
    
    init(frame: CGRect, videoAsset: AVAsset) {
        super.init(frame: frame)
        self.videoAsset = videoAsset
        calculateTotalFrame()
        adjustFrame()
        setVideoFrames()
        DispatchQueue.global(qos: .userInteractive).async {
            self.makeFrameThumnails()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func adjustFrame() {
        let height = frame.size.width / Double(totalFrameCount)
        frame = CGRect(origin: frame.origin, size: CGSize(width: frame.size.width, height: height))
    }
    
    private func setVideoFrames() {
        let height = frame.size.height
        var x: CGFloat = 0.0
        for _ in 0..<totalFrameCount {
            let imageView = UIImageView(frame: CGRect(x: x, y: 0, width: height, height: height))
            addSubview(imageView)
            imageArray.append(imageView)
            x += height
        }
    }
    
    
    private func makeFrameThumnails() {
        Task {
            await calculatePerFrameDuration()
            self.makeThumbnails(videoAsset)
        }
    }
    
    private func calculateTotalFrame() {
        let height = frame.size.height
        totalFrameCount = Int(frame.size.width / height)
        if Double(totalFrameCount) * height < frame.size.width {
            totalFrameCount += 1
        }
    }
    
    func dismissView() {
        isScrolling = nil
        removeFromSuperview()
    }
    
    deinit {
        print("deinit -> VideoFrameView")
    }
    
    func makeThumbnails(_ videoAsset: AVAsset) {
        let imageGenerator = AVAssetImageGenerator(asset: videoAsset)
        imageGenerator.appliesPreferredTrackTransform = true
        imageGenerator.requestedTimeToleranceAfter    = CMTime.zero;
        imageGenerator.requestedTimeToleranceBefore   = CMTime.zero;
        imageGenerator.maximumSize = CGSize(width: 100, height: 100)
        
        var time = 0.0
        for i in 0..<imageArray.count {
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTime(seconds: time, preferredTimescale: 60000),actualTime: nil)
                DispatchQueue.main.async {
                    self.imageArray[i].image = UIImage(cgImage: cgImage)
                }
            } catch _ {
                print("image generetor error")
            }
            time += frameDuration
        }
    }
    
    private func calculatePerFrameDuration() async {
        if let duration =  await videoAsset.trackDuration {
            frameDuration = duration / CGFloat(totalFrameCount)
        }
    }
}
