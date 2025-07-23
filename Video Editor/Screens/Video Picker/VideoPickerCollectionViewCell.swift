//
//  VideoPickerCollectionViewCell.swift
//  Video Editor
//
//  Created by Sufian  on 11/07/2025.
//

import UIKit
import Photos

class VideoPickerCollectionViewCell: UICollectionViewCell {
    static let identifier: String = "VideoPickerCell"
    
    @IBOutlet weak var imageView: UIImageView!
    
    var asset: PHAsset! {
        didSet { load() }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        layer.cornerRadius = 4
        imageView.backgroundColor = .white
    }
    
    func load() {
        let manager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = true
        manager.requestImage(for: asset, targetSize: frame.size, contentMode: .default, options: requestOptions, resultHandler: { (image, info) in
            DispatchQueue.main.async {
                self.imageView.image = image
            }
        })
    }
}
