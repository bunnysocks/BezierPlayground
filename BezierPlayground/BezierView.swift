//
//  BezierView.swift
//  BezierPlayground
//
//  Created by heman on 06/11/25.
//

import Foundation
import UIKit
import CoreMotion

class BezierView: UIView {
    private var displayLink: CADisplayLink?
    private let motionManager = CMMotionManager()
    var useFakeMotion = false  // Changed to false by default
    
    // Control Points
    var P0 = CGPoint(x: 100, y: 400)
    var P1 = CGPoint(x: 180, y: 120)
    var P2 = CGPoint(x: 220, y: 680)
    var P3 = CGPoint(x: 320, y: 400)

    // Motion properties
    var velocity1 = CGPoint.zero
    var velocity2 = CGPoint.zero
    var targetP1 = CGPoint(x: 180, y: 120)
    var targetP2 = CGPoint(x: 220, y: 680)
    
    // Gyroscope integration
    var gyroOffsetX: CGFloat = 0
    var gyroOffsetY: CGFloat = 0
    
    // FPS tracking
    private var lastFrameTime: CFTimeInterval = 0
    private var fps: Int = 0
    private var frameCount: Int = 0
    private var fpsUpdateTime: CFTimeInterval = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        
        setupGyroscope()
        
        displayLink = CADisplayLink(target: self, selector: #selector(update))
        displayLink?.add(to: .main, forMode: .default)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupGyroscope() {
        guard motionManager.isGyroAvailable else {
            print("Gyroscope not available")
            useFakeMotion = true
            return
        }
        
        motionManager.gyroUpdateInterval = 1.0 / 60.0  // 60 Hz
        motionManager.startGyroUpdates(to: .main) { [weak self] (data, error) in
            guard let self = self, let gyroData = data else { return }
            
            // Integrate rotation rates to get position offsets
            // Multiply by a factor to control sensitivity
            let sensitivity: CGFloat = 50.0
            
            // gyroData.rotationRate.y affects horizontal movement (pitch)
            // gyroData.rotationRate.x affects vertical movement (roll)
            self.gyroOffsetX += CGFloat(gyroData.rotationRate.y) * sensitivity
            self.gyroOffsetY += CGFloat(gyroData.rotationRate.x) * sensitivity
            
            // Clamp the offsets to reasonable bounds
            let maxOffset: CGFloat = 150
            self.gyroOffsetX = max(-maxOffset, min(maxOffset, self.gyroOffsetX))
            self.gyroOffsetY = max(-maxOffset, min(maxOffset, self.gyroOffsetY))
        }
    }

    @objc func update() {
        // Update FPS
        let currentTime = CACurrentMediaTime()
        frameCount += 1
        
        if currentTime - fpsUpdateTime >= 1.0 {
            fps = frameCount
            frameCount = 0
            fpsUpdateTime = currentTime
        }
        
        if useFakeMotion {
            let time = CACurrentMediaTime()
            let x = sin(time) * 100 + 200
            let y = cos(time * 0.7) * 100 + 400
            targetP1 = CGPoint(x: x, y: y)
            
            let x2 = sin(time * 1.3) * 120 + 200
            let y2 = cos(time * 0.9) * 80 + 400
            targetP2 = CGPoint(x: x2, y: y2)
        } else {
            // Use gyroscope data to set target positions
            // Base positions
            let baseP1 = CGPoint(x: 180, y: 120)
            let baseP2 = CGPoint(x: 220, y: 680)
            
            // Apply gyroscope offsets
            targetP1 = CGPoint(x: baseP1.x + gyroOffsetX,
                              y: baseP1.y + gyroOffsetY)
            targetP2 = CGPoint(x: baseP2.x - gyroOffsetX * 0.8,
                              y: baseP2.y - gyroOffsetY * 0.8)
        }

        let k: CGFloat = 0.1      // spring stiffness
        let damping: CGFloat = 0.8 // resistance

        // --- P1 ---
        let acceleration1 = k * (targetP1 - P1) - damping * velocity1
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
    
    func computeTangent(at t: CGFloat) -> CGPoint {
        let oneMinusT = 1 - t
        let term1 = (3 * oneMinusT * oneMinusT) * (P1 - P0)
        let term2 = (6 * oneMinusT * t) * (P2 - P1)
        let term3 = (3 * t * t) * (P3 - P2)
        return term1 + term2 + term3
    }
    
    func cubicBezierPoint(t: CGFloat) -> CGPoint {
        let oneMinusT = 1 - t
        let term1 = (oneMinusT * oneMinusT * oneMinusT) * P0
        let term2 = (3 * oneMinusT * oneMinusT * t) * P1
        let term3 = (3 * oneMinusT * t * t) * P2
        let term4 = (t * t * t) * P3
        return term1 + term2 + term3 + term4
    }

    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        let bezierPoints = computeBezierPoints(tStep: 0.02)
        
        
        if let first = bezierPoints.first {
            context.move(to: first)
            for point in bezierPoints.dropFirst() {
                context.addLine(to: point)
            }
            context.strokePath()
        }
        
        // Draw control points
        UIColor.systemGray2.setFill()
        let controlPoints = [P0, P1, P2, P3]
        for p in controlPoints {
            let r = CGRect(x: p.x - 5, y: p.y - 5, width: 10, height: 10)
            context.fillEllipse(in: r)
        }
        
        // Connect control points with gray lines
        UIColor.systemGray.setStroke()
        context.setLineWidth(1.5)
        // make line dotted
        let dashPatternForLine: [CGFloat] = [4, 2] // 4 points drawn, 2 points space
        context.setLineDash(phase: 0, lengths: dashPatternForLine)
        context.move(to: P0)
        context.addLine(to: P1)
        context.addLine(to: P2)
        context.addLine(to: P3)
        context.strokePath()
        
        
        // draw curve
        let silver = UIColor(white: 0.85, alpha: 0.5) // light gray with 50% opacity
        silver.setStroke()
        context.setLineWidth(16) // thicker line
        context.setLineCap(.round) // makes ends smooth and nicer
        context.addLines(between: bezierPoints)
        context.strokePath()


        // draw tangents
        UIColor.systemGray2.setStroke()
        context.setLineWidth(1.5)


        let tValues = stride(from: 0.0, through: 1.0, by: 0.5)
        for t in tValues {
            let tValue = CGFloat(t)
            let curvePoint = cubicBezierPoint(t: tValue)   // position on curve
            let tangent = computeTangent(at: tValue)       // derivative
            let norm = sqrt(tangent.x * tangent.x + tangent.y * tangent.y)
            guard norm > 0 else { continue }
            let dir = CGPoint(x: tangent.x / norm, y: tangent.y / norm)
            let scale: CGFloat = 20                        // shorter line
            let end = CGPoint(x: curvePoint.x + dir.x * scale,
                              y: curvePoint.y + dir.y * scale)
            
            // draw line
            context.move(to: curvePoint)
            context.addLine(to: end)
            context.strokePath()
            
            // draw arrowhead
            let arrowSize: CGFloat = 8
            let perp = CGPoint(x: -dir.y * arrowSize, y: dir.x * arrowSize)
            context.move(to: end)
            context.addLine(to: CGPoint(x: end.x - dir.x * arrowSize + perp.x,
                                        y: end.y - dir.y * arrowSize + perp.y))
            context.move(to: end)
            context.addLine(to: CGPoint(x: end.x - dir.x * arrowSize - perp.x,
                                        y: end.y - dir.y * arrowSize - perp.y))
            context.strokePath()
        }

        // reset dash
        context.setLineDash(phase: 0, lengths: [])
        
        // Draw FPS and coordinates
        drawDebugInfo(context: context)
    }
    
    func drawDebugInfo(context: CGContext) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.monospacedSystemFont(ofSize: 12, weight: .regular),
            .foregroundColor: UIColor.darkGray,
            .paragraphStyle: paragraphStyle
        ]
        
        let debugText = """
        FPS: \(fps)
        
        P0: (\(Int(P0.x)), \(Int(P0.y)))
        P1: (\(Int(P1.x)), \(Int(P1.y)))
        P2: (\(Int(P2.x)), \(Int(P2.y)))
        P3: (\(Int(P3.x)), \(Int(P3.y)))
        
        Gyro: (\(String(format: "%.1f", gyroOffsetX)), \(String(format: "%.1f", gyroOffsetY)))
        """
        
        let textRect = CGRect(x: 10, y: 40, width: 200, height: 150)
        debugText.draw(in: textRect, withAttributes: attrs)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)

        // Choose which control point to move (whichever is closer)
        let d1 = hypot(location.x - P1.x, location.y - P1.y)
        let d2 = hypot(location.x - P2.x, location.y - P2.y)

        if d1 < d2 {
            targetP1 = location
        } else {
            targetP2 = location
        }
    }
    
    deinit {
        displayLink?.invalidate()
        motionManager.stopGyroUpdates()
    }
}
