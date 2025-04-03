//
//  ViewController.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let vc  = MainViewController(rootView: MainView())
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

