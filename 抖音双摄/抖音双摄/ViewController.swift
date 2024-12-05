//
//  ViewController.swift
//  抖音双摄
//
//  Created by 彭祖鑫 on 2024/11/14.
//

import UIKit

class ViewController: UIViewController {


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let vc = DualCameraPreviewViewController()
        self.navigationController?.pushViewController(vc, animated: true)
    }

}

