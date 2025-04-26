//
//  ViewController.swift
//  ByCharWrappingStudy
//
//  Created by 彭祖鑫 on 2025/4/26.
//

import UIKit

class ViewController: UIViewController {
    
    private let testLabel: PZXEllipsisLabel = {
        let label = PZXEllipsisLabel()
    label.text = "RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980"
//        label.text = "RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.0989809808009890890098980980800989089009898098080098908900989809808009890890098980980800989089009898098080098908900989809808009890890 RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.0989809808009890890098980980800989089009898098080098908900989809808009890890098980980800989089009898098080098908900989809808009890890 RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980.0989809808009890890098980980800989089009898098080098908900989809808009890890098980980800989089009898098080098908900989809808009890890"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .lightGray
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 4 // 设置初始显示4行
        label.lineBreakMode = .byTruncatingTail // 设置省略号在末尾
        
//        label.text = "RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980RM 9809812980213980.09898098080098908909809812980213980.09898098080098908909809812980213980"

  
        return label
    }()
    
    private let lineCountLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.text = "行数: 4"
        label.textColor = .black
        return label
    }()
    
    private let plusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()
    
    private let minusButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("-", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        setupUI()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // 添加子视图
        view.addSubview(testLabel)
        view.addSubview(lineCountLabel)
        view.addSubview(plusButton)
        view.addSubview(minusButton)
        
        // 设置约束
        let leadingConstraintConstant: CGFloat = 20
        let trailingConstraintConstant: CGFloat = -20
        NSLayoutConstraint.activate([
            // 文本标签约束
            testLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            testLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: leadingConstraintConstant),
            testLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: trailingConstraintConstant),
            
            // 行数标签约束
            lineCountLabel.topAnchor.constraint(equalTo: testLabel.bottomAnchor, constant: 30),
            lineCountLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lineCountLabel.widthAnchor.constraint(equalToConstant: 100),
            
            // 按钮约束 - 水平排列
            minusButton.topAnchor.constraint(equalTo: lineCountLabel.bottomAnchor, constant: 20),
            minusButton.trailingAnchor.constraint(equalTo: view.centerXAnchor, constant: -20),
            minusButton.widthAnchor.constraint(equalToConstant: 50),
            minusButton.heightAnchor.constraint(equalToConstant: 50),
            
            plusButton.topAnchor.constraint(equalTo: lineCountLabel.bottomAnchor, constant: 20),
            plusButton.leadingAnchor.constraint(equalTo: view.centerXAnchor, constant: 20),
            plusButton.widthAnchor.constraint(equalToConstant: 50),
            plusButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // 更新行数显示
        updateLineCountLabel()
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        // --- 结束新增代码 ---
    }
    
    private func setupActions() {
        plusButton.addTarget(self, action: #selector(increaseLines), for: .touchUpInside)
        minusButton.addTarget(self, action: #selector(decreaseLines), for: .touchUpInside)
    }
    
    // MARK: - 按钮事件处理
    
    @objc private func increaseLines() {
        // 增加行数，最大限制为10行
        testLabel.numberOfLines = min(testLabel.numberOfLines + 1, 20)
        updateLineCountLabel()
        updateLabelLayout()
    }
    
    @objc private func decreaseLines() {
        // 减少行数，最少为1行
        testLabel.numberOfLines = max(testLabel.numberOfLines - 1, 1)
        updateLineCountLabel()
        updateLabelLayout()
    }
    
    private func updateLineCountLabel() {
        lineCountLabel.text = "行数: \(testLabel.numberOfLines)"
    }
    
    private func updateLabelLayout() {
        // 强制更新布局
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

