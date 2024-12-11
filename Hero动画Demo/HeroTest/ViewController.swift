//
//  ViewController.swift
//  HeroTest
//
//  Created by 彭祖鑫 on 2023/7/19.
//

import UIKit
import Hero


class ViewController: UIViewController {

    @IBOutlet weak var blackView: UIView!
    @IBOutlet weak var redView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        isHeroEnabled = true
        redView.hero.id = "ironMan"
        blackView.hero.id = "batMan"
    }


    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let nextVC : ViewController2 = UIStoryboard.init(name: "ViewController2", bundle: nil).instantiateViewController(withIdentifier: "ViewController2") as! ViewController2
        
        // 使用Hero的方式进行转场
        nextVC.hero.isEnabled = true
        navigationController?.hero.isEnabled = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
}

