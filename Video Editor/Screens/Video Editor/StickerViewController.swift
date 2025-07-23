//
//  StickerViewController.swift
//  Video Editor
//
//  Created by Sufian  on 16/07/2025.
//

import UIKit

class StickerViewController: UIViewController, Storyboarded {
    
    private var isSubViewSet = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var didDisappear: defaultBlock?
    var didSelect: ((String) -> Void)?
    
    var images = ["emoji1", "emoji2", "emoji3"]

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Do any additional setup after loading the view.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didDisappear?()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isSubViewSet {
            setupSubViews()
            isSubViewSet = true
        }
    }
    
    private func setupSubViews() {
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
    }
}

extension StickerViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: StickerListViewCell.identifire, for: indexPath) as! StickerListViewCell
        cell.imageView.image = UIImage(named: images[indexPath.row])
        return cell
    }
}

extension StickerViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        didSelect?(images[indexPath.row])
    }
}

extension StickerViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = (collectionView.frame.size.width - 35) / 3
        return CGSize(width: height, height: height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
