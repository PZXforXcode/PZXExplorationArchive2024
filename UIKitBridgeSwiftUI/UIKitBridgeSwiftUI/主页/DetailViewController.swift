//
//  DetailViewController.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import UIKit

class DetailViewController: UIViewController {
    
    // 如果需要，可以接收从MainView传递的用户数据
    var userInfo: UserModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        // 设置导航标题
        title = "详情页面"
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 创建一个标签显示详情信息
        let infoLabel = UILabel()
        infoLabel.translatesAutoresizingMaskIntoConstraints = false
        infoLabel.numberOfLines = 0
        infoLabel.textAlignment = .center
        infoLabel.font = UIFont.systemFont(ofSize: 20)
        
        if let user = userInfo {
            infoLabel.text = "用户详情信息\n\n姓名: \(user.name)\n年龄: \(user.age)\nID: \(user.id)"
        } else {
            infoLabel.text = "这是详情页面\n没有接收到用户数据"
        }
        
        view.addSubview(infoLabel)
        
        // 使用自动布局约束
        NSLayoutConstraint.activate([
            infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            infoLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            infoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
} 