//
//  ViewController.swift
//  YLFireViewDemo
//
//  Created by 彭祖鑫 on 2024/11/27.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        // Do any additional setup after loading the view.
                let fireAnimationView = YLFireAnimationView(frame: CGRect(x: 50, y: 100, width: 50, height: 50))
                view.addSubview(fireAnimationView)
        

    }


}

