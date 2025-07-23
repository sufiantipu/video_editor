//
//  VideoCropView.swift
//  Video Editor
//
//  Created by Sufian  on 16/07/2025.
//

import UIKit
import AVKit

class VideoCropView: UIView {
    
    let pin1 = UIImageView(image: UIImage(named: "Pin"))
    let pin2 = UIImageView(image: UIImage(named: "Pin"))
    let pin3 = UIImageView(image: UIImage(named: "Pin"))
    let pin4 = UIImageView(image: UIImage(named: "Pin"))
    
    var coverView: CoverView!
    var transparentView = ImageCropTransparentView()
    
    func setFrame(_ frame: CGRect) {
        self.frame = frame
        setSubView()
    }
    
    private func setSubView() {
        setPins()
        setCoverView()
        setTransparentView()
        setTransparenViewWith(size: self.frame.size)
    }
    
    private func setPins() {
        let width = self.frame.size.width / 2
//        let frame = self.superview!.frame
        pin1.frame = CGRect(x: self.frame.midX - width / 2, y: self.frame.size.height / 2 - width / 2, width: 20, height: 20)
        pin2.frame = CGRect(x: self.frame.midX + width / 2, y: self.frame.size.height / 2 - width / 2, width: 20, height: 20)
        pin3.frame = CGRect(x: self.frame.midX + width / 2, y: self.frame.size.height / 2 + width / 2, width: 20, height: 20)
        pin4.frame = CGRect(x: self.frame.midX - width / 2, y: self.frame.size.height / 2 + width / 2, width: 20, height: 20)
        pin1.isUserInteractionEnabled = true
        pin2.isUserInteractionEnabled = true
        pin3.isUserInteractionEnabled = true
        pin4.isUserInteractionEnabled = true
        self.superview!.addSubview(pin1)
        self.superview!.addSubview(pin2)
        self.superview!.addSubview(pin3)
        self.superview!.addSubview(pin4)
        
        self.addGestureOn(pin: pin1)
        self.addGestureOn(pin: pin2)
        self.addGestureOn(pin: pin3)
        self.addGestureOn(pin: pin4)
    }
    
    private func setCoverView() {
        coverView = CoverView(frame: bounds)
        self.addSubview(coverView)
    }
    
    //MARK:- Helper Methods
    
    private func resetPinPosition() {
        pin1.center = CGPoint(x: transparentView.frame.origin.x + self.frame.origin.x, y: transparentView.frame.origin.y + self.frame.origin.y)
        pin2.center = CGPoint(x: transparentView.frame.maxX + self.frame.origin.x, y: transparentView.frame.minY + self.frame.origin.y)
        pin3.center = CGPoint(x: transparentView.frame.maxX + self.frame.origin.x, y: transparentView.frame.maxY + self.frame.origin.y)
        pin4.center = CGPoint(x: transparentView.frame.minX + self.frame.origin.x, y: transparentView.frame.maxY + self.frame.origin.y)
        setCoverViewTransparentRect()
    }
    
    private func isPinPositionCorrect(center1: CGPoint, center2: CGPoint, center3: CGPoint, center4: CGPoint) -> Bool {
        if center2.x - center1.x < 40 {
            return false
        } else if center4.y - center1.y < 40 {
            return false
        }
        return isPointInside(point: center1) && isPointInside(point: center2) && isPointInside(point: center3) && isPointInside(point: center4)
    }
    
    private func isPointInside(point: CGPoint) -> Bool {
        if point.x < 0 || point.x > self.frame.size.width || point.y < 0 || point.y > self.frame.size.height {
            return false
        }
        return true
    }
    
    private func addGestureOn(pin: UIView) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(gesture:)))
        pin.addGestureRecognizer(panGesture)
    }
    
    private func setCoverViewTransparentRect() {
        let rect = CGRect(x: pin1.center.x - self.frame.origin.x, y: pin1.center.y - self.frame.origin.y, width: pin2.center.x - pin1.center.x, height: pin3.center.y - pin1.center.y)
        if coverView == nil {
            return
        }
        coverView.setTransparent(rect: rect)
    }
    
    private func setTransparentView() {
        let width = self.frame.size.width / 2
        let heigth = self.frame.size.height / 2
        let rect = CGRect(x: width / 2, y: heigth / 2, width: width, height: heigth)
        transparentView.frame = rect
        transparentView.setSubViews()
        transparentView.delegate = self
//        self.insertSubview(transparentView, belowSubview: pin1)
        self.addSubview(transparentView)
        resetPinPosition()
    }
    
    private func resetTransparentView() {
        let rect = CGRect(x: pin1.center.x - self.frame.origin.x, y: pin1.center.y - self.frame.origin.y, width: pin2.center.x - pin1.center.x, height: pin3.center.y - pin1.center.y)
        transparentView.frame = rect
        transparentView.setSubViews()
    }
    
    //MARK:- Gesture Recognizer Methods
    
    @objc private func panGestureAction(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            print("")
        case .changed:
            var point = gesture.location(in: self.superview)
            let origin = self.frame.origin
            if point.x - origin.x < 0 {
                point.x = origin.x
            }
            if point.x - origin.x > self.frame.size.width {
                point.x = self.frame.size.width + origin.x
            }
            if point.y - origin.y > self.frame.size.height {
                point.y = self.frame.size.height + origin.y
            }
            if point.y - origin.y < 0 {
                point.y = origin.y
            }
            let view = gesture.view
            if view == pin1 {
                var point2 = pin2.center
                var point4 = pin4.center
                point2.y = point.y
                point4.x = point.x
                if point2.x - point.x < 40 {
                    point.x = point2.x - 40
                }
                if point4.y - point.y < 40 {
                    point.y = point4.y - 40
                }
                pin1.center = point
                pin2.center.y = pin1.center.y
                pin4.center.x = pin1.center.x
            } else if view == pin2 {
                var point1 = pin1.center
                var point3 = pin3.center
                point1.y = point.y
                point3.x = point.x
                if point.x - point1.x < 40 {
                    point.x = point1.x + 40
                }
                if point3.y - point.y < 40 {
                    point.y = point3.y - 40
                }
                pin2.center = point
                pin1.center.y = pin2.center.y
                pin3.center.x = pin2.center.x
            } else if view == pin3 {
                var point4 = pin4.center
                var point2 = pin2.center
                point4.y = point.y
                point2.x = point.x
                if point.x - point4.x < 40 {
                    point.x = point4.x + 40
                }
                if point.y - point2.y < 40 {
                    point.y = point2.y + 40
                }
                pin3.center = point
                pin4.center.y = pin3.center.y
                pin2.center.x = pin3.center.x
            } else if view == pin4 {
                var point3 = pin3.center
                var point1 = pin1.center
                point3.y = point.y
                point1.x = point.x
                if point3.x - point.x < 40 {
                    point.x = point3.x - 40
                }
                if point.y - point1.y < 40 {
                    point.y = point1.y + 40
                }
                pin4.center = point
                pin3.center.y = pin4.center.y
                pin1.center.x = pin4.center.x
            }
            setCoverViewTransparentRect()
            resetTransparentView()
        case .ended:
            print("")
        default:
            print("")
        }
    }
    
    private func setTransparenViewWith(size: CGSize) {
        var width: CGFloat
        var height: CGFloat
        if size.width > size.height {
            width = self.frame.size.width
            height = width * size.height / size.width
        } else {
            height = self.frame.size.height
            width = height * size.width / size .height
        }
        if height > self.frame.size.height {
            let newHeight = self.frame.size.height
            width = width / height * newHeight
            height = newHeight
        }
        if width > self.frame.size.width {
            let newWidth = self.frame.size.width
            height = height / width * newWidth
            width = newWidth
        }
        let rect = CGRect(x: self.frame.size.width / 2 - width / 2, y: self.frame.size.height / 2 - height / 2, width: width, height: height)
        transparentView.frame = rect
        transparentView.setSubViews()
        resetPinPosition()
    }
    
    //MARK:- Button Actions
    
    func getCropedFrame() -> CGRect {
        let rect = CGRect(x: pin1.center.x - self.frame.origin.x, y: pin1.center.y - self.frame.origin.y, width: pin2.center.x - pin1.center.x, height: pin3.center.y - pin1.center.y)
        return rect
    }
}

extension VideoCropView: ImageTransparentViewDelegate {
    func imageTransparentViewDidMoved(_ view: ImageCropTransparentView) {
        resetPinPosition()
    }
}

