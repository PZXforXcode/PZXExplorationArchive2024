//
//  CustomShareView.swift
//  share
//
//  Created by 彭祖鑫 on 2024/11/12.
//

import UIKit

class CustomShareView: UIView {
    
    var shareButtonAction: (() -> Void)?
    var cancelButtonAction: (() -> Void)?
    var contentLabel = UILabel()
    var shareContent: String? {
        didSet {
            if let shareContent {
                self.contentLabel.text = "你要分享的内容为：\(shareContent)"
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    
    private func setupView() {
        self.backgroundColor = .white
        // 设置 contentLabel
        contentLabel.numberOfLines = 0  // 允许多行显示
        contentLabel.textAlignment = .center
        contentLabel.text = "测试文字"
        contentLabel.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentLabel)
        
        // 设置 contentLabel 约束，使其水平垂直居中
        NSLayoutConstraint.activate([
            contentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            contentLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            contentLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20),
            contentLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20)
        ])
        
        // 创建一个容器视图来放置按钮
        let buttonStackView = UIStackView()
        buttonStackView.axis = .vertical
        buttonStackView.spacing = 20
        buttonStackView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(buttonStackView)
        
        // 创建分享按钮
        let shareButton = UIButton(type: .system)
        shareButton.setTitle("分享", for: .normal)
        shareButton.addTarget(self, action: #selector(shareButtonTapped), for: .touchUpInside)
        
        // 创建取消按钮
        let cancelButton = UIButton(type: .system)
        cancelButton.setTitle("取消", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        
        // 将按钮添加到堆栈视图
        buttonStackView.addArrangedSubview(shareButton)
        buttonStackView.addArrangedSubview(cancelButton)
        
        // 设置堆栈视图的约束
        NSLayoutConstraint.activate([
            buttonStackView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            buttonStackView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            buttonStackView.leadingAnchor.constraint(greaterThanOrEqualTo: self.leadingAnchor, constant: 20),
            buttonStackView.trailingAnchor.constraint(lessThanOrEqualTo: self.trailingAnchor, constant: -20)
        ])
    }
    
    @objc
    private func shareButtonTapped() {
        shareButtonAction?()
    }

    @objc
    private func cancelButtonTapped() {
        cancelButtonAction?()
    }
}
