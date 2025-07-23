//
//  FilterManager.swift
//  Video Editor
//
//  Created by Sufian on 13/07/2025.
//

import UIKit
import AVFoundation
import CoreImage
import CoreImage.CIFilterBuiltins

final class FilterManager {
    
static let filterNames = ["CISepiaTone", "CIPhotoEffectMono", "CIPhotoEffectNoir", "CIPhotoEffectChrome", "CIPhotoEffectFade"]

    static func randomFilterName() -> String {
        return filterNames.randomElement() ?? "CISepiaTone"
    }

    static func randomFilter() -> CIFilter? {
        let name = randomFilterName()
        return CIFilter(name: name)
    }
    
    static func getFilter(with name: String) -> CIFilter? {
        return CIFilter(name: name)
    }
    
    static let shared = FilterManager()
    private init() {}
    
    private let context = CIContext()
    
    func applyFilter(to image: UIImage, filterName: String) async -> UIImage? {
        guard let ciImage = CIImage(image: image),
              let filter = CIFilter(name: filterName) else {
            return nil
        }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let outputImage = filter.outputImage,
              let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
    
    
}
