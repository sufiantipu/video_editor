//
//  EditorViewController.swift
//  Video Editor
//
//  Created by Sufian on 12/07/2025.
//

import UIKit
import AVKit

class EditorViewController: UIViewController, Storyboarded {
    
    @IBOutlet weak var editView: EditView!
    @IBOutlet weak var tabView: TabView!
    
    private var loadingView: UIActivityIndicatorView?
    
    private var isSubViewSetup: Bool = false
    
    var videoData: VideoModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isSubViewSetup {
            editView.videoView.play()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        editView.videoView.pause()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if !isSubViewSetup {
            setSubViews()
            isSubViewSetup = true
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    private func setNavigationBar() {
        let backButton = UIBarButtonItem(image: UIImage(systemName: "chevron.backward"), style: .plain, target: self, action: #selector(backButtonPressed(_:)))
        backButton.tintColor = .white
        navigationItem.leftBarButtonItem = backButton
        
        let shareButton = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareButtonPressed(_:)))
        shareButton.tintColor = .white
        navigationItem.rightBarButtonItem = shareButton
    }
    
    //MARK:- Subview Setting Methods
    
    func setSubViews() {
        setNavigationBar()
        setupEditView()
        settabView()
    }
    
    private func setupEditView() {
        editView.videoData = videoData
    }
    
    private func settabView() {
        let dataArray = [
            TabData("trim_deactive", selectedIcon: "trim", name: "Trim"),
            TabData("filter_deactive", selectedIcon: "filter", name: "Filters"),
            TabData("stickers_deactive", selectedIcon: "stickers", name: "Sticker"),
            TabData("crop_deactive", selectedIcon: "crop", name: "Crop")
        ]
        tabView.setDatas(dataArray)
        tabView.didSelectItem = { [weak self] index in
            guard let self = self else { return }
            switch index {
            case 0:
                if let asset = self.videoData?.asset {
                    self.trimVideo(asset)
                }
            case 1:
                showFilterView()
            case 2:
                showStickerView()
            case 3:
                cropVideo()
            default:
                break
            }
        }
    }
    
    private func trimVideo() {
        
    }
    
    private func showFilterView() {
        editView.updateFilter(FilterManager.randomFilterName())
    }
    
    private func showStickerView() {
        let controller = StickerViewController.instantiate() as! StickerViewController
        controller.didSelect = { [weak self] imageName in
            guard let self = self else { return }
            if let image = UIImage(named: imageName) {
                self.editView.addNewSticker(image)
            }
        }
//        controller.didDisappear = { [weak self] in
//            guard let self = self else { return }
//            self.tabView.isHidden = false
//        }
        if let sheet = controller.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(controller, animated: true)
    }
    
    private func cropVideo() {
        let url = self.videoData.url
        let controller = VideoCropViewController.instantiate() as! VideoCropViewController
        controller.videoURL = url
        controller.modalPresentationStyle = .fullScreen
        controller.didFinishCropping = { [weak self] canvesSize, cropRect in
            guard let self = self else { return }
            self.editView.videoData?.cropRect = cropRect
            self.editView.videoView.update(with: canvesSize, cropRect: cropRect)
        }
        present(controller, animated: true, completion: nil)
    }
    
    //MARK: Helper Methods
    
    private func trimVideo(_ asset: AVAsset) {
        let controller = VideoTrimmerViewController.instantiate() as! VideoTrimmerViewController
        controller.videoAsset = asset
        controller.didSelectTimes = { [weak self] startTime, endTime in
            guard let self = self else { return }
            self.editView.updateTime(startTime, endTime: endTime)
        }
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
    }
    
    // MARK:- Button Action
    
    @IBAction func backButtonPressed(_ sender: Any?) {
        let alert = createAlertWithAction(title: "", message: "Are you sure want to go to the Home Screen", action: UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        })
        topMostViewController().present(alert, animated: true)
    }
    
    
    @IBAction func shareButtonPressed(_ sender: Any?) {
        Task {
            showLoading()
            if let url = await editView.exportVideo() {
                hideLoading()
                let activityViewController = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                activityViewController.popoverPresentationController?.barButtonItem = sender as? UIBarButtonItem
                present(activityViewController, animated: true)
            } else {
                hideLoading()
            }
        }
    }
    
    private func showLoading() {
        if loadingView == nil {
            let spinner = UIActivityIndicatorView(style: .large)
            spinner.center = view.center
            spinner.color = .white
            spinner.hidesWhenStopped = true
            spinner.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(spinner)
            NSLayoutConstraint.activate([
                spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
                spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
            loadingView = spinner
        }
        loadingView?.startAnimating()
        view.isUserInteractionEnabled = false
    }

    private func hideLoading() {
        loadingView?.stopAnimating()
        view.isUserInteractionEnabled = true
    }
}
