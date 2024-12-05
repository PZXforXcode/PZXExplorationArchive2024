//
//  ViewController.swift
//  用贝塞尔画折线图
//
//  Created by 彭祖鑫 on 2024/11/29.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        self.view.backgroundColor = .cyan
        
        // 创建 PZXChartLineView 并添加到视图中
        let chartLineView = PZXChartLineView(frame: CGRect(x: 0, y: 100, width: self.view.bounds.width  , height: 500))
        self.view.addSubview(chartLineView)
    }


}

