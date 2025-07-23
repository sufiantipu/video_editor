//
//  FilterView.swift
//  Video Editor
//
//  Created by Sufian  on 13/07/2025.
//

import UIKit

class FilterView: UIView {
    var selectedIndex = 0
    var coverImage: UIImage!
    var filters = [String]() {
        didSet {
            selectedIndex = 0
            collectionView.reloadData()
            collectionView.scrollToItem(at: IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: false)
        }
    }
    
    var didSelectFilter: ((String) -> Void)?
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setSubview()
    }
    
    private func setSubview() {
        setCollectionView()
    }
    
    private func setCollectionView() {
        collectionView.fixInView(self)
        collectionView.register(FilterViewCell.self, forCellWithReuseIdentifier: FilterViewCell.identifire)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.contentInset = .init(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    //MARK: Public Methods
    
    func setData(with coverImage: UIImage, filters: [String]) {
        self.coverImage = coverImage
        self.filters = filters
    }
}

extension FilterView: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FilterViewCell.identifire, for: indexPath) as! FilterViewCell
        cell.didSelect = { [weak self] name in
            self?.didSelectFilter?(name)
        }
        cell.configure(with: coverImage, filterName: filters[indexPath.row])
        return cell
    }
}

extension FilterView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    }
}

extension FilterView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.frame.size.height
        return CGSize(width: height, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}
