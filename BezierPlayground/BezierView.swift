//
//  BezierView.swift
//  BezierPlayground
//
//  Created by heman on 06/11/25.
//

import Foundation
import UIKit

class BezierView: UIView {
    private var displayLink: CADisplayLink?
    
    // Control Points
    var P0 = CGPoint(x: 100, y: 400)
    var P1 = CGPoint(x: 150, y: 100)
    var P2 = CGPoint(x: 250, y: 700)
    var P3 = CGPoint(x: 300, y: 400)
    
    // Motion properties
    var velocity1 = CGPoint.zero
    var velocity2 = CGPoint.zero
    var targetP1 = CGPoint(x: 150, y: 100)
    var targetP2 = CGPoint(x: 250, y: 700)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .default)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc func update() {
        let k: CGFloat = 0.1      // spring stiffness
        let damping: CGFloat = 0.8 // resistance

        // --- P1 ---
        let acceleration1 = k * (targetP1 - P1)  - damping * velocity1
        velocity1 = velocity1 + acceleration1
        P1 = P1 + velocity1

        // --- P2 ---
        let acceleration2 = k * (targetP2 - P2) - damping * velocity2
        velocity2 = velocity2 + acceleration2
        P2 = P2 + velocity2
        
        setNeedsDisplay()
    }

    
    func computeBezierPoints(tStep: CGFloat) -> [CGPoint] {
        var points: [CGPoint] = []
        
        var t: CGFloat = 0
        while t <= 1 {
            let oneMinusT = 1 - t
            
            let term1 = (oneMinusT * oneMinusT * oneMinusT) * P0
            let term2 = (3 * oneMinusT * oneMinusT * t) * P1
            let term3 = (3 * oneMinusT * t * t) * P2
            let term4 = (t * t * t) * P3
            
            let point = term1 + term2 + term3 + term4
            points.append(point)
            
            t += tStep
        }
        return points
    }
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let bezierPoints = computeBezierPoints(tStep: 0.02)
        
        // Draw curve
        UIColor.systemBlue.setStroke()
        context.setLineWidth(3.0)
        
        if let first = bezierPoints.first {
            context.move(to: first)
            for point in bezierPoints.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
        
        // Draw control points
        UIColor.systemRed.setFill()
        let controlPoints = [P0, P1, P2, P3]
        for p in controlPoints {
            let r = CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)
            context.fillEllipse(in: r)
        }
        
        // Connect control points with gray lines
        UIColor.systemGray.setStroke()
        context.setLineWidth(1.0)
        context.move(to: P0)
        context.addLine(to: P1)
        context.addLine(to: P2)
        context.addLine(to: P3)
        context.strokePath()
    }

}


