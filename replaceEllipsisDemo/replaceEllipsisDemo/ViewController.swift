//
//  ViewController.swift
//  replaceEllipsisDemo
//
//  Created by 彭祖鑫 on 2025/4/26.
//

import UIKit
// import CoreText // 不再需要CoreText

class ViewController: UIViewController {
    
    private var originalText: String?

    // 创建UILabel
    private lazy var label: UILabel = { // 使用 lazy var 允许在闭包中访问 self
        let label = UILabel()
        label.numberOfLines = 6
        // 将原始文本存储起来
        self.originalText = "RM 1234567890.1234567890.现在，你可以运行应用程序，并通过点击这两个按钮动态地增加或减少 UILabel 的行数。每次改变行数后，文本都会根据新的行数限制重新应用省略号处理。567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.1234567890.12345现在，你可以运行应用程序，并通过点击这两个按钮动态地增加或减少 UILabel 的行数。每次改变行数后，文本都会根据新的行数限制重新应用省略号处理。"
        label.text = self.originalText // 初始化时设置文本
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 18)
        label.lineBreakMode = .byCharWrapping // 保持字符换行
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // 添加按钮 - 增加行数
    private lazy var increaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("增加行数", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(increaseLines), for: .touchUpInside)
        return button
    }()
    
    // 添加按钮 - 减少行数
    private lazy var decreaseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("减少行数", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(decreaseLines), for: .touchUpInside)
        return button
    }()
    
    // 显示当前行数的标签
    private lazy var linesInfoLabel: UILabel = {
        let label = UILabel()
        label.text = "当前行数: \(self.label.numberOfLines)"
        label.textColor = .darkGray
        label.font = UIFont.systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // 添加视图
        view.addSubview(label)
        view.addSubview(increaseButton)
        view.addSubview(decreaseButton)
        view.addSubview(linesInfoLabel)
        
        // 设置约束
        NSLayoutConstraint.activate([
            // Label 约束
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),
            
            // 增加行数按钮约束
            increaseButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            increaseButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 10),
            increaseButton.widthAnchor.constraint(equalToConstant: 100),
            increaseButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 减少行数按钮约束
            decreaseButton.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 30),
            decreaseButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -10),
            decreaseButton.widthAnchor.constraint(equalToConstant: 100),
            decreaseButton.heightAnchor.constraint(equalToConstant: 40),
            
            // 行数信息标签约束
            linesInfoLabel.topAnchor.constraint(equalTo: increaseButton.bottomAnchor, constant: 20),
            linesInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        // 更新行数信息
        updateLinesInfo()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
//        PZXLabelEllipsisHelper.applyCustomEllipsisIfNeeded(to: label)
        label.applyCustomEllipsisIfNeeded()

    }
    
    // 增加行数的方法
    @objc private func increaseLines() {
        // 增加行数，最多不超过10行
        label.numberOfLines = min(label.numberOfLines + 1, 10)

        // 恢复原始文本，以便重新应用省略号
        if let originalText = self.originalText {
            label.text = originalText
        }
        

        
        // 更新行数信息
        updateLinesInfo()
        
        // 重新应用省略号
//        PZXLabelEllipsisHelper.applyCustomEllipsisIfNeeded(to: label)
        label.applyCustomEllipsisIfNeeded()

    }
    
    // 减少行数的方法
    @objc private func decreaseLines() {
        // 减少行数，最少不低于1行
        label.numberOfLines = max(label.numberOfLines - 1, 1)
        
        // 恢复原始文本，以便重新应用省略号
        if let originalText = self.originalText {
            label.text = originalText
        }
        
        // 更新行数信息
        updateLinesInfo()
        
        // 重新应用省略号
//        PZXLabelEllipsisHelper.applyCustomEllipsisIfNeeded(to: label)
        
        label.applyCustomEllipsisIfNeeded()
    }
    
    // 更新行数信息标签
    private func updateLinesInfo() {
        linesInfoLabel.text = "当前行数: \(label.numberOfLines)"
    }
}

