//
//  EditView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit
import AVKit

class EditView: UIView {
    
    private var stickerLayerView: StickerContainerView!
    @IBOutlet weak var videoView: EditorVideoView!
    
    var selecTedSubViewIndex = 0
    
    var videoData: VideoModel?
    
    private var didSetSubviews = false
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comoninit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        comoninit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if !didSetSubviews {
            setSubview()
            didSetSubviews = true
        }
    }
    
    // MARK: - Setup View
    
    private func comoninit() {
        backgroundColor = .clear
    }
    
    private func setSubview() {
        setupStickerLayerView()
        setVideoView()
//        clipsToBounds = true
    }
    
    private func setupStickerLayerView() {
        stickerLayerView = StickerContainerView()
        stickerLayerView.backgroundColor = .clear
        addSubview(stickerLayerView)
    }
    
    private func setVideoView() {
        videoView.didUpdateFrame = { [weak self] in
            guard let self = self else { return }
            self.stickerLayerView.frame = videoView.frame
            let rect = CGRect(origin: .zero, size: videoView.videoSize)
            videoData?.cropRect = rect

        }
        updateVideo()
    }
    
    private func updateVideo() {
        if let videoData = videoData, !videoView.isPlaying {
            videoView.setUrl(videoData.url)
            videoView.setTimes(videoData.startTime, endTime: videoData.endTime)
            videoView.play()
        }
    }
    
    func addNewSticker(_ image: UIImage) {
        stickerLayerView.addNewSticker(image)
    }
    
    func updateFilter(_ filter: String) {
        videoData?.filterName = filter
        videoView.filterName = filter
        videoView.play()
    }
    
    func updateTime(_ startTime: CGFloat, endTime: CGFloat) {
        videoData?.startTime = startTime
        videoData?.endTime = endTime
        videoView.setTimes(startTime, endTime: endTime)
    }
    
    
    func exportVideo() async -> URL? {
        videoView.pause()
        var start: CGFloat?
        var end: CGFloat?
        if let time = videoData?.startTime {
            start = CGFloat(time)
        }
        if let time = videoData?.endTime {
            end = CGFloat(time)
        }
        if let stickerImage = renderStickerLayerAsImage(), let url = videoData?.url {
            do {
                return try await VideoFilterExporter.exportVideoWithFilter(inputURL: url, outputURL: generateExportUrl(), filter: FilterManager.getFilter(with: videoData?.filterName ?? ""), stickerImage: stickerImage, cropRect: videoData?.cropRect, startTime: start, endTime: end)
            } catch {
                print(error.localizedDescription)
            }
//            return try? await withCheckedThrowingContinuation { continuation in
//                VideoFilterExporter.exportVideoWithFilter(inputURL: url, outputURL: generateExportUrl(), filter: FilterManager.randomFilter(), stickerImage: stickerImage, cropRect: videoData?.cropRect) { result in
//                    switch result {
//                    case .success(let url):
//                        continuation.resume(returning: url)
//                    case .failure(let error):
//                        continuation.resume(throwing: error)
//                    }
//                }
//            }
        }
        return nil
    }
    
    //MARK: Helper
    
    private func renderStickerLayerAsImage() -> UIImage? {
        stickerLayerView.deselectAllStickers()
        let renderer = UIGraphicsImageRenderer(bounds: stickerLayerView.bounds)
        return renderer.image { context in
            stickerLayerView.layer.render(in: context.cgContext)
        }
    }
    
    func generateExportUrl() -> URL {
        return FileManager.default.temporaryDirectory.appendingPathComponent("edited-video.mp4")
    }
}
