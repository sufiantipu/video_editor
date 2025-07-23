//
//  VideoFetcher.swift
//  Video Editor
//
//  Created by Sufian on 11/07/2025.
//

import UIKit
import Photos

class VideoFetcher {
    
    private let authorizationManager = PhotoLibraryAuthorizationManager()
    
    func fetchVideos() async -> [PHAsset] {
        let isAuthorized = await authorizationManager.requestAuthorization()
        guard isAuthorized else {
            print("Photo Library access denied.")
            return []
        }
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.video.rawValue)
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let fetchResult = PHAsset.fetchAssets(with: fetchOptions)
        var videos: [PHAsset] = []
        for i in 0..<fetchResult.count {
            videos.append(fetchResult.object(at: i))
        }
        return videos
    }
    
}

actor PhotoLibraryAuthorizationManager {
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            PHPhotoLibrary.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
}
