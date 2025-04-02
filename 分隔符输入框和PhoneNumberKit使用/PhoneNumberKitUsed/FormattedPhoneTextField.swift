//
//  FormattedPhoneTextField.swift
//  PhoneNumberKitUsed
//
//  Created by 彭祖鑫 on 2025/4/2.
//

import UIKit

/**
 * 自定义格式化电话号码输入框
 * 实现了344格式（xxx xxxx xxxx）的电话号码格式化
 * 自我处理文本格式化和光标位置
 */
class FormattedPhoneTextField: UITextField {
    
    // MARK: - 属性
    
    /// 电话号码的分段长度规则，默认为 [3, 4, 4]
    var lengthSegments: [Int] = [3, 4, 4]
    
    /// 分隔符，默认为空格
    var separator: String = " "
    
    /// 是否仅允许输入数字
    var digitsOnly: Bool = true
    
    /// 最大允许的数字数量，默认为11（与344格式对应）
    var maxDigits: Int = 11
    
    // MARK: - 初始化方法
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    /**
     * 初始化设置
     */
    private func setup() {
        // 设置键盘类型为数字键盘
        self.keyboardType = .numberPad
        // 设置自身为代理
        self.delegate = self
    }
    
    // MARK: - 格式化方法
    
    /**
     * 格式化电话号码为指定的分段格式
     * @param number 纯数字字符串
     * @return 格式化后的电话号码字符串
     */
    func formatPhoneNumber(_ number: String) -> String {
        var formatted = ""
        var index = 0
        
        for length in lengthSegments {
            if index >= number.count {
                break
            }
            // 从字符串中提取指定长度的子串
            let start = number.index(number.startIndex, offsetBy: index)
            let end = number.index(start, offsetBy: min(length, number.count - index))
            let part = number[start..<end]
            
            if formatted.isEmpty {
                formatted += String(part)
            } else {
                formatted += separator + String(part)
            }
            
            index += length
        }
        
        return formatted
    }
    
    /**
     * 获取纯数字字符串
     * @param text 带格式的文本
     * @return 只包含数字的字符串
     */
    func extractDigits(from text: String) -> String {
        return text.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
    }
}

// MARK: - UITextFieldDelegate

extension FormattedPhoneTextField: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取当前输入框的文本
        let currentText = textField.text ?? ""
        
        // 处理退格键的特殊情况：光标在分隔符后面
        if string.isEmpty && range.length == 1 {
            // 检查是否删除的是分隔符
            if let rangeStart = Range(range, in: currentText)?.lowerBound,
               String(currentText[rangeStart]) == separator {
                
                // 创建一个新的范围，包括分隔符前的一个数字
                if let selectedRange = textField.selectedTextRange,
                   let newPosition = textField.position(from: selectedRange.start, offset: -1),
                   let _ = textField.textRange(from: newPosition, to: selectedRange.end) {
                    
                    // 获取新范围的位置
                    let location = textField.offset(from: textField.beginningOfDocument, to: newPosition)
                    let length = textField.offset(from: newPosition, to: selectedRange.end)
                    
                    // 计算用户输入后的新文本
                    let nsRange = NSRange(location: location, length: length + 1)
                    let modifiedText = (currentText as NSString).replacingCharacters(in: nsRange, with: "")
                    
                    // 移除所有非数字字符，只保留数字
                    let digits = extractDigits(from: modifiedText)
                    
                    // 格式化电话号码
                    let formattedPhoneNumber = formatPhoneNumber(digits)
                    
                    // 更新输入框的显示
                    textField.text = formattedPhoneNumber
                    
                    // 设置新的光标位置（删除分隔符和前一个数字后，光标应该在前一个位置）
                    if let position = textField.position(from: textField.beginningOfDocument, offset: location) {
                        textField.selectedTextRange = textField.textRange(from: position, to: position)
                    }
                    
                    return false
                }
            }
        }
        
        // 如果设置了只允许数字，且输入的不是数字也不是删除操作，则拒绝输入
        if digitsOnly && !string.isEmpty {
            let allowedCharSet = CharacterSet.decimalDigits
            let characterSet = CharacterSet(charactersIn: string)
            if !allowedCharSet.isSuperset(of: characterSet) {
                return false
            }
        }
        
        // 获取当前光标位置
        guard let selectedRange = textField.selectedTextRange else {
            return true
        }
        
        // 当前光标位置
        let cursorPosition = textField.offset(from: textField.beginningOfDocument, to: selectedRange.end)
        
        // 获取当前文本中光标之前的数字数量
        var digitCountBeforeCursor = 0
        for i in 0..<cursorPosition {
            if i < currentText.count {
                let index = currentText.index(currentText.startIndex, offsetBy: i)
                if CharacterSet.decimalDigits.contains(Unicode.Scalar(String(currentText[index]))!) {
                    digitCountBeforeCursor += 1
                }
            }
        }
        
        // 处理删除操作
        if string.isEmpty && range.length == 1 {
            // 如果删除的是数字，需要调整光标位置的计数
            let deleteRange = Range(range, in: currentText)!
            let deleteChar = currentText[deleteRange.lowerBound]
            if CharacterSet.decimalDigits.contains(Unicode.Scalar(String(deleteChar))!) {
                digitCountBeforeCursor -= 1
            }
        } else {
            // 如果是添加字符，需要计算添加的数字数量
            let addedDigitCount = string.filter { char in
                guard let scalar = Unicode.Scalar(String(char)) else { return false }
                return CharacterSet.decimalDigits.contains(scalar)
            }.count
            digitCountBeforeCursor += addedDigitCount
        }
        
        // 计算用户输入后的新文本
        let newText = (currentText as NSString).replacingCharacters(in: range, with: string)
        
        // 移除所有非数字字符，只保留数字
        let digits = extractDigits(from: newText)
        
        // 检查是否超过最大位数
        if digits.count > maxDigits {
            return false
        }
        
        // 格式化电话号码
        let formattedPhoneNumber = formatPhoneNumber(digits)
        
        // 更新输入框的显示
        textField.text = formattedPhoneNumber
        
        // 恢复光标位置
        setFormattedTextCursorPosition(textField: textField, formattedText: formattedPhoneNumber, digitCountBeforeCursor: digitCountBeforeCursor)
        
        return false
    }
    
    /**
     * 根据光标前的数字数量设置格式化后文本的光标位置
     * @param textField 文本输入框
     * @param formattedText 格式化后的文本
     * @param digitCountBeforeCursor 光标前的数字数量
     */
    private func setFormattedTextCursorPosition(textField: UITextField, formattedText: String, digitCountBeforeCursor: Int) {
        // 特殊情况处理：如果数字数量为0，光标应该在开头
        if digitCountBeforeCursor <= 0 {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: 0) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return
        }
        
        // 特殊情况处理：如果所有数字都在光标之前，则光标应该在文本的最后
        let totalDigitCount = formattedText.filter { $0.isNumber }.count
        if digitCountBeforeCursor >= totalDigitCount {
            if let newPosition = textField.position(from: textField.beginningOfDocument, offset: formattedText.count) {
                textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
            }
            return
        }
        
        // 计算新的光标位置
        var newCursorOffset = 0
        var countedDigits = 0
        
        for (index, char) in formattedText.enumerated() {
            if char.isNumber {
                countedDigits += 1
                if countedDigits == digitCountBeforeCursor {
                    newCursorOffset = index + 1 // 光标应该在找到的数字后面
                    break
                }
            }
        }
        
        // 设置新的光标位置
        if let newPosition = textField.position(from: textField.beginningOfDocument, offset: newCursorOffset) {
            textField.selectedTextRange = textField.textRange(from: newPosition, to: newPosition)
        }
    }
}
