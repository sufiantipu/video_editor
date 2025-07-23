//
//  TabView.swift
//  Video Editor
//
//  Created by Sufian  on 10/07/2025.
//

import UIKit

class TabView: UIView {
    
    var didSelectItem: ((Int) -> Void)?
    var dataArray: [TabData] = [TabData]()
    var collectionViewCell: TabViewCellProtocol = TabViewCell()
    var selectedIndex: Int = -1
    
    private lazy var collectionView: UICollectionView = { [unowned self] in
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isDirectionalLockEnabled = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.contentInset = .zero
        return collectionView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comonInit()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        comonInit()
    }
    
    private func comonInit() {
        setSubviews()
        backgroundColor = .clear
    }
    
    //MARK: subview Setup
    
    private func setSubviews() {
        setCollectionView()
    }
    
    private func setCollectionView() {
        collectionView.register( collectionViewCell.getClass(), forCellWithReuseIdentifier: collectionViewCell.reuseIdentifier)
        collectionView.fixInView(self)
        collectionView.delegate = self
        collectionView.dataSource = self
    }
    
    //MARK: Public Methods
    
    func setDatas(_ datas: [TabData]) {
        self.dataArray = datas
        collectionView.reloadData()
    }
}

extension TabView: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: collectionViewCell.reuseIdentifier, for: indexPath)
        updateCell(cell, data: dataArray[indexPath.row], isSelected: selectedIndex == indexPath.row)
        return cell
    }
    
    func updateCell(_ cell: UICollectionViewCell, data: TabData, isSelected: Bool) {
        let cell = cell as! TabViewCellProtocol
        cell.setSelected(isSelected)
        cell.setData(data)
    }
}

extension TabView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelectItem?(indexPath.row)
    }
    
    func didSelectNewIndex(_ index: Int) {
        if selectedIndex == index {
            selectedIndex = -1
            collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else {
            var indexes = [IndexPath]()
            if selectedIndex != -1 {
                indexes.append(IndexPath(item: selectedIndex, section: 0))
            }
            indexes.append(IndexPath(item: index, section: 0))
            selectedIndex = index
            collectionView.reloadItems(at: indexes)
        }
    }
}

extension TabView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.collectionView.bounds.size.width) / CGFloat(self.dataArray.count)
        return CGSize(width: width, height: collectionView.frame.size.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}
