//
//  YLHealthySlider.swift
//  YLHealthySlider
//
//  Created by 彭祖鑫 on 2024/11/26.
//

import UIKit

class YLHealthySlider: UIView {
    
    private let sections: [(range: ClosedRange<Double>, color: UIColor)] = [
        (14...15, .lightGray),
        (15...16, .blue),
        (16...18.5, .cyan),
        (18.5...25, .green),
        (25...30, .yellow),
        (30...35, .orange),
        (35...40, .red),
        (40...41, .lightGray)
    ]
    
    private let sectionHeight: CGFloat = 10 // 区块高度
    private let arrowSize = CGSize(width: 10, height: 10)
    private let padding: CGFloat = 0
    private let spacing: CGFloat = 2 // 色块间距
    
    private var arrowView: UIView!
    private var valueLabel: UILabel!
    private var labels: [UILabel] = [] // 底部关键点标签数组
    
    private let markers: [Double] = [15, 16, 18.5, 25, 30, 35, 40] // 标记点数组
    
    var value: Double = 21.4 {
        didSet {
            updateArrowPosition()
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
        // 添加彩条背景
        backgroundColor = .clear
        
        // 添加箭头视图
        arrowView = UIView()
        arrowView.backgroundColor = .black
        arrowView.layer.cornerRadius = arrowSize.width / 2
        addSubview(arrowView)
        
        // 添加数值标签
        valueLabel = UILabel()
        valueLabel.textAlignment = .center
        valueLabel.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        addSubview(valueLabel)
        
        // 添加底部标记点标签
        for marker in markers {
            let label = UILabel()
            label.text = String(marker)

            label.textAlignment = .center
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .black
            addSubview(label)
            labels.append(label)
        }
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        drawSections(in: rect)
        layoutMarkerLabels(in: rect)
    }
    
    private func drawSections(in rect: CGRect) {
        let totalWidth = rect.width - 2 * padding
        var currentX = padding
        
        for section in sections {
            // 计算每个区块宽度，并减去间距
            let sectionWidth = totalWidth * CGFloat(
                (section.range.upperBound - section.range.lowerBound) / 27.0
            ) - spacing
            
            // 绘制每个区块
            let sectionFrame = CGRect(
                x: currentX,
                y: rect.height / 2 - sectionHeight / 2,
                width: sectionWidth,
                height: sectionHeight
            )
            let path = UIBezierPath(
                roundedRect: sectionFrame,
                cornerRadius: sectionHeight / 2
            )
            
            let color = section.color
            color.setFill()
            path.fill()
            
            // 更新起始位置，加入间距
            currentX += sectionWidth + spacing
        }
    }
    
    private func layoutMarkerLabels(in rect: CGRect) {
        let totalWidth = rect.width - 2 * padding
        
        for (index, marker) in markers.enumerated() {
            // 找到每个标记点的相对位置
            let progress = CGFloat((marker - 14) / 27.0)
            let positionX = totalWidth * progress + padding
            
            // 布局标记点标签
            if index < labels.count {
                let label = labels[index]
                label.frame = CGRect(
                    x: positionX - 15,
                    y: rect.height / 2 + sectionHeight + 8,
                    width: 30,
                    height: 12
                )
//                label.text = String(format: "%.1f", marker)
                if marker.truncatingRemainder(dividingBy: 1) == 0 {
                    // 转换为整数后显示
                    label.text = String(format: "%d", Int(marker))
                } else {
                    // 显示一位小数
                    label.text = String(format: "%.1f", marker)
                }
            }
        }
    }
    
    private func updateArrowPosition() {
        guard value >= 14, value <= 41 else { return }
        
        let totalWidth = bounds.width - 2 * padding
        var currentX = padding
        var position: CGFloat = padding
        
        for section in sections {
            // 计算每个区块宽度，并减去间距
            let sectionWidth = totalWidth * CGFloat(
                (section.range.upperBound - section.range.lowerBound) / 27.0
            ) - spacing
            
            if section.range.contains(value) {
                let progress = CGFloat(
                    (value - section.range.lowerBound) / (
                        section.range.upperBound - section.range.lowerBound
                    )
                )
                position = currentX + sectionWidth * progress
                break
            }
            currentX += sectionWidth + spacing
        }
        
        // 更新箭头位置
        arrowView.frame = CGRect(
            x: position - arrowSize.width / 2,
            y: bounds.height / 2 - arrowSize.height - 5,
            width: arrowSize.width,
            height: arrowSize.height
        )
        arrowView.layer.cornerRadius = arrowSize.width / 2
        
        // 更新数值标签位置和文本
        valueLabel.frame = CGRect(
            x: position - 25,
            y: arrowView.frame.minY - 20,
            width: 50,
            height: 15
        )
        valueLabel.text = String(format: "%.1f", value)
    }
}
