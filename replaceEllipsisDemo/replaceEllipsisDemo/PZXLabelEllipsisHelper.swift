//
//  PZXLabelEllipsisHelper.swift
//  replaceEllipsisDemo
//
//  Created by 彭祖鑫 on 2025/4/26.
//

import UIKit

/// 标签省略号处理工具类
class PZXLabelEllipsisHelper {
    
    /// 将 UILabel 中溢出的文本末尾替换为省略号
    /// - Parameters:
    ///   - label: 需要处理的标签
    ///   - ellipsis: 省略号字符串，默认为 "......"
    ///   - charsToReplace: 需要替换的尾部字符数，默认为 3
    /// - Returns: 是否发生了截断并应用了省略号
    
    static func applyCustomEllipsisIfNeeded(to label: UILabel,
                                           ellipsis: String = "......",
                                           charsToReplace: Int = 3) {
        guard let originalText = label.text,
              let font = label.font,
              label.bounds.width > 0,
              originalText.count > 3
        else { return }
        label.layoutIfNeeded()
        label.setNeedsLayout()
        // 创建一个临时的UILabel来更准确地模拟实际UILabel的行为
        let testLabel = UILabel(frame: CGRect(x: 0, y: 0, width: label.bounds.width, height: .greatestFiniteMagnitude))
        testLabel.font = font
        testLabel.text = originalText
        testLabel.numberOfLines = label.numberOfLines
        testLabel.lineBreakMode = label.lineBreakMode
        
        // 让临时标签布局并确定其尺寸
        testLabel.sizeToFit()
        let labelHeight = testLabel.bounds.size.height
        
        // 使用实际行高和UILabel的属性来设置TextKit
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = label.lineBreakMode
        
        let attributedString = NSAttributedString(string: originalText, attributes: [
            .font: font,
            .paragraphStyle: paragraphStyle
        ])
        
        let textStorage = NSTextStorage(attributedString: attributedString)
        let layoutManager = NSLayoutManager()
        textStorage.addLayoutManager(layoutManager)
        
        // 使用精确的行高和提供额外空间来避免潜在的裁剪问题
        let lineHeight = font.lineHeight
        let lineSpacing = (labelHeight / CGFloat(label.numberOfLines)) - lineHeight
        
        // 为三行文本提供足够的空间
        let containerHeight = (lineHeight + lineSpacing) * CGFloat(label.numberOfLines) + 5 // 添加一点额外空间
        
        let textContainer = NSTextContainer(size: CGSize(width: label.bounds.width, height: containerHeight))
        textContainer.lineBreakMode = label.lineBreakMode
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = label.numberOfLines
        layoutManager.addTextContainer(textContainer)
        
        // 获取可见范围
        let glyphRange = layoutManager.glyphRange(for: textContainer)
        let characterRange = layoutManager.characterRange(forGlyphRange: glyphRange, actualGlyphRange: nil)
        
        let visibleString = (originalText as NSString).substring(with: NSRange(location: 0, length: characterRange.length))
        print("visibleString = \(visibleString)")
        
        // 打印并检查实际显示文本是否已截断
        let isTruncated = characterRange.length < originalText.count
        print("是否截断: \(isTruncated)")
        print("可见字符数: \(characterRange.length), 原文字符数: \(originalText.count)")
        
        // 另一种方法：将临时标签的文本设置为字符索引，看看最后能显示哪个索引
        let characterIndexString = String(Array(0..<originalText.count).map { String($0 % 10) }.joined())
        testLabel.text = characterIndexString
        testLabel.sizeToFit() // 重新计算尺寸
        
        // 如果发生截断，应用省略号
        if isTruncated && visibleString.count >= charsToReplace {
            // 从可见文本移除最后3个字符，添加省略号
            let truncatedVisibleText = String(visibleString.dropLast(charsToReplace)) + ellipsis
            print("truncatedVisibleText = \(truncatedVisibleText)")
            
            if label.text != truncatedVisibleText {
                label.text = truncatedVisibleText
            }
        } else if !isTruncated {
            // 没有截断，显示完整文本
            if label.text != originalText {
                label.text = originalText
            }
        }
    }
    
}

// 可选：为 UILabel 添加便捷扩展方法
extension UILabel {
    /// 应用自定义省略号（如果文本溢出）
    /// - Parameters:
    ///   - ellipsis: 省略号字符串，默认为 "......"
    ///   - charsToReplace: 需要替换的尾部字符数，默认为 3
    /// - Returns: 是否应用了省略号
    func applyCustomEllipsisIfNeeded(ellipsis: String = "......", charsToReplace: Int = 3) {
        PZXLabelEllipsisHelper.applyCustomEllipsisIfNeeded(to: self,
                                                              ellipsis: ellipsis,
                                                              charsToReplace: charsToReplace)
    }
}
