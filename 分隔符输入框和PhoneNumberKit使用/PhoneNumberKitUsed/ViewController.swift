//
//  ViewController.swift
//  PhoneNumberKitUsed
//
//  Created by 彭祖鑫 on 2025/4/2.
//

import UIKit

/**
 * 主视图控制器类
 * 该类实现了UITextFieldDelegate协议，用于处理文本输入框的输入事件
 */
class ViewController: UIViewController {
    
    /// PhoneNumberKit专用输入框，支持国际电话号码的格式化和验证
    private lazy var phoneNumberTextField: PhoneNumberTextField = {
        let textField = PhoneNumberTextField()
        // 是否显示国家/地区代码前缀
        textField.withPrefix = false
        // 是否显示国旗图标
        textField.withFlag = true
        // 是否显示示例占位符
        textField.withExamplePlaceholder = true
        // 是否启用默认的国家/地区选择器界面
        textField.withDefaultPickerUI = true
        // 最大数字位数限制（当前被注释)
        // textField.maxDigits = 11
        textField.partialFormatter.defaultRegion = "CN"

        // 设置占位符文本
        textField.placeholder = "请输入手机号码"
        // 禁止自动转换约束，以便手动设置约束
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    /// 自定义格式化的电话号码输入框，实现344格式的电话号码输入
    private lazy var normalTextField: FormattedPhoneTextField = {
        let textField = FormattedPhoneTextField()
        // 设置占位符文本
        textField.placeholder = "普通输入框 (344格式)"
        // 设置边框样式为圆角矩形
        textField.borderStyle = .roundedRect
        // 禁止自动转换约束，以便手动设置约束
        textField.translatesAutoresizingMaskIntoConstraints = false
        // 设置键盘类型为数字键盘
        textField.keyboardType = .numberPad
        // 配置格式化参数
        textField.lengthSegments = [3, 4, 4]
        textField.separator = " "
        textField.maxDigits = 11
        return textField
    }()
    
    /**
     * 视图加载完成后调用
     * 在此方法中设置UI界面
     */
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    /**
     * 设置UI界面元素
     * 添加各种控件到视图并设置约束
     */
    private func setupUI() {
        // 将电话号码输入框添加到视图
        view.addSubview(phoneNumberTextField)
        // 将普通输入框添加到视图
        view.addSubview(normalTextField)
        
        // 激活自动布局约束
        NSLayoutConstraint.activate([
            // PhoneNumberTextField居中显示
            phoneNumberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneNumberTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            // 设置输入框的宽度为300点
            phoneNumberTextField.widthAnchor.constraint(equalToConstant: 300),
            // 设置输入框的高度为44点
            phoneNumberTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // 普通输入框位于PhoneNumberTextField下方20点的位置
            normalTextField.topAnchor.constraint(equalTo: phoneNumberTextField.bottomAnchor, constant: 20),
            // 普通输入框水平居中对齐
            normalTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // 设置输入框的宽度为300点
            normalTextField.widthAnchor.constraint(equalToConstant: 300),
            // 设置输入框的高度为44点
            normalTextField.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
}

