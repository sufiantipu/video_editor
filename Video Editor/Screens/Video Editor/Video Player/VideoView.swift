//
//  VideoView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class VideoView: UIView {
    
    var videoUrl: URL!
    var asset: AVAsset?
    var player: AVPlayer?
    var playerLayer: AVPlayerLayer?
    var videoSize: CGSize! = .zero
    
    var isPlaying = false
    var startTime: CGFloat = 0.0
    var endTime: CGFloat = 0.0
    
    var videoLayerView = UIView(frame: .zero)
    
    var didEndPlaying: defaultBlock?
    var currentPlayingTime: ((CGFloat) -> Void)?
    var didUpdateFrame: defaultBlock?
    
    var timeObserver: Any?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
         super.init(coder: aDecoder)
    }
    
    //MARK:- Setup Methods
    
    func setUrl(_ url: URL) {
        self.videoUrl = url
        setup()
        clipsToBounds = true
    }
    
    func setup() {
        self.asset = AVAsset(url: videoUrl)
        Task {
            self.startTime = 0.0
            self.endTime = await asset?.trackDuration ?? 0.0
            setPlayerView()
        }
    }
    
    func setSize() {
        Task {
            if let size = await self.asset?.presentationVideoSize {
                self.videoSize = size
                self.update(with: size)
                self.didUpdateFrame?()
                self.updateFrame()
            }
        }
    }
    
    @MainActor
    func update(with size: CGSize) {
        let imageSize = size
        guard let superview = superview else { return }
        let viewSize = superview.bounds.size
        let imageAspectRatio = imageSize.width / imageSize.height
        let viewAspectRatio = viewSize.width / viewSize.height

        var targetSize = CGSize.zero

        if imageAspectRatio > viewAspectRatio {
            targetSize.width = viewSize.width
            targetSize.height = viewSize.width / imageAspectRatio
        } else {
            targetSize.height = viewSize.height
            targetSize.width = viewSize.height * imageAspectRatio
        }

        let x = (viewSize.width - targetSize.width) / 2
        let y = (viewSize.height - targetSize.height) / 2
        let targetFrame = CGRect(origin: CGPoint(x: x, y: y), size: targetSize)
        self.frame = targetFrame
    }
    
    func updateFrame() {
        videoLayerView.frame = bounds
        playerLayer?.frame = bounds
    }
    
    func setPlayerView() {
        setVideoLayerView()
        setPlayer()
        updateFrame()
    }
    
    func setPlayer() {
        player = AVPlayer(url: videoUrl)
        player?.volume = 0
        setTimeObserver()
        setVideoLayer()
        setSize()
    }
    
    func setTimeObserver() {
        timeObserver = player?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 10), queue: nil) { [weak self] time in
            guard let self = self else { return }
            let seconds = CMTimeGetSeconds(time)
            if seconds.isNaN {
                return
            }
            if self.endTime <= seconds {
                DispatchQueue.main.async {
                    self.seekToStartTime()
                }
                return
            }
            print("Debug currentPlayingTime \(seconds) class -> \(String(describing: type(of: self)))")
            self.currentPlayingTime?(seconds)
        }
    }
    
    func removeVideo() {
        player?.pause()
        player = nil
    }
    
    func setVideoLayerView() {
        insertSubview(videoLayerView, at: 0)
    }
    
    func setVideoLayer() {
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.needsDisplayOnBoundsChange = true
        videoLayerView.layer.sublayers?.removeAll()
        videoLayerView.layer.addSublayer(playerLayer)
        self.playerLayer = playerLayer
    }
    
    //MARK:- Dismis Methods
    
    func dismissPlayer() {
        pause()
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
        }
        player = nil
        videoLayerView.removeFromSuperview()
        didEndPlaying = nil
    }
    
    //MARK:- Player Control
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        pause()
    }
    
    func getVolume() -> Float {
        return self.player?.volume ?? 0.0
    }
    
    //MARK:- Override Methods
    
    
    //MARK:- Helper Methods
    func seekToStartTime() {
        seek(startTime)
        play()
    }
    
    func seek(_ time: Double) {
        let cmTime = CMTime(seconds: time, preferredTimescale: 60000)
        self.player?.seek(to: cmTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    func setTimes(_ startTime: CGFloat, endTime: CGFloat) {
        self.startTime = startTime
        self.endTime = endTime
        seek(startTime)
    }
}
