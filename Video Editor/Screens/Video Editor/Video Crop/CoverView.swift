//
//  CoverView.swift
//  Video Editor
//
//  Created by Sufian  on 16/07/2025.
//

import UIKit

class CoverView: UIView {
    
    var transparentRect: CGRect!
    

    override func draw(_ rect: CGRect) {
        guard let transparentRect = self.transparentRect else {
            return
        }
        let path =  UIBezierPath(rect: self.bounds)
        path.append(UIBezierPath(rect: transparentRect))
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.fillRule = CAShapeLayerFillRule.evenOdd
        fillLayer.frame = self.bounds
        fillLayer.path = path.cgPath
        fillLayer.fillColor = UIColor.black.withAlphaComponent(0.9).cgColor //UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.7).cgColor
        
        self.layer.mask = fillLayer
    }
    
    func setTransparent(rect: CGRect) {
        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        transparentRect = rect
        draw(self.frame)
    }
    
    func createPathWith(points: [CGPoint]) -> UIBezierPath {
        let path = UIBezierPath()
        for (i, point) in points.enumerated() {
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        path.close()
        path.addClip()
        return path
    }
    
    func getPointsFrom(rect: CGRect) -> [CGPoint]{
        
        let point1 = CGPoint(x: rect.minX, y: rect.minY)
        let point2 = CGPoint(x: rect.maxX, y: rect.minY)
        let point3 = CGPoint(x: rect.maxX, y: rect.maxY)
        let point4 = CGPoint(x: rect.minX, y: rect.maxY)
        
        return [point1, point2, point3, point4]
    }
}
