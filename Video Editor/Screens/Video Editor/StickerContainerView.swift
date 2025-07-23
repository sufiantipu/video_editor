//
//  StickerContainerView.swift
//  Video Editor
//
//  Created by Sufian  on 15/07/2025.
//

import UIKit

class StickerContainerView: UIView {
    
    var touchStartPoint: CGPoint!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews() {
        backgroundColor = .clear
        setTapGesture()
    }
    
    func setTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapGestureAction(_:)))
        tap.numberOfTapsRequired = 1
        addGestureRecognizer(tap)
    }
    
    
    //MARK:- Helper Methods
    
    func addNewSticker(_ image: UIImage) {
        let width = frame.size.width / 3
        let height = width * image.size.height / image.size.width
        let sticker = Sticker(frame: CGRect(x: 0, y: 0, width: width, height: height))
        addSubview(sticker)
        sticker.image = image
        sticker.center = CGPoint(x: frame.size.width / 2, y: frame.size.height / 2)
        addTapGestureTo(sticker)
    }
    
    func addTapGestureTo(_ sticker: UIView) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(stickerTapGestureAction(_:)))
        tap.numberOfTapsRequired = 1
        sticker.addGestureRecognizer(tap)
    }
    
    @objc func tapGestureAction(_ recognizer: UITapGestureRecognizer) {
       deselectAllStickers()
    }
    
    @objc func stickerTapGestureAction(_ recognizer: UITapGestureRecognizer) {
        guard let sticker = recognizer.view as? Sticker else {
            return
        }
        deselectAllStickers()
        sticker.makeSelected(true)
    }
    
    func deselectAllStickers() {
        for subView in subviews {
            if let sticker = subView as? Sticker {
                sticker.makeSelected(false)
            }
        }
    }
    
    func isAnyStickerSelected() -> Bool {
        for subView in subviews {
            if subView.isKind(of: Sticker.self) {
                let sticker = subView as! Sticker
                if sticker.isSelected {
                    return true
                }
            }
        }
        return false
    }
    
    //MARK:- Touch Event Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        deselectAllStickers()
    }

}


extension StickerContainerView: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}
