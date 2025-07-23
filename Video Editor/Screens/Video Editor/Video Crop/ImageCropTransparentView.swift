//
//  ImageCropTransparentView.swift
//  Video Editor
//
//  Created by Sufian  on 16/07/2025.
//

import UIKit

class ImageCropTransparentView: UIView {
    
    let line1 = UIView()
    let line2 = UIView()
    let line3 = UIView()
    let line4 = UIView()
    
    let line5 = UIView()
    let line6 = UIView()
    let line7 = UIView()
    let line8 = UIView()
    
    var touchStartPoint: CGPoint!
    var delegate: ImageTransparentViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setSubViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setSubViews() {
        setupVerticalLines()
        setupHorizontalLines()
    }
    
    func setupVerticalLines() {
        let verticalLines = [line1, line2, line5, line6]
        
        for (index, line) in verticalLines.enumerated() {
            line.backgroundColor = UIColor.white
            var x: CGFloat = 0
            switch index {
            case 0: x = self.frame.size.width / 3 - 1
            case 1: x = self.frame.size.width * 2 / 3 - 1
            case 2: x = 0
            case 3: x = self.frame.size.width
            default: break
            }
            setLine(line, frame: CGRect(x: x, y: 0, width: 1, height: self.frame.size.height))
        }
    }
    
    func setupHorizontalLines() {
        let horizontalLines = [line3, line4, line7, line8]
        
        for (index, line) in horizontalLines.enumerated() {
            var y: CGFloat = 0
            switch index {
            case 0: y = self.frame.size.height / 3 - 1
            case 1: y = self.frame.size.height * 2 / 3 - 1
            case 2: y = 0
            case 3: y = self.frame.size.height
            default: break
            }
            setLine(line, frame: CGRect(x: 0, y: y, width: self.frame.size.width, height: 1))
        }
    }
    
    private func setLine(_ line: UIView, frame: CGRect) {
        addSubview(line)
        line.frame = frame
        line.backgroundColor = UIColor.white
    }
    
    //MARK:- Touch Event Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchStartPoint = touches.first!.location(in: self.superview)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touchLocation = touches.first!.location(in: self.superview)
        moveCenterOfObjectToNew(point: touchLocation)
        touchStartPoint = touchLocation
    }
    
    
    func moveCenterOfObjectToNew(point: CGPoint) {
        if touchStartPoint == nil {
            return
        }
        var newCenter = CGPoint(x: self.center.x + point.x - touchStartPoint.x, y: self.center.y +
            point.y - touchStartPoint.y)
        let midX = self.bounds.midX
        if newCenter.x > self.superview!.bounds.size.width - midX {
            newCenter.x = (self.superview?.bounds.size.width)! - midX
        }
        if newCenter.x < midX {
            newCenter.x = midX
        }
        let midY = self.bounds.midY
        if newCenter.y > self.superview!.bounds.size.height - midY {
            newCenter.y = self.superview!.bounds.size.height - midY
        }
        if newCenter.y < midY {
            newCenter.y = midY
        }
        self.center = newCenter
        if let delegate = self.delegate {
            delegate.imageTransparentViewDidMoved(self)
        }
    }
}

protocol ImageTransparentViewDelegate {
     func imageTransparentViewDidMoved(_ view: ImageCropTransparentView)
    
}
