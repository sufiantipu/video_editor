//
//  ThumbView.swift
//  Video Editor
//
//  Created by Sufian  on 12/07/2025.
//

import UIKit

class ThumbView: UIImageView {
    
    var isLeft = false
    var canMove: ((CGFloat) -> Bool)?
    var didMove: (() -> Void)?
    var isMoving: ((Bool) -> Void)?
    
    init(frame: CGRect, image: UIImage?, isLeft: Bool) {
        super.init(frame: frame)
        self.image = image
        self.isLeft = isLeft
        isUserInteractionEnabled = true
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func dismiss() {
        canMove = nil
        didMove = nil
        isMoving = nil
    }
    
    deinit {
        print("deinit: ThumbView")
    }
    
    func setup() {
        setPanGesture()
    }
    
    func setPanGesture() {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction(_:)))
        addGestureRecognizer(pan)
    }
    
    //MARK:- Helper Methods
    
    @objc func panAction(_ recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .ended {
            isMoving?(false)
        } else if recognizer.state == .began {
            isMoving?(true)
        }
        let translation = recognizer.translation(in: self)
        if let canMove = canMove, canMove(translation.x + frame.origin.x) {
            frame = CGRect(origin: CGPoint(x: translation.x + frame.origin.x, y: 0), size: frame.size)
            didMove?()
        }
        recognizer.setTranslation(.zero, in: self)
    }
}
