//
//  TabViewCell.swift
//  Video Editor
//
//  Created by Sufian  on 10/07/2025.
//

import UIKit

class TabViewCell: UICollectionViewCell {

    var iconImageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    var label: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private var selectedColor = UIColor.systemBlue
    private var deselectedColor = UIColor.gray
    
    private var _isSelected = false
    
    var data: TabData! {
        didSet {
            self.updateUI()
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        setupSubviews()
    }
    
    //MARK: subview setup
    
    private func setupSubviews() {
        setImageView()
        setLabel()
    }
    
    private func setImageView() {
        if iconImageView.superview != contentView {
            contentView.addSubview(iconImageView)
            
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor).isActive = true
            iconImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 5).isActive = true
            iconImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
            iconImageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
    }
    
    private func setLabel() {
        if label.superview != contentView {
            contentView.addSubview(label)
            
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
            label.heightAnchor.constraint(equalToConstant: 20).isActive = true
        }
    }
    
    private func updateUI() {
        DispatchQueue.main.async {
            self.iconImageView.image = UIImage(named: self._isSelected ? self.data.selectedIconName : self.data.iconName)
            self.label.text = self.data.name
            self.label.textColor = self._isSelected ? self.selectedColor : self.deselectedColor
//            self.backgroundColor = self._isSelected ? .red : .clear
        }
    }
    
    func select(_ yes: Bool) {
        _isSelected = yes
        updateUI()
    }
}

extension TabViewCell: TabViewCellProtocol {
    func getClass() -> AnyClass {
        return TabViewCell.self
    }
    
    func setData(_ data: TabData) {
        self.data = data
    }
    
    func setSelected(_ value: Bool) {
        _isSelected = value
    }
}




