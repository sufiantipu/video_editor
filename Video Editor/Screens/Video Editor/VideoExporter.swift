//
//  VideoFilterExporter.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import AVFoundation
import UIKit
import CoreImage

class VideoFilterExporter {
    
    enum ExportError: Error {
        case invalidInputURL
        case assetCreationFailed
        case exportFailed(String)
        case videoTrackNotFound
        case invalidTimeRange
    }
    
    static func exportVideoWithFilter(
        inputURL: URL,
        outputURL: URL,
        filter: CIFilter? = nil,
        stickerImage: UIImage? = nil,
        cropRect: CGRect? = nil,
        startTime: CGFloat? = nil,
        endTime: CGFloat? = nil,
        quality: String = AVAssetExportPresetHighestQuality
    ) async throws -> URL {
        guard FileManager.default.fileExists(atPath: inputURL.path) else {
            throw ExportError.invalidInputURL
        }
        if FileManager.default.fileExists(atPath: outputURL.path) {
            try? FileManager.default.removeItem(at: outputURL)
        }
        let asset = AVAsset(url: inputURL)
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        guard let videoTrack = videoTracks.first else {
            throw ExportError.videoTrackNotFound
        }
        let assetDuration = try await asset.load(.duration)
        let exportStartTime = startTime != nil ? CMTime(seconds: Double(startTime!), preferredTimescale: 600) : .zero
        let exportEndTime = endTime != nil ? CMTime(seconds: Double(endTime!), preferredTimescale: 600) : assetDuration
        guard exportStartTime.isValid && exportEndTime.isValid &&
              exportStartTime < exportEndTime &&
              exportStartTime >= .zero &&
              exportEndTime <= assetDuration else {
            throw ExportError.invalidTimeRange
        }
        let exportDuration = exportEndTime - exportStartTime
        let exportTimeRange = CMTimeRange(start: exportStartTime, duration: exportDuration)
        let composition = AVMutableComposition()
        guard let compositionVideoTrack = composition.addMutableTrack(
            withMediaType: .video,
            preferredTrackID: kCMPersistentTrackID_Invalid
        ) else {
            throw ExportError.assetCreationFailed
        }
        let audioTracks = try? await asset.loadTracks(withMediaType: .audio)
        if let audioTrack = audioTracks?.first {
            if let compositionAudioTrack = composition.addMutableTrack(
                withMediaType: .audio,
                preferredTrackID: kCMPersistentTrackID_Invalid
            ) {
                do {
                    try compositionAudioTrack.insertTimeRange(
                        exportTimeRange,
                        of: audioTrack,
                        at: .zero
                    )
                } catch {
                    print("Failed to add audio track: \(error)")
                }
            }
        }
        do {
            try compositionVideoTrack.insertTimeRange(
                exportTimeRange,
                of: videoTrack,
                at: .zero
            )
        } catch {
            throw ExportError.exportFailed("Failed to insert video track: \(error)")
        }
        let videoSize = try await videoTrack.load(.naturalSize)
        let transform = try await videoTrack.load(.preferredTransform)
        guard let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: quality
        ) else {
            throw ExportError.assetCreationFailed
        }
        exportSession.outputURL = outputURL
        exportSession.outputFileType = .mp4
        exportSession.shouldOptimizeForNetworkUse = true
        if filter != nil || stickerImage != nil || cropRect != nil {
            let videoComposition = try await createVideoComposition(
                asset: composition,
                videoSize: videoSize,
                transform: transform,
                filter: filter,
                stickerImage: stickerImage,
                cropRect: cropRect,
                duration: exportDuration
            )
            exportSession.videoComposition = videoComposition
        }
        return try await withCheckedThrowingContinuation { continuation in
            exportSession.exportAsynchronously {
                switch exportSession.status {
                case .completed:
                    continuation.resume(returning: outputURL)
                case .failed:
                    let error = exportSession.error?.localizedDescription ?? "Unknown error"
                    continuation.resume(throwing: ExportError.exportFailed(error))
                case .cancelled:
                    continuation.resume(throwing: ExportError.exportFailed("Export cancelled"))
                default:
                    continuation.resume(throwing: ExportError.exportFailed("Export failed with status: \(exportSession.status.rawValue)"))
                }
            }
        }
    }
    
    private static func createVideoComposition(
        asset: AVAsset,
        videoSize: CGSize,
        transform: CGAffineTransform,
        filter: CIFilter?,
        stickerImage: UIImage?,
        cropRect: CGRect?,
        duration: CMTime
    ) async throws -> AVMutableVideoComposition {
        let transformedSize = videoSize.applying(transform)
        let renderSize = CGSize(width: abs(transformedSize.width), height: abs(transformedSize.height))
        let finalSize = cropRect?.size ?? renderSize
        let videoComposition = AVMutableVideoComposition()
        videoComposition.renderSize = finalSize
        videoComposition.frameDuration = CMTime(value: 1, timescale: 30)
        let instruction = AVMutableVideoCompositionInstruction()
        instruction.timeRange = CMTimeRange(start: .zero, duration: duration)
        let videoTracks = try await asset.loadTracks(withMediaType: .video)
        guard let videoTrack = videoTracks.first else {
            return videoComposition
        }
        let layerInstruction = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)
        
        if let cropRect = cropRect {
            let cropTransform = CGAffineTransform.identity
                .translatedBy(x: -cropRect.origin.x, y: -cropRect.origin.y)
            let combinedTransform = transform.concatenating(cropTransform)
            layerInstruction.setTransform(combinedTransform, at: .zero)
        } else {
            layerInstruction.setTransform(transform, at: .zero)
        }
        instruction.layerInstructions = [layerInstruction]
        videoComposition.instructions = [instruction]
        if let stickerImage = stickerImage {
            let parentLayer = CALayer()
            let videoLayer = CALayer()
            let overlayLayer = CALayer()
            parentLayer.frame = CGRect(origin: .zero, size: finalSize)
            videoLayer.frame = CGRect(origin: .zero, size: finalSize)
            overlayLayer.frame = CGRect(origin: .zero, size: finalSize)
            let stickerLayer = createStickerLayer(
                image: stickerImage,
                videoSize: finalSize
            )
            overlayLayer.addSublayer(stickerLayer)
            parentLayer.addSublayer(videoLayer)
            parentLayer.addSublayer(overlayLayer)
            videoComposition.animationTool = AVVideoCompositionCoreAnimationTool(
                postProcessingAsVideoLayer: videoLayer,
                in: parentLayer
            )
        }
        
        if let filter = filter {
            videoComposition.customVideoCompositorClass = FilterVideoCompositor.self
            FilterVideoCompositor.currentFilter = filter
            FilterVideoCompositor.originalTransform = transform
            FilterVideoCompositor.originalVideoSize = videoSize
            FilterVideoCompositor.targetRenderSize = finalSize
            layerInstruction.setTransform(.identity, at: .zero)
        }
        
        return videoComposition
    }
    
    private static func createStickerLayer(image: UIImage, videoSize: CGSize) -> CALayer {
        let imageLayer = CALayer()
        imageLayer.contents = image.cgImage
        let imageSize = image.size
        let scaleX = videoSize.width / imageSize.width
        let scaleY = videoSize.height / imageSize.height
        let scale = min(scaleX, scaleY)
        let scaledWidth = imageSize.width * scale
        let scaledHeight = imageSize.height * scale
        let x = (videoSize.width - scaledWidth) / 2
        let y = (videoSize.height - scaledHeight) / 2
        imageLayer.frame = CGRect(x: x, y: y, width: scaledWidth, height: scaledHeight)
        imageLayer.contentsGravity = .resizeAspect
        return imageLayer
    }
}

class FilterVideoCompositor: NSObject, AVVideoCompositing {
    static var currentFilter: CIFilter?
    static var originalTransform: CGAffineTransform = .identity
    static var originalVideoSize: CGSize = .zero
    static var targetRenderSize: CGSize = .zero
    
    var sourcePixelBufferAttributes: [String : Any]? = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    
    var requiredPixelBufferAttributesForRenderContext: [String : Any] = [
        kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
    ]
    
    func renderContextChanged(_ newRenderContext: AVVideoCompositionRenderContext) {
        // Handle render context changes
    }
    
    func startRequest(_ request: AVAsynchronousVideoCompositionRequest) {
        guard let sourcePixelBuffer = request.sourceFrame(byTrackID: CMPersistentTrackID(truncating: request.sourceTrackIDs.first!)) else {
            request.finish(with: NSError(domain: "FilterError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Source frame not found"]))
            return
        }
        let bufferWidth = CVPixelBufferGetWidth(sourcePixelBuffer)
        let bufferHeight = CVPixelBufferGetHeight(sourcePixelBuffer)
        
        print("Source pixel buffer size: \(bufferWidth) x \(bufferHeight)")
        print("Original video size: \(FilterVideoCompositor.originalVideoSize)")
        print("Target render size: \(FilterVideoCompositor.targetRenderSize)")
        
        guard let filter = FilterVideoCompositor.currentFilter else {
            request.finish(withComposedVideoFrame: sourcePixelBuffer)
            return
        }
        var sourceImage = CIImage(cvPixelBuffer: sourcePixelBuffer)
        let originalTransform = FilterVideoCompositor.originalTransform
        if !originalTransform.isIdentity {
            let correctionTransform = originalTransform.inverted()
            sourceImage = sourceImage.transformed(by: correctionTransform)
            let imageExtent = sourceImage.extent
            let centeringTransform = CGAffineTransform(translationX: -imageExtent.origin.x, y: -imageExtent.origin.y)
            sourceImage = sourceImage.transformed(by: centeringTransform)
        }
        filter.setValue(sourceImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage else {
            request.finish(with: NSError(domain: "FilterError", code: 2, userInfo: [NSLocalizedDescriptionKey: "Filter output failed"]))
            return
        }
        guard let outputPixelBuffer = request.renderContext.newPixelBuffer() else {
            request.finish(with: NSError(domain: "FilterError", code: 3, userInfo: [NSLocalizedDescriptionKey: "Could not create output pixel buffer"]))
            return
        }
        
        print("Output pixel buffer size: \(CVPixelBufferGetWidth(outputPixelBuffer)) x \(CVPixelBufferGetHeight(outputPixelBuffer))")
        
        let ciContext = CIContext()
        let renderRect = CGRect(origin: .zero, size: FilterVideoCompositor.targetRenderSize)
        ciContext.render(outputImage, to: outputPixelBuffer, bounds: renderRect, colorSpace: CGColorSpaceCreateDeviceRGB())
        request.finish(withComposedVideoFrame: outputPixelBuffer)
    }
}
