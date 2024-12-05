//
//  ViewController.swift
//  六芒星雷达图
//
//  Created by 彭祖鑫 on 2024/11/28.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
        // Do any additional setup after loading the view.
        let radarChart = RadarChartView(frame: CGRect(x: 50, y: 100, width: 300, height: 300))
         radarChart.backgroundColor = .white
         radarChart.values = [50, 70, 90, 60, 80, 65] // 自定义数据
         self.view.addSubview(radarChart)
    }


}

