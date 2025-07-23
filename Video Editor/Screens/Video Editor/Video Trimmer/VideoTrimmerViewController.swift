//
//  VideoTrimmerViewController.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class VideoTrimmerViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var trimmerView: TrimmerView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var videoPlayerView: TrimmerVideoPlayerView!
    var neeedsSetup = true
    var videoAsset: AVAsset!
    var didSelectTimes: ((CGFloat, CGFloat) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if neeedsSetup {
            neeedsSetup = false
            setup()
        }
    }
    
    deinit {
        print("VideoTrimmerViewController deinit")
    }
    
    func dismiss() {
        trimmerView.dismiss()
        videoPlayerView.dismissPlayer()
    }
    
    private func setup() {
        view.backgroundColor = SCREEN_BACKGROUND_COLOR
//        self.setNavigationBar(text: "Trim")
        setNavigationBar()
        setSubViews()
    }
    
    
    private func setSubViews() {
        setVideoView(videoAsset)
        setTrimmerView(videoAsset)
    }
    
private func setNavigationBar() {
    let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonPressed(_:)))
    backButton.tintColor = .white
    navigationItem.leftBarButtonItem = backButton

    let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(nextButtonPressed(_:)))
    doneButton.tintColor = .white
    navigationItem.rightBarButtonItem = doneButton
}
    
    func setVideoView(_ asset: AVAsset) {
        videoPlayerView.setupWithAsset(asset)
        videoPlayerView.currentPlayingTime = { [weak self] time in
            guard let self = self else { return }
            self.trimmerView.setCurrentPlayingTime(time)
        }
    }
    
    func setTrimmerView(_ asset: AVAsset) {
        trimmerView.videoAsset = asset
        trimmerView.didSetThums = { startTime, endTime in
            self.videoPlayerView.setTimesAndPlay(startTime, endTime: endTime)
            self.timeLabel.text = "\(self.formatTimeString(startTime))s ~ \(self.formatTimeString(endTime))s"
        }
        trimmerView.stopVideo = { ok in
            ok == true ? self.videoPlayerView.stop() : self.videoPlayerView.play()
        }
        trimmerView.calculateTimes()
    }
    
    //MaRK:- Button Actions
    @IBAction func backButtonPressed(_ sender: Any?) {
        dismiss(animated: true, completion: nil)
        dismiss()
    }
    
    @IBAction func nextButtonPressed(_ sender: Any?) {
        dismiss(animated: false) {
            self.didSelectTimes?(self.trimmerView.startTime, self.trimmerView.endTime)
        }
        dismiss()
    }
    
    //MARK:- Helper Methods
    
    func formatTimeString(_ value: CGFloat) -> String {
        var time = ""
        if value > 3600 {
            time = String(format:"%02d:%02d:%02d",
                Int(value/3600),
                Int((value/60).truncatingRemainder(dividingBy: 60)),
                Int(value.truncatingRemainder(dividingBy: 60)))
        } else {
            time = String(format:"%02d:%02d",
                Int((value/60).truncatingRemainder(dividingBy: 60)),
                Int(value.truncatingRemainder(dividingBy: 60)))
        }
        return time
    }

}
