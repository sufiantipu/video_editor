//
//  EditorVideoView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class EditorVideoView: VideoView {
    
    var filterName: String = ""
    
    var cropRect: CGRect?
    
    override func setPlayer() {
        if let asset = asset {
            Task {
                let item = AVPlayerItem(asset: asset)
                item.videoComposition = await makeDynamicFilterComposition(for: asset)
                player = AVPlayer(playerItem: item)
                player?.volume = 0.0
                self.setTimeObserver()
                self.setVideoLayer()
                self.setSize()
                self.play()
            }
        }
    }
    
    private func makeDynamicFilterComposition(for asset: AVAsset) async -> AVVideoComposition? {
        await withCheckedContinuation { continuation in
            AVVideoComposition.videoComposition(with: asset, applyingCIFiltersWithHandler: { [weak self] request in
                guard let self = self else { return }

                if !self.filterName.isEmpty {
                    print("Debug filter \(filterName)")
                    let source = request.sourceImage.clampedToExtent()
                    let filter = CIFilter(name: self.filterName)
                    filter?.setValue(source, forKey: kCIInputImageKey)

                    let output = filter?.outputImage?.cropped(to: source.extent) ?? source
                    request.finish(with: output, context: nil)
                } else {
                    request.finish(with: request.sourceImage, context: nil)
                }
            }, completionHandler: { composition, _ in
                continuation.resume(returning: composition)
            })
        }
    }
    
    func update(with size: CGSize, canvesSize: CGSize, cropRect: CGRect?) {
        guard let superview = superview else { return }

        // Scale factor between canvasSize (original video size) and display size
        let scaleX = size.width / canvesSize.width
        let scaleY = size.height / canvesSize.height

        var displayRect: CGRect

        if let cropRect = cropRect {
            // Scale cropRect from original video size to current display size
            let scaledX = cropRect.origin.x * scaleX
            let scaledY = cropRect.origin.y * scaleY
            let scaledWidth = cropRect.width * scaleX
            let scaledHeight = cropRect.height * scaleY
            displayRect = CGRect(x: scaledX, y: scaledY, width: scaledWidth, height: scaledHeight)
        } else {
            // No crop — show entire video
            displayRect = CGRect(origin: .zero, size: size)
        }

        // Position relative to the original video frame
        // Calculate top-left origin in superview based on scaled cropRect
        let originX = (superview.bounds.width - size.width) / 2 - displayRect.origin.x
        let originY = (superview.bounds.height - size.height) / 2 - displayRect.origin.y

        self.frame = CGRect(origin: CGPoint(x: originX, y: originY), size: size)

        // Ensure the video layer view and playerLayer fill the full video frame
        videoLayerView.frame = self.bounds
        playerLayer?.frame = videoLayerView.bounds
    }
    
    func update(with canvesSize: CGSize, cropRect: CGRect) {
        update(with: cropRect.size)
        
        let width = canvesSize.width / cropRect.width * bounds.width
        let height = canvesSize.height / cropRect.height * bounds.height
        let x = cropRect.origin.x / canvesSize.width * width
        let y = cropRect.origin.y / canvesSize.height * height
//        let frame = CGRect(x: x, y: y, width: width, height: height)
        
        print("\(canvesSize.width / cropRect.origin.x) = \(width / bounds.origin.x)")
        
        let videolanLayerFrame = CGRect(x: -x, y: -y, width: width, height: height)
        
        videoLayerView.frame = videolanLayerFrame
        playerLayer?.frame = videoLayerView.bounds
    }
    
}
