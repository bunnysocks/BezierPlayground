//
//  ViewController.swift
//  BezierPlayground
//
//  Created by heman on 05/11/25.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    private var fpsLabel: UILabel!
    private var displayLink: CADisplayLink!
    private var lastTimestamp: CFTimeInterval = 0
    private var frameCount = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        let bezierView = BezierView(frame: view.bounds)
        bezierView.backgroundColor = .white
        view.addSubview(bezierView)

        // --- FPS label setup ---
        fpsLabel = UILabel(frame: CGRect(x: 20, y: view.bounds.height - 40, width: 80, height: 20))
        fpsLabel.textColor = .white
        fpsLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 14, weight: .medium)
        fpsLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        fpsLabel.layer.cornerRadius = 5
        fpsLabel.clipsToBounds = true
        fpsLabel.textAlignment = .center
        fpsLabel.text = "FPS: 0"
        view.addSubview(fpsLabel)

        // --- DisplayLink for FPS ---
        displayLink = CADisplayLink(target: self, selector: #selector(updateFPS))
        displayLink.add(to: .main, forMode: .common)
    }

    @objc private func updateFPS(link: CADisplayLink) {
        if lastTimestamp == 0 {
            lastTimestamp = link.timestamp
            return
        }

        frameCount += 1
        let delta = link.timestamp - lastTimestamp
        if delta >= 1.0 {
            let fps = Double(frameCount) / delta
            fpsLabel.text = String(format: "FPS: %.0f", fps)
            frameCount = 0
            lastTimestamp = link.timestamp
        }
    }
}
