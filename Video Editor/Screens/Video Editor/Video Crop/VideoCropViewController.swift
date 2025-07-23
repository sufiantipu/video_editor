//
//  VideoCropViewController.swift
//  Video Editor
//
//  Created by Sufian  on 16/07/2025.
//

import UIKit

class VideoCropViewController: UIViewController, Storyboarded {

    @IBOutlet weak var videoView: VideoView!
    @IBOutlet weak var cropView: VideoCropView!
    
    var videoURL: URL!
    
    var isSubviewSet = false
    
    var didFinishCropping: ((_ canvesSize: CGSize, _ cropRect: CGRect) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isSubviewSet {
            isSubviewSet = true
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setSubviews()
    }
    
    func dismiss() {
        videoView.dismissPlayer()
    }
    
    //MARK: Subviews
    
    private func setSubviews() {
        videoView.setUrl(videoURL)
        videoView.didUpdateFrame = { [weak self] in
            guard let self = self else { return }
            self.cropView.setFrame(self.videoView.frame)
            self.videoView.play()
        }
    }

    @IBAction func cropButtonPressed(_ sender: Any?) {
        let cropRectInView = self.cropView.getCropedFrame()
        let videoSize = videoView.videoSize!
        let displaySize = cropView.frame.size  // This is the size of the view displaying the video
        
        // Calculate scale ratios between video size and displayed size
        let scaleX = videoSize.width / displaySize.width
        let scaleY = videoSize.height / displaySize.height

        // Convert the crop rect to video coordinates
        let scaledCropRect = CGRect(
            x: cropRectInView.origin.x * scaleX,
            y: cropRectInView.origin.y * scaleY,
            width: cropRectInView.size.width * scaleX,
            height: cropRectInView.size.height * scaleY
        )

        dismiss(animated: true, completion: nil)
        didFinishCropping?(videoSize, scaledCropRect)
    }

}
