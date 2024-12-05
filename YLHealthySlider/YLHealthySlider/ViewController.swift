//
//  ViewController.swift
//  YLHealthySlider
//
//  Created by 彭祖鑫 on 2024/11/26.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        let healthySlider = YLHealthySlider(frame: CGRect(x: 10, y: 100, width: 360, height: 50))
        healthySlider.value = 21.4
        view.addSubview(healthySlider)

//        healthySlider.value = 25.0

    }


}

