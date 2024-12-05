//
//  CustomMarkerView.swift
//  YLWeightLineChart
//
//  Created by 彭祖鑫 on 2024/11/27.
//

import DGCharts

class CustomMarkerView: MarkerView {
    private var label: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    override func offsetForDrawing(atPoint point: CGPoint) -> CGPoint {
        let offsetX = -self.bounds.size.width / 2  // 水平居中
        let offsetY = -self.bounds.size.height - 10  // 在点上方，稍微增加一点偏移（比如10）避免贴紧点
        return CGPoint(x: offsetX, y: offsetY)
    }


    private func setupView() {
        // 设置背景颜色和圆角
        backgroundColor = .blue
        layer.cornerRadius = 5
        clipsToBounds = true
        
        // 添加一个标签用于显示数据
        label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        label.frame = bounds
        label.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(label)
    }

    // 更新显示内容
    override func refreshContent(entry: ChartDataEntry, highlight: Highlight) {
        if let weight = entry.y.isNaN ? nil : entry.y {
            label.text = "\(weight) kg"
        } else {
            label.text = "No Data"
        }
        super.refreshContent(entry: entry, highlight: highlight)
    }
}
