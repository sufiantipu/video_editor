//
//  StickerView.swift
//  Video Editor
//
//  Created by Sufian  on 15/07/2025.
//

import UIKit

let IAStickerViewControlSize = 25.0
let ASPUserResizableViewGlobalInset = 5.0
let ASPUserResizableViewDefaultMinWidth = 48.0
let ASPUserResizableViewDefaultMinHeight = 48.0
let ASPUserResizableViewInteractiveBorderSize = 10.0

class StickerBorder: UIView {
    
    let borderColor = "29abe2"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    override func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()
        context!.saveGState()
        context!.setLineWidth(1.0)
        context!.setStrokeColor(UIColor(hexString: borderColor).cgColor)
        context!.addRect(self.bounds.insetBy(dx: CGFloat(ASPUserResizableViewInteractiveBorderSize / 2), dy: CGFloat(ASPUserResizableViewInteractiveBorderSize / 2)))
        context!.strokePath()
        context!.restoreGState()
    }
}

class Sticker: UIView {
    
    var scale = CGFloat(1)
    var initialSize: CGSize!
    var sizeIncrease: CGFloat!
    var borderView: StickerBorder!
    
    var preventsPositionOutsideSuperview: Bool = true
    var preventsResizing = false
    var preventsDeleting = false
    var translucencySticker = true
    var isSelected = false
    var deltaAngle: CGFloat!
    var touchStartPoint: CGPoint!
    
    let rotateButton = UIImageView()
    let deleteButton = UIImageView()
    var image: UIImage! {
        didSet {
            imageView.image = image
        }
    }
    
    var imageView = UIImageView()
    var backgroundView = UIView()
    let prevent: CGFloat = 40
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.frame = frame
        initialSize = frame.size
        self.setProperties()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("This class does not support NSCoding")
    }
    
    private func setProperties() {
        //setBackgroundView()
        setImageView()
        setPinchGesture()
        setBorderView()
        setRotateButton()
        setDeleteButton()
        
        deltaAngle = atan2(self.frame.origin.y + self.frame.size.height - self.center.y, self.frame.origin.x + self.frame.size.width - self.center.x)
    }
    
    func setBorderView() {
        borderView = StickerBorder(frame: self.bounds.insetBy(dx: CGFloat(ASPUserResizableViewGlobalInset), dy: CGFloat(ASPUserResizableViewGlobalInset)))
        borderView.isHidden = true
        
        self.addSubview(borderView)
    }
    
    func setBorderViewFrame() {
        borderView.frame = self.bounds.insetBy(dx: CGFloat(ASPUserResizableViewGlobalInset), dy: CGFloat(ASPUserResizableViewGlobalInset))
        borderView.setNeedsDisplay()
    }
    
    func setRotateButton() {
        setRotateButtonFrame()
        rotateButton.image = UIImage(systemName: "arrow.counterclockwise.circle.fill")
        rotateButton.tintColor = .white
        rotateButton.isUserInteractionEnabled = true
        let pangesture = UIPanGestureRecognizer(target: self, action: #selector(rotatePanGestureAction(gesture:)))
        rotateButton.addGestureRecognizer(pangesture)
        self.addSubview(rotateButton)
    }
    
    func setRotateButtonFrame() {
        rotateButton.frame = CGRect(x: self.bounds.size.width - CGFloat(IAStickerViewControlSize), y: self.bounds.size.height - CGFloat(IAStickerViewControlSize), width: CGFloat(IAStickerViewControlSize), height: CGFloat(IAStickerViewControlSize))
    }
    
    func setDeleteButton() {
        setDeleteButtonFrame()
        deleteButton.image = UIImage(systemName: "xmark.circle.fill")
        deleteButton.tintColor = .white
        deleteButton.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(deleteTapGestureAction(gesture:)))
        deleteButton.addGestureRecognizer(tapGesture)
        self.addSubview(deleteButton)
    }
    
    func setDeleteButtonFrame() {
        deleteButton.frame = CGRect(x: 0, y: 0, width: IAStickerViewControlSize, height: IAStickerViewControlSize)
    }
    
    func setPinchGesture() {
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGestureAction(gesture:)))
        self.addGestureRecognizer(pinchGesture)
    }
    
    //MARK:- Gesture Recognizer Action Methods
    
    @objc func pinchGestureAction(gesture: UIPinchGestureRecognizer) {
        if !isSelected {
            return
        }
        resetSizeIncrease()
        scale *= gesture.scale
        gesture.scale = 1.0
        applyNew(size: CGSize(width: initialSize.width * scale, height: initialSize.height * scale))
    }
    
    @objc func rotatePanGestureAction(gesture: UIPanGestureRecognizer) {
        let state = gesture.state
        switch state {
        case .began:
            //        reduseOpacity(ok: true)
            break
        case .changed:
            let angle = atan2(gesture.location(in: self.superview).y - self.center.y, gesture.location(in: self.superview).x - self.center.x)
            let angleDiffrence = deltaAngle - angle
            if !preventsResizing {
                if !shouldPauseRotation(-angleDiffrence) {
                    self.transform = CGAffineTransform(rotationAngle: -angleDiffrence)
                }
            }
            setBorderViewFrame()
        case .ended:
            reduseOpacity(ok: false)
        default:
            print("Error")
        }
    }
    
    @objc func deleteTapGestureAction(gesture: UITapGestureRecognizer) {
        self.removeFromSuperview()
    }
    
    //MARK:- Helper Methods
    
    func resetSizeIncrease() {
        scale = self.bounds.size.height / self.initialSize.height
        sizeIncrease = 0
    }
    
    
    func preventUp() {
        let maxY = self.frame.maxY
        if maxY < prevent {
            let add = prevent - maxY
            var center = self.center
            center.y += add
            self.center = center
        }
    }
    
    func preventDown() {
        let superViewHeigth = self.superview!.bounds.size.height
        if self.frame.origin.y + prevent > superViewHeigth {
            let minus = self.frame.origin.y + prevent - superViewHeigth
            var center = self.center
            center.y -= minus
            self.center = center
        }
    }
    
    func preventLeft() {
        let maxX = self.frame.maxX
        if maxX < prevent {
            let add = prevent - maxX
            var center = self.center
            center.x += add
            self.center = center
        }
    }
    
    func preventRight() {
        let superViewWidth = self.superview!.bounds.size.width
        if self.frame.origin.x + prevent > superViewWidth {
            let minus = self.frame.origin.x + prevent - superViewWidth
            var center = self.center
            center.x -= minus
            self.center = center
        }
    }
    
    func setSubViewFrames() {
        setBorderViewFrame()
        setDeleteButtonFrame()
        setRotateButtonFrame()
        borderView.setNeedsDisplay()
        setNeedsDisplay()
    }
    
    func setBackgroundView() {
        backgroundView.frame = self.bounds.insetBy(dx: CGFloat(ASPUserResizableViewGlobalInset), dy: CGFloat(ASPUserResizableViewGlobalInset))
        backgroundView.alpha = 0.3
        backgroundView.backgroundColor = .black
        addSubview(backgroundView)
    }
    
    func setImageView() {
        imageView.frame = self.bounds.insetBy(dx: CGFloat(ASPUserResizableViewGlobalInset), dy: CGFloat(ASPUserResizableViewGlobalInset))
        imageView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
    }
    
    func applyNew(size: CGSize) {
        self.bounds = CGRect(x: self.bounds.origin.x, y: self.bounds.origin.y, width: size.width, height: size.height)
        setSubViewFrames()
    }
    
    func reduseOpacity(ok: Bool) {
        guard ok || !translucencySticker else {
            self.alpha = 1.0
            return
        }
        self.alpha = 0.65
    }
    
    func makeSelected(_ ok: Bool) {
        isSelected = ok
        borderView.isHidden = !ok
        rotateButton.isHidden = !ok
        deleteButton.isHidden = !ok
    }
    
    func moveCenterOfObjectToNew(point: CGPoint) {
        if touchStartPoint == nil {
            return
        }
        var newCenter = CGPoint(x: self.center.x + point.x - touchStartPoint.x, y: self.center.y + point.y - touchStartPoint.y)
        if preventsPositionOutsideSuperview {
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
        }
        self.center = newCenter
        preventUp()
        preventDown()
        preventLeft()
        preventRight()
    }
    
    //MARK:- Touch Event Methods
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSelected {
            makeSelected(true)
            return
        }
        reduseOpacity(ok: true)
        touchStartPoint = touches.first!.location(in: self.superview)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        reduseOpacity(ok: false)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        reduseOpacity(ok: false)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if !isSelected {
            return
        }
        reduseOpacity(ok: true)
        let touchLocation = touches.first!.location(in: self.superview)
        moveCenterOfObjectToNew(point: touchLocation)
        touchStartPoint = touchLocation
    }
    
    // Helper function to determine if rotation should pause near snap points
    private func shouldPauseRotation(_ angle: CGFloat) -> Bool {
        let degrees = Int(angle * 180 / .pi) % 360
        let snapPoints = [0, 90, 180, 270, 360]
        return snapPoints.contains { abs($0 - degrees) <= 2 || abs($0 - degrees + 360) <= 2 }
    }
    
}
