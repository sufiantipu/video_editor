//
//  FilterViewCell.swift
//  Video Editor
//
//  Created by Sufian  on 13/07/2025.
//

import UIKit

class FilterViewCell: UICollectionViewCell {
    
    static let identifire = "FilterListCell"
    
    var _isSelected: Bool = false {
        didSet {
            layer.borderWidth = _isSelected ? 2 : 0
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.isUserInteractionEnabled = true
        return iv
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.numberOfLines = 1
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private var currentFilterName: String?
    private var imageLoadTask: Task<Void, Never>?
    
    var didSelect: ((String) -> Void)?
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.masksToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageLoadTask?.cancel()
        imageLoadTask = nil
        imageView.image = nil
        currentFilterName = nil
        nameLabel.text = nil
    }
    
    func configure(with image: UIImage, filterName: String) {
        setupIfNeeded()
        imageView.image = nil
        currentFilterName = filterName
        
        imageLoadTask = Task {
            if !Task.isCancelled, currentFilterName == filterName, let filtered = await FilterManager.shared.applyFilter(to: image, filterName: filterName) {
                DispatchQueue.main.async {
                    self.imageView.image = filtered
                }
            }
        }
    }
    
    private func setupIfNeeded() {
        guard imageView.superview == nil else { return }
        
        contentView.addSubview(imageView)
        contentView.addSubview(nameLabel)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            imageView.widthAnchor.constraint(equalToConstant: 60),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            
            nameLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 3),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            nameLabel.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
        
        layoutIfNeeded()
        
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2
        
        setupTapGesture()
    }
    
    private func setupTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        imageView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func imageTapped() {
        if let filterName = currentFilterName {
            didSelect?(filterName)
        }
    }
}
