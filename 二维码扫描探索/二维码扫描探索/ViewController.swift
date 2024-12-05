//
//  ViewController.swift
//  二维码扫描探索
//
//  Created by 彭祖鑫 on 2024/12/5.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .cyan
    }

    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let scannerVC = QRCodeScannerViewController()
//        let scannerVC = QRFrameCodeScannerViewController()

        self.navigationController?.pushViewController(scannerVC, animated: true)
//        present(scannerVC, animated: true)

    }
    
    

}

