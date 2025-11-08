//
//  ViewController.swift
//  BezierPlayground
//
//  Created by heman on 05/11/25.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let bezierView = BezierView(frame: view.bounds)
        bezierView.backgroundColor = .white
        view.addSubview(bezierView)
        
//        let pointA = CGPoint(x: 10, y: 20)
//        let pointB = CGPoint(x: 5, y: 15)
//                
//        let sum = pointA + pointB
//        print("Sum of points: \(sum)")
//        let diff = pointA - pointB
//        print("Sum of points: \(diff)")
//        let mul = pointA * pointB
//        print("Sum of points: \(mul)")
//        let div = pointA / pointB
//        print("Sum of points: \(div)")

    }


}
