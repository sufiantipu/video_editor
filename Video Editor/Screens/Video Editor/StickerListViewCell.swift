//
//  StickerListViewCell.swift
//  Video Editor
//
//  Created by Sufian on 16/07/2025.
//

import UIKit

class StickerListViewCell: UICollectionViewCell {
    
    static let identifire = "StickerListCell"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupIfNeeded()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
    
    private func setupIfNeeded() {
        guard imageView.superview == nil else { return }
        
        contentView.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        layoutIfNeeded()
        
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
    }
}
