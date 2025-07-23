//
//  ViewController.swift
//  Video Editor
//
//  Created by Sufian on 10/07/2025.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    private var videoFetcher = VideoFetcher()
    
    private var videoAssets: [PHAsset] = []
    private let cellSpacing: CGFloat = 10
    private var isDataLoaded = false

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isDataLoaded {
            isDataLoaded = true
            getVideoAssets()
            setSubViews()
        }
    }
    
    private func setSubViews() {
        setCollectionView()
    }
    
    private func setCollectionView() {
        collectionView.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
    }
    
    private func getVideoAssets() {
        Task {
            let videos = await self.videoFetcher.fetchVideos()
            update(with: videos)
        }
    }
    
    @MainActor
    private func update(with videoAssets: [PHAsset]) {
        self.videoAssets = videoAssets
        collectionView.reloadData()
    }
    
    private func selectVideo(_ asset: PHAsset) {
        let manager = PHImageManager.default()
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        manager.requestAVAsset(forVideo: asset, options: options) { avasset, _, _ in
            Task {
                if let urlAsset = avasset as? AVURLAsset, let duration = await urlAsset.trackDuration, let size = await avasset?.presentationVideoSize {
                    let videoModel = VideoModel(
                        asset: avasset,
                        url: urlAsset.url,
                        startTime: 0,
                        endTime: duration,
                        videoSize: size,
                        frame: .zero,
                        stickers: []
                    )
                    self.goToEditorView(with: videoModel)
                }
            }
        }
    }
    
    @MainActor
    private func goToEditorView(with videoData: VideoModel) {
        let controller = EditorViewController.instantiate() as! EditorViewController
        controller.videoData = videoData
        navigationController?.pushViewController(controller, animated: true)
    }
}

//MARK:- UICollection View Methods
extension ViewController: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
            return 1
        }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoAssets.count
       }
       
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VideoPickerCollectionViewCell.identifier, for: indexPath) as! VideoPickerCollectionViewCell
        let asset = videoAssets[indexPath.item]
        cell.asset = asset
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: section == 0 ? 70 : 70 )
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let screenWidth = collectionView.frame.size.width
        let inset: CGFloat = 10
        let colum: CGFloat = 3
        let width = (screenWidth - (inset * 2 + cellSpacing * (colum - 1) + 0.1)) / colum
        let height = width * 74 / 109
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return cellSpacing
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = videoAssets[indexPath.item]
        selectVideo(asset)
    }
}
