import DGCharts

class CustomYAxisRenderer: YAxisRenderer {

    override func renderLimitLines(context: CGContext) {
        //以前的不绘制
//        super.renderLimitLines(context: context)
        let yAxis = self.axis
        let limitLines = yAxis.limitLines
        
        if limitLines.isEmpty { return }

        context.saveGState()
        defer { context.restoreGState() }

        // 遍历所有限制线
        for limitLine in limitLines {
            if !limitLine.isEnabled { continue }
            
            let position = transformer?.pixelForValues(x: 0.0, y: limitLine.limit)

            // 绘制限制线
            context.setStrokeColor(limitLine.lineColor.cgColor)
            context.setLineWidth(limitLine.lineWidth)
            
            if let lineDashLengths = limitLine.lineDashLengths {
                context.setLineDash(phase: limitLine.lineDashPhase, lengths: lineDashLengths)
            } else {
                context.setLineDash(phase: 0, lengths: [])
            }
            
            context.beginPath()
            context.move(to: CGPoint(x: viewPortHandler.contentLeft, y: position!.y))
            context.addLine(to: CGPoint(x: viewPortHandler.contentRight, y: position!.y))
            context.strokePath()
            
            // 绘制标签及其背景
            let label = limitLine.label
            if !label.isEmpty, limitLine.drawLabelEnabled {
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: limitLine.valueFont,
                    .foregroundColor: limitLine.valueTextColor
                ]
                let labelSize = label.size(withAttributes: attributes)
                let labelX = labelSize.width + 8
                let labelY = position!.y - labelSize.height / 2

                let backgroundRect = CGRect(
                    x: labelX - 8, // 8 为左右内边距
                    y: labelY - 4, // 4 为上下内边距
                    width: labelSize.width + 16,
                    height: labelSize.height + 8
                )
                
                // 创建带圆角的背景矩形
                let cornerRadius = backgroundRect.height / 2
                let path = UIBezierPath(roundedRect: backgroundRect, cornerRadius: cornerRadius)
                                
                
                context.setFillColor(UIColor.blue.cgColor) // 背景颜色
                context.addPath(path.cgPath)
                context.fillPath()

                label.draw(
                    in: CGRect(x: labelX, y: labelY, width: labelSize.width, height: labelSize.height),
                    withAttributes: attributes
                )
            }
        }
    }
}

