//
//  BezierView.swift
//  BezierPlayground
//
//  Created by heman on 06/11/25.
//

import Foundation
import UIKit

class BezierView: UIView {
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        context.setLineWidth(3.0)
        
        let centerPoint = CGPoint(x: bounds.width/2, y: bounds.height/2)
        context.move(to: centerPoint)
        
        let size : CGFloat = 100;
        let rectOrigin = CGPoint(x: centerPoint.x - size / 2, y: centerPoint.y - size / 2)
        let rectangle = CGRect(origin: rectOrigin, size: CGSize(width: size, height: size))
        
        UIColor.systemBlue.setStroke()  
        context.addRect(rectangle)
        context.strokePath()
        
        UIColor.systemGray.setStroke()
        context.addEllipse(in: rectangle)
        context.strokePath()
    }
}
