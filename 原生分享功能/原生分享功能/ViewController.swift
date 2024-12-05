//
//  ViewController.swift
//  原生分享功能
//
//  Created by 彭祖鑫 on 2024/11/21.
//

import UIKit

class ViewController: UIViewController {

    @IBAction func buttonPressed(_ sender: UIButton) {
        
        let url = URL(string: "https://www.baidu.com")!
        let image = UIImage(named: "invoice-success")!
        let description = "描述文字哈哈哈哈"
        shareContent(url: url, image: image, description: description, viewController: self)
        

    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .cyan
    }
    
    

    func shareContent(url: URL, image: UIImage, description: String, viewController: UIViewController) {
        // 设置分享内容
        let activityItems: [Any] = [description, image, url]
        
        // 初始化分享控制器
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        
        // 在 iPad 上设置弹出位置
        if let popover = activityVC.popoverPresentationController {
            popover.sourceView = viewController.view
            popover.sourceRect = CGRect(x: viewController.view.bounds.midX, y: viewController.view.bounds.midY, width: 0, height: 0)
            popover.permittedArrowDirections = []
        }
        
        // 显示分享界面
        viewController.present(activityVC, animated: true, completion: nil)
    }



}

