//
//  PZXEllipsisLabel.swift
//  ByCharWrappingStudy
//
//  Created by 彭祖鑫 on 2025/4/28.
//
//能实现 按字符换行且尾部有...的Label
import UIKit

class PZXEllipsisLabel: UILabel {
    
    // MARK: - 常量
    private let ellipsisString = "..."
    
    // MARK: - 初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        // 默认设置
        numberOfLines = 0
        lineBreakMode = .byTruncatingTail // 默认由 UILabel 处理，但我们自定义
        contentMode = .redraw // 确保 bounds 变化时重绘
    }
    
    // MARK: - 文本大小计算 (关键修复)
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        guard let text = self.text, !text.isEmpty else {
            return super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        }
        
        // 1. 创建文本系统组件
        let textStorage = createTextStorage(for: text)
        let layoutManager = NSLayoutManager()
        // 重要：使用传入的 bounds 计算，特别是宽度
        let textContainer = NSTextContainer(size: CGSize(width: bounds.width, height: CGFloat.greatestFiniteMagnitude))
        
        // 2. 配置文本容器
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = numberOfLines // 使用传入的限制
        textContainer.lineBreakMode = .byCharWrapping // 强制字符换行计算
        
        // 3. 连接组件
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // 4. 计算实际需要的总高度 (精确)
        var totalHeight: CGFloat = 0
        var lineCount = 0
        // 使用 enumerateLineFragments 遍历实际渲染的行
        layoutManager.enumerateLineFragments(forGlyphRange: layoutManager.glyphRange(for: textContainer)) { rect, usedRect, container, glyphRange, stop in
            totalHeight += usedRect.height // 累加 **实际使用** 的高度
            lineCount += 1
            // 如果设置了行数限制，并且已经达到限制，则停止累加
            if numberOfLines > 0 && lineCount >= numberOfLines {
                stop.pointee = true
            }
        }
        
        // 5. 处理特殊情况：没有文本或计算高度为0，则至少返回一行的高度
        if totalHeight == 0 && !text.isEmpty {
            totalHeight = self.font.lineHeight
        }
        
        // 6. 返回计算得到的精确边界
        // 注意：宽度仍然使用传入的 bounds.width，因为换行依赖于此宽度
        // 高度使用我们精确计算的 totalHeight
        let calculatedRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.width, height: ceil(totalHeight)) // 使用 ceil 避免浮点数精度问题
        print("textRect calculated height: \(calculatedRect.height) for lines: \(numberOfLines)")
        return calculatedRect
    }
    
    // MARK: - 绘制方法
    override func drawText(in rect: CGRect) {
        print("drawText in rect: \(rect)")
        guard let textToDraw = text, !textToDraw.isEmpty else {
            super.drawText(in: rect) // 如果没文本，调用父类绘制
            return
        }
        
        // 1. 创建文本系统组件 (用于绘制)
        let textStorage = createTextStorage(for: textToDraw)
        let layoutManager = NSLayoutManager()
        let textContainer = NSTextContainer(size: rect.size) // 使用传入的绘制区域 rect
        
        // 2. 配置文本容器
        configureTextContainer(textContainer) // 使用 self.numberOfLines
        
        // 3. 连接组件
        textStorage.addLayoutManager(layoutManager)
        layoutManager.addTextContainer(textContainer)
        
        // 4. 判断是否需要截断 (准确判断)
        let totalLinesNeeded = countTotalLines(textStorage: textStorage, width: rect.width)
        let needsTruncation = (numberOfLines > 0 && totalLinesNeeded > numberOfLines)
        
        print("Total lines needed: \(totalLinesNeeded), numberOfLines: \(self.numberOfLines), needsTruncation: \(needsTruncation)")
        
        // 5. 获取绘制的 glyph 范围
        // 这个 glyphRange 是根据 textContainer 的 size 和 maximumNumberOfLines 计算出来的
        let glyphRangeToDraw = layoutManager.glyphRange(for: textContainer)
        
        if needsTruncation {
            print("Drawing truncated text...")
            // 处理文本截断，添加省略号
            drawTruncatedText(layoutManager, textContainer, textStorage, glyphRangeToDraw, in: rect)
        }
        else {
            print("Drawing full text... Glyph range length: \(glyphRangeToDraw.length)")
            // 直接绘制可见的全部文本
            layoutManager.drawBackground(forGlyphRange: glyphRangeToDraw, at: rect.origin)
            layoutManager.drawGlyphs(forGlyphRange: glyphRangeToDraw, at: rect.origin)
        }
    }
    
    // MARK: - 辅助方法
    private func createTextStorage(for text: String) -> NSTextStorage {
        // 创建段落样式
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping // 关键设置：按字符换行
        paragraphStyle.lineBreakStrategy = .pushOut
        
        // 创建属性字符串
        let attributes: [NSAttributedString.Key: Any] = [
            .font: self.font as Any,
            .foregroundColor: self.textColor as Any,
            .paragraphStyle: paragraphStyle
        ]
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        
        return NSTextStorage(attributedString: attributedString)
    }
    
    private func configureTextContainer(_ textContainer: NSTextContainer) {
        textContainer.lineFragmentPadding = 0
        textContainer.maximumNumberOfLines = self.numberOfLines // 使用实例的 numberOfLines
        textContainer.lineBreakMode = .byTruncatingTail // 容器本身也设置截断，LayoutManager 会参考
    }
    
    // 计算完整文本在给定宽度下所需的总行数
    private func countTotalLines(textStorage: NSTextStorage, width: CGFloat) -> Int {
        // 创建临时布局管理器和容器来计算完整文本行数
        let tempLayoutManager = NSLayoutManager()
        let tempContainer = NSTextContainer(size: CGSize(width: width, height: CGFloat.greatestFiniteMagnitude))
        tempContainer.lineFragmentPadding = 0
        tempContainer.maximumNumberOfLines = 0 // 不限制行数
        tempContainer.lineBreakMode = .byCharWrapping // 确保按字符换行计算
        
        textStorage.addLayoutManager(tempLayoutManager)
        tempLayoutManager.addTextContainer(tempContainer)
        
        // 计算所需的总行数
        var lineCount = 0
        tempLayoutManager.enumerateLineFragments(forGlyphRange: tempLayoutManager.glyphRange(for: tempContainer)) { _, _, _, _, stop in
            lineCount += 1
        }
        
        // 清理临时添加的 layoutManager
        textStorage.removeLayoutManager(tempLayoutManager)
        
        return lineCount
    }
    
    // 绘制带省略号的文本 (关键修复)
    private func drawTruncatedText(_ layoutManager: NSLayoutManager, _ textContainer: NSTextContainer, _ textStorage: NSTextStorage, _ glyphRangeToDraw: NSRange, in rect: CGRect) {
        
        // 1. 确定最后一行的 glyph 范围
        var lastLineGlyphRange = NSRange(location: NSNotFound, length: 0)
        let visibleGlyphRange = layoutManager.glyphRange(for: textContainer)
        layoutManager.enumerateLineFragments(forGlyphRange: visibleGlyphRange) { lineRect, usedRect, container, lineGlyphRange, stop in
            // 检查是否是最后可见的行
            if NSMaxRange(lineGlyphRange) >= NSMaxRange(visibleGlyphRange) {
                lastLineGlyphRange = lineGlyphRange
                stop.pointee = true
            }
        }
        
        if lastLineGlyphRange.location == NSNotFound {
             // 如果找不到最后一行（理论上不应发生），则绘制原始可见部分
            print("Warning: Could not find last line to truncate.")
            layoutManager.drawBackground(forGlyphRange: glyphRangeToDraw, at: rect.origin)
            layoutManager.drawGlyphs(forGlyphRange: glyphRangeToDraw, at: rect.origin)
            return
        }
        
        // 2. 计算省略号宽度和最后一行可用宽度
        let ellipsisWidth = ellipsisString.size(withAttributes: [.font: font as Any]).width
        let lastLineFragmentRect = layoutManager.lineFragmentUsedRect(forGlyphAt: lastLineGlyphRange.location, effectiveRange: nil)
        let availableWidth = lastLineFragmentRect.width - ellipsisWidth
        
        // 3. 找到最后一个能完全显示的 glyph
        var lastVisibleGlyphIndexInLine = lastLineGlyphRange.location
        var currentWidth: CGFloat = 0
        
        for glyphIndex in lastLineGlyphRange.location..<NSMaxRange(lastLineGlyphRange) {
            let glyphRect = layoutManager.boundingRect(forGlyphRange: NSRange(location: glyphIndex, length: 1), in: textContainer)
            if currentWidth + glyphRect.width <= availableWidth {
                currentWidth += glyphRect.width
                lastVisibleGlyphIndexInLine = glyphIndex
            } else {
                break // 宽度不足
            }
        }
        
        // 4. 计算截断位置的字符索引
        // 注意 +1 是因为 characterIndexForGlyph 返回的是字形覆盖的第一个字符索引
        let truncateLocation = layoutManager.characterIndexForGlyph(at: lastVisibleGlyphIndexInLine) + 1
        
        // 5. 创建并绘制截断后的属性字符串
        if let originalText = textStorage.string as NSString? {
            // 确保截断位置有效
            guard truncateLocation >= 0 && truncateLocation < originalText.length else {
                print("Warning: Invalid truncateLocation: \(truncateLocation)")
                 layoutManager.drawBackground(forGlyphRange: glyphRangeToDraw, at: rect.origin)
                 layoutManager.drawGlyphs(forGlyphRange: glyphRangeToDraw, at: rect.origin)
                 return
            }
            
            let truncatedString = originalText.substring(to: truncateLocation) + ellipsisString
            
            // 重新创建属性字符串进行绘制
            let truncatedAttrString = NSAttributedString(string: truncatedString, attributes: textStorage.attributes(at: 0, effectiveRange: nil))
            
            // 直接绘制这个截断后的字符串到目标 rect
            // 不需要再创建新的 LayoutManager/TextContainer，因为我们已经知道在哪里绘制
            truncatedAttrString.draw(in: rect)
            print("Drew truncated string: \(truncatedString)")
            
        } else {
            // 如果原始文本转换失败，绘制原始可见部分
             layoutManager.drawBackground(forGlyphRange: glyphRangeToDraw, at: rect.origin)
             layoutManager.drawGlyphs(forGlyphRange: glyphRangeToDraw, at: rect.origin)
        }
    }
    
    // MARK: - 重写属性以支持自动布局
    override var intrinsicContentSize: CGSize {
        let size = textRect(forBounds: CGRect(x: 0, y: 0, width: bounds.width > 0 ? bounds.width : CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude), limitedToNumberOfLines: numberOfLines).size
         print("intrinsicContentSize calculated: \(size)")
        return size
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
         let fittedSize = textRect(forBounds: CGRect(origin: .zero, size: size), limitedToNumberOfLines: numberOfLines).size
         print("sizeThatFits calculated: \(fittedSize) for input: \(size)")
        return fittedSize
    }
    
    // 触发重新计算布局和重绘
    override var numberOfLines: Int {
        didSet {
            if oldValue != numberOfLines {
                setNeedsLayout()
                invalidateIntrinsicContentSize()
            }
        }
    }
    
    override var text: String? {
         didSet {
             if oldValue != text {
                 setNeedsLayout()
                 invalidateIntrinsicContentSize()
             }
         }
     }
    
     override var font: UIFont! {
         didSet {
             if oldValue != font {
                 setNeedsLayout()
                 invalidateIntrinsicContentSize()
             }
         }
     }
    
     override var bounds: CGRect {
         didSet {
             if oldValue.size != bounds.size {
                 // 宽度变化可能影响换行，需要重新布局
                 setNeedsLayout()
                 invalidateIntrinsicContentSize()
             }
         }
     }
} 
