//
//  RadarChartView.swift
//  六芒星雷达图
//
//  Created by 彭祖鑫 on 2024/11/28.
//

import UIKit

class RadarChartView: UIView {
    
    // 数据：每个顶点的值
    var values: [CGFloat] = [50, 70, 90, 60, 80, 65] // 示例数据
    var maxValue: CGFloat = 100.0
    
    // 标签文字数据
    var labels: [String] = ["得分", "篮板", "助攻", "抢断", "盖帽", "罚球"]
    
    // 绘制雷达图
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let context = UIGraphicsGetCurrentContext()
        context?.setLineWidth(2)
        
        let center = CGPoint(x: rect.width / 2, y: rect.height / 2) // 雷达图中心
        let radius = min(rect.width, rect.height) / 2 - 30 // 外层六边形的半径
        let angles: [CGFloat] = [0, CGFloat.pi / 3, 2 * CGFloat.pi / 3, CGFloat.pi, 4 * CGFloat.pi / 3, 5 * CGFloat.pi / 3] // 六个角度
        
        // 绘制填充的雷达图区域
        context?.setStrokeColor(UIColor.blue.cgColor)
        context?.setFillColor(UIColor.blue.withAlphaComponent(0.2).cgColor)
        
        var points: [CGPoint] = []
        
        // 计算每个点的坐标
        for i in 0..<6 {
            let angle = angles[i]
            let value = values[i]
            let x = center.x + cos(angle) * (radius * value / maxValue)
            let y = center.y + sin(angle) * (radius * value / maxValue)
            points.append(CGPoint(x: x, y: y))
        }
        
        // 绘制填充多边形
        context?.beginPath()
        context?.move(to: points[0])
        for point in points.dropFirst() {
            context?.addLine(to: point)
        }
        context?.closePath()
        context?.fillPath()
        
        // 绘制外层六边形边框
        context?.setStrokeColor(UIColor.black.cgColor)
        context?.beginPath()
        for i in 0..<6 {
            let angle = angles[i]
            let x = center.x + cos(angle) * radius
            let y = center.y + sin(angle) * radius
            if i == 0 {
                context?.move(to: CGPoint(x: x, y: y))
            } else {
                context?.addLine(to: CGPoint(x: x, y: y))
            }
        }
        context?.closePath()
        context?.strokePath()
        
        // 绘制内层的六边形网格
        let gridLevels: [CGFloat] = [0.7, 0.4] // 内层的两个网格（例如，0.7和0.4表示60%和30%的半径比例）
        for level in gridLevels {
            let innerRadius = radius * level
            context?.setStrokeColor(UIColor.lightGray.cgColor)
            context?.beginPath()
            for i in 0..<6 {
                let angle = angles[i]
                let x = center.x + cos(angle) * innerRadius
                let y = center.y + sin(angle) * innerRadius
                if i == 0 {
                    context?.move(to: CGPoint(x: x, y: y))
                } else {
                    context?.addLine(to: CGPoint(x: x, y: y))
                }
            }
            context?.closePath()
            context?.strokePath()
        }
        
        // 绘制每个值的标记
        for (i, value) in values.enumerated() {
            let angle = angles[i]
            let x = center.x + cos(angle) * (radius * value / maxValue)
            let y = center.y + sin(angle) * (radius * value / maxValue)
            let label = "\(Int(value))"
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 12)]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: x - size.width / 2, y: y - size.height / 2), withAttributes: attributes)
        }
        
        // 绘制六个轴线
        for angle in angles {
            let endPoint = CGPoint(x: center.x + cos(angle) * radius, y: center.y + sin(angle) * radius)
            context?.move(to: center)
            context?.addLine(to: endPoint)
            context?.strokePath()
        }
        
        // 绘制每个角的标签文字
        for (i, label) in labels.enumerated() {
            let angle = angles[i]
            let labelRadius = radius + 15 // 标签的偏移量（略微远离六边形的边缘）
            let x = center.x + cos(angle) * labelRadius
            let y = center.y + sin(angle) * labelRadius
            
            // 绘制标签文字
            let attributes: [NSAttributedString.Key: Any] = [.foregroundColor: UIColor.black, .font: UIFont.systemFont(ofSize: 14)]
            let size = label.size(withAttributes: attributes)
            label.draw(at: CGPoint(x: x - size.width / 2, y: y - size.height / 2), withAttributes: attributes)
        }
    }
}
