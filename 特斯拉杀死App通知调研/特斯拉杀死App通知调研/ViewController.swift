//
//  ViewController.swift
//  特斯拉杀死App通知调研
//
//  Created by 彭祖鑫 on 2024/12/17.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.view.backgroundColor = .cyan
        //调用这个方法给通知授权
        requestNotificationPermission()

    }


    
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("通知权限已授权")
            } else {
                print("通知权限未授权")
            }
        }
    }
}

