//
//  ViewController2.swift
//  HeroTest
//
//  Created by 彭祖鑫 on 2024/12/11.
//

import UIKit
import Hero

class ViewController2: UIViewController {

    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var redView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.hero.isEnabled = true
        redView.hero.id = "ironMan"
        blackView.hero.id = "batMan"
        self.view.hero.modifiers = [.translate(y:100)]
        
        // 添加侧滑返回手势支持
//           navigationController?.interactivePopGestureRecognizer?.delegate = nil
//           
//           // 启用 Hero 的交互式动画
//           let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan
//           (_:)))
//           view.addGestureRecognizer(pan)
        
        // 添加边缘滑动手势
        let edgePan = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        edgePan.edges = .left  // 设置从左边缘触发
        view.addGestureRecognizer(edgePan)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.x / view.bounds.width
        
        switch gesture.state {
        case .began:
            // 开始交互式转场
            navigationController?.popViewController(animated: true)
        case .changed:
            // 更新转场进度
            Hero.shared.update(progress)
        case .ended, .cancelled:
            // 根据进度和速度决定是完成还是取消转场
            let velocity = gesture.velocity(in: nil)
            if (progress + velocity.x / view.bounds.width) > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        default:
            break
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
