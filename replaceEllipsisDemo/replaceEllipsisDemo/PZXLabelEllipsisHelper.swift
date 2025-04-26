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
    /// - Returns: 是否发生了截断并应用了省略号
    
    static func applyCustomEllipsisIfNeeded(to label: UILabel) {
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
        
        // 如果发生截断，动态计算需要替换的字符数量
        if isTruncated && visibleString.count > 0 {
            // 最少显示的省略号 - 确保至少有3个点
            let minEllipsis = "..."
            
            // 计算最小省略号的宽度
            let minEllipsisWidth = (minEllipsis as NSString).size(withAttributes: [.font: font]).width
                        
            // 从可见字符串的末尾开始，找到合适的截断位置
            var truncatedText = visibleString
            var currentWidth: CGFloat = 0
            var charsRemoved = 0
            
            // 首先我们确保至少有空间放最小省略号
            let maxCharsToRemove = min(visibleString.count - 1, 15) // 最多移除15个字符，并至少保留1个字符
            
            // 先移除字符直到有足够空间放置最小省略号
            while charsRemoved < maxCharsToRemove {
                // 确保有字符可移除
                if truncatedText.isEmpty {
                    break
                }
                
                let lastChar = String(truncatedText.last!)
                let lastCharWidth = (lastChar as NSString).size(withAttributes: [.font: font]).width
                
                // 如果移除的宽度已经足够放置最小省略号，则可以停止移除
                if currentWidth >= minEllipsisWidth {
                    break
                }
                
                truncatedText.removeLast()
                currentWidth += lastCharWidth
                charsRemoved += 1
            }
            
            // 现在我们有足够空间放最小省略号，看看是否还有更多空间放置完整省略号
            let actualEllipsis: String
            actualEllipsis = minEllipsis // 使用最小省略号

            
            // 添加省略号
            truncatedText += actualEllipsis
            
            print("调整后文本 = \(truncatedText), 移除字符数: \(charsRemoved), 使用省略号: \(actualEllipsis)")
            
            if label.text != truncatedText {
                label.text = truncatedText
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
    /// - Returns: 是否应用了省略号
    func applyCustomEllipsisIfNeeded() {
        PZXLabelEllipsisHelper.applyCustomEllipsisIfNeeded(to: self)
    }
}
