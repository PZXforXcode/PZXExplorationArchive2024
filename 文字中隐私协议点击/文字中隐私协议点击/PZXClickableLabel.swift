import UIKit
import CoreText

class PZXClickableLabel: UILabel {
    private var pzxAttributedText: NSAttributedString?
    private var clickableRanges: [(range: NSRange, identifier: String)] = []
    var onTextTap: ((String) -> Void)? // 点击回调
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear // 设置背景色为透明
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.isUserInteractionEnabled = true
        self.backgroundColor = .clear // 设置背景色为透明
    }

    
    func setupText(_ text: String, clickableTexts: [String]) {
        // 创建富文本并设置字体和颜色
        let font = UIFont.systemFont(ofSize: 22)
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: font, // 设置字体
            .foregroundColor: UIColor.black // 默认字体颜色
        ])
        let fullText = text as NSString

        // 清空旧的范围记录
        clickableRanges.removeAll()

        // 设置可点击文字的样式和范围
        for clickableText in clickableTexts {
            let range = fullText.range(of: clickableText)
            if range.location != NSNotFound {
                clickableRanges.append((range: range, identifier: clickableText))
                attributedString.addAttribute(.foregroundColor, value: UIColor.blue, range: range) // 设置可点击文字的颜色
                attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range) // 设置下划线
            }
        }
        
        let paragraphStyle = getDefaultParagraphStyle() // 使用封装的函数
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.pzxAttributedText = attributedString
        setNeedsDisplay() // 重新绘制
    }
    
    func setupTextWithStyle(_ text: String,
                            font: UIFont = UIFont.systemFont(ofSize: 22),
                            textColor: UIColor = .black,
                            clickableTextColor: UIColor = .blue,
                            underlineStyle: NSUnderlineStyle = .single,
                            clickableTexts: [String]) {
        // 创建富文本并设置字体和颜色
        let attributedString = NSMutableAttributedString(string: text, attributes: [
            .font: font, // 设置字体
            .foregroundColor: textColor // 默认字体颜色
        ])
        let fullText = text as NSString

        // 清空旧的范围记录
        clickableRanges.removeAll()

        // 设置可点击文字的样式和范围
        for clickableText in clickableTexts {
            let range = fullText.range(of: clickableText)
            if range.location != NSNotFound {
                clickableRanges.append((range: range, identifier: clickableText))
                attributedString.addAttribute(.foregroundColor, value: clickableTextColor, range: range) // 设置可点击文字的颜色
                attributedString.addAttribute(.underlineStyle, value: underlineStyle.rawValue, range: range) // 设置下划线样式
            }
        }

        let paragraphStyle = getDefaultParagraphStyle() // 使用封装的函数
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))

        self.pzxAttributedText = attributedString
        setNeedsDisplay() // 重新绘制
    }

    // MARK: - 绘制文本
//    override func draw(_ rect: CGRect) {
//        guard let context = UIGraphicsGetCurrentContext(), let attributedText = pzxAttributedText else { return }
//
//        // 翻转坐标系，CoreText 的坐标系是左下角为原点
//        context.textMatrix = .identity
//        context.translateBy(x: 0, y: bounds.size.height)
//        context.scaleBy(x: 1.0, y: -1.0)
//
//        // 创建 CTFramesetter
//        let path = CGPath(rect: bounds, transform: nil)
//        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
//        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)
//
//        // 获取文本的所有行
//        let lines = CTFrameGetLines(frame) as! [CTLine]
//        // 计算文本的最大矩形区域
//        var origins = [CGPoint](repeating: CGPoint.zero, count: lines.count)
//        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
//
//        // 计算整个文本框的背景区域
//        var maxY: CGFloat = 0.0
//        for (index, line) in lines.enumerated() {
//            let lineOrigin = origins[index]
//            var ascent: CGFloat = 0.0
//            var descent: CGFloat = 0.0
//            var leading: CGFloat = 0.0
//
//            // 获取该行的 typographic bounds
//            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
//
//            let lineHeight = ascent + descent
//            let lineRect = CGRect(x: 0, y: lineOrigin.y - descent, width: bounds.width, height: lineHeight)
//
//            // 找到最高的Y值，确定背景的高度
//            if lineOrigin.y > maxY {
//                maxY = lineOrigin.y
//            }
//
//            // 在文本框的每一行区域绘制背景色
//            context.setFillColor(UIColor.lightGray.withAlphaComponent(0.3).cgColor)  // 设置背景色
//            context.fill(lineRect)  // 填充背景色
//        }
//
//        // 绘制文本
//        CTFrameDraw(frame, context)
//    }

    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext(), let attributedText = pzxAttributedText else { return }

        // 翻转坐标系，CoreText 的坐标系是左下角为原点
        context.textMatrix = .identity
        context.translateBy(x: 0, y: bounds.size.height)
        context.scaleBy(x: 1.0, y: -1.0)

        // 创建 CTFramesetter
        let path = CGPath(rect: bounds, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)

        // 绘制文本
        CTFrameDraw(frame, context)
    }
    
    private func getDefaultParagraphStyle() -> NSMutableParagraphStyle {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byCharWrapping // 按字符换行
//        paragraphStyle.lineBreakMode = .byTruncatingTail // 设置省略号
        paragraphStyle.lineSpacing = 0 // 设置行间距
        paragraphStyle.alignment = .left // 设置对齐方式
        return paragraphStyle
    }

    // MARK: - 触摸事件处理
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first, let attributedText = pzxAttributedText else { return }
        let location = touch.location(in: self)

        // 创建 CTFramesetter
        let path = CGPath(rect: bounds, transform: nil)
        let framesetter = CTFramesetterCreateWithAttributedString(attributedText as CFAttributedString)
        let frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, attributedText.length), path, nil)

        // 获取点击位置的字符索引
        guard let lines = CTFrameGetLines(frame) as? [CTLine] else { return }
        let origins = UnsafeMutablePointer<CGPoint>.allocate(capacity: lines.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), origins)

        for (index, line) in lines.enumerated() {
            let lineOrigin = origins[index]

            // 计算点击点是否在当前行范围内
            let transformedPoint = CGPoint(x: location.x - lineOrigin.x, y: bounds.height - location.y - lineOrigin.y)

            // 获取该行的 typographic bounds
            var _: CGFloat = 0
            var lineHeight: CGFloat = 0
            var ascent: CGFloat = 0
            var descent: CGFloat = 0
            var leading: CGFloat = 0
            
            CTLineGetTypographicBounds(line, &ascent, &descent, &leading)
            lineHeight = ascent + descent

            // 确保点击点在当前行的 Y 范围内
            if transformedPoint.y >= 0 && transformedPoint.y <= lineHeight {
                // 获取字符索引
                let charIndex = CTLineGetStringIndexForPosition(line, transformedPoint)

                // 判断字符索引是否在某个可点击范围内
                for rangeInfo in clickableRanges {
                    if NSLocationInRange(charIndex, rangeInfo.range) {
                        onTextTap?(rangeInfo.identifier) // 触发点击回调
                        origins.deallocate()
                        return
                    }
                }
            }
        }
        origins.deallocate()
    }



}


