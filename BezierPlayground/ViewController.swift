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

    }


}
