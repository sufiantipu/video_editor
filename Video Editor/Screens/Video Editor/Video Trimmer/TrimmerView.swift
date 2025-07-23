//
//  TrimmerView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class TrimmerView: UIView {
    
    var videoFrameView: VideoFrameView!
    var leftThumbView: ThumbView!
    var rightThumbView: ThumbView!
    var leftCoverView: UIView!
    var rightCoverView: UIView!
    var topLine: UIView!
    var bottomLine: UIView!
    var indicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 1
        return view
    }()
    
    var indicatorWidth: CGFloat = 3
    
    var videoAsset: AVAsset! {
        didSet {
            self.setup()
        }
    }
    
    let thumbWidth: CGFloat = 20
    var startTime: CGFloat = 0.0
    var endTime: CGFloat = 0.0
    var duration: CGFloat = 0.0
    
    var didSetThums: ((CGFloat, CGFloat) -> Void)?
    var stopVideo: ((Bool) -> Void)?
    

    init(_ frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //setSubView()
    }
    
    func dismiss() {
        leftThumbView.dismiss()
        rightThumbView.dismiss()
        videoFrameView.dismissView()
        videoFrameView = nil
        didSetThums = nil
        stopVideo = nil
    }
    
    func setup() {
        backgroundColor = .clear
        setSubView()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.calculateTimes()
        }
    }
    
    func setSubView() {
        Task {
            duration = await videoAsset.trackDuration ?? 0.0
        }
        setVideoFrameView()
        setLeftCoverView()
        setRightCoverView()
        setTopLineView()
        setBottomLineView()
        setLeftThumView()
        setRightThumView()
        adjustFrames()
        setIndicatorView()
    }
    
    func setVideoFrameView() {
        videoFrameView = VideoFrameView(frame: CGRect(x: thumbWidth, y: 0, width: frame.size.width - (thumbWidth * 2), height: frame.size.height), videoAsset: videoAsset)
        videoFrameView.isScrolling = { ok in
            self.stopVideo?(ok)
            self.calculateTimes()
        }
        addSubview(videoFrameView)
    }
    
    func setLeftThumView() {
        leftThumbView = ThumbView(frame: CGRect(x: 0, y: 0, width: thumbWidth, height: videoFrameView.frame.size.height), image: UIImage(named: "left_thumb"), isLeft: true)
        leftThumbView.canMove = { [weak self] x in
            guard let self = self else { return false }
            if x >= 0 && x + self.thumbWidth + 10 <= self.rightThumbView.frame.origin.x {
                return true
            }
            return false
        }
        leftThumbView.didMove = {[weak self] in
            guard let self = self else { return }
            self.adjustFrames()
        }
        leftThumbView.isMoving = { [weak self] ok in
            guard let self = self else { return }
            self.stopVideo?(ok)
        }
        addSubview(leftThumbView)
    }
    
    func setRightThumView() {
        rightThumbView = ThumbView(frame: CGRect(x: frame.size.width - thumbWidth, y: 0, width: thumbWidth, height: videoFrameView.frame.size.height), image: UIImage(named: "right_thumb"), isLeft: true)
        rightThumbView.canMove = { [weak self] x in
            guard let self = self else { return false }
            if x - (10 + self.thumbWidth) >= self.leftThumbView.frame.origin.x && x + self.thumbWidth <= self.frame.size.width {
                return true
            }
            return false
        }
        rightThumbView.didMove = {
            self.adjustFrames()
        }
        rightThumbView.isMoving = { [weak self] ok in
            guard let self = self else { return }
            self.stopVideo?(ok)
        }
        addSubview(rightThumbView)
    }
    
    func setLeftCoverView() {
        leftCoverView = UIView()
        leftCoverView.backgroundColor = BRIGHT_COLOR.withAlphaComponent(0.58)
        addSubview(leftCoverView)
    }
    
    func setRightCoverView() {
        rightCoverView = UIView()
        rightCoverView.backgroundColor = BRIGHT_COLOR.withAlphaComponent(0.58)
        addSubview(rightCoverView)
    }
    
    func setTopLineView() {
        topLine = UIView()
        topLine.backgroundColor = BRIGHT_COLOR
        addSubview(topLine)
    }
    
    func setBottomLineView() {
        bottomLine = UIView()
        bottomLine.backgroundColor = BRIGHT_COLOR
        addSubview(bottomLine)
    }
    
    private func setIndicatorView() {
        indicatorView.frame = CGRect(x: leftThumbView.frame.maxX, y: 0, width: indicatorWidth, height: self.bounds.height)
        insertSubview(indicatorView, belowSubview: topLine)
    }
    
    deinit {
        print("deinit -> TrimmerView")
    }
    
    //MARK:- Frmae Adjustment
    
    func adjustFrames() {
        adjustLeftCoverViewFrame()
        adjustRightCoverViewFrame()
        adjustTopLineViewFrame()
        adjustBottomLineViewFrame()
        calculateTimes()
    }
    
    func calculateTimes() {
        startTime = calculateTime(with: leftThumbView.frame.origin.x)
        endTime = calculateTime(with: rightThumbView.frame.origin.x)
        didSetThums?(startTime, endTime)
    }
    
    private func calculateTime(with xPos: CGFloat) -> CGFloat {
        return (xPos * duration) / bounds.width
    }
    
    func adjustLeftThumViewFrame() {
        
    }
    
    func adjustRightThumViewFrame() {
        
    }
    
    func adjustLeftCoverViewFrame() {
        leftCoverView.frame = CGRect(x: videoFrameView.frame.origin.x, y: videoFrameView.frame.origin.y, width: leftThumbView.frame.origin.x, height: videoFrameView.frame.size.height)
    }
    
    func adjustRightCoverViewFrame() {
        rightCoverView.frame = CGRect(x: rightThumbView.frame.origin.x, y: videoFrameView.frame.origin.y, width: frame.size.width - (rightThumbView.frame.origin.x + thumbWidth), height: videoFrameView.frame.size.height)
    }
    
    func adjustTopLineViewFrame() {
        topLine.frame = CGRect(x: leftThumbView.frame.origin.x + thumbWidth, y: videoFrameView.frame.origin.y, width: rightThumbView.frame.origin.x - (leftThumbView.frame.origin.x + thumbWidth), height: 1)
    }
    
    func adjustBottomLineViewFrame() {
        bottomLine.frame = CGRect(x: leftThumbView.frame.origin.x + thumbWidth, y: videoFrameView.frame.origin.y + videoFrameView.frame.size.height - 1, width: rightThumbView.frame.origin.x - (leftThumbView.frame.origin.x + thumbWidth), height: 1)
    }
    
    //MARK:- Helper Methods
    
    func setCurrentPlayingTime(_ time: CGFloat) {
        if endTime > startTime {
            let totalGap = rightThumbView.frame.minX - leftThumbView.frame.maxX
            let timeDiffrence = endTime - startTime
            let currentTime = time - startTime
            let indicatorPosX = totalGap * currentTime / timeDiffrence + leftThumbView.frame.maxX
            let y = videoFrameView.frame.origin.y
            let height = videoFrameView.frame.size.height
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.indicatorView.frame = CGRect(x: indicatorPosX, y: y, width: self.indicatorWidth, height: height)
            }
        }
    }
    
    func updateSubViews() {
        
    }
    
}
