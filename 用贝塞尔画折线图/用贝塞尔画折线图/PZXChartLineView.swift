//
//  PZXChartLineView.swift
//  用贝塞尔画折线图
//
//  Created by 彭祖鑫 on 2024/11/29.
//

import UIKit

// 自定义的折线图视图，继承自 UIView
class PZXChartLineView: UIView {
    
    // 折线图中的数据点，存储每个点的 Y 值
    var points: [CGFloat] = []
    
    // 折线图中对应的数据点的标签
    var labels: [String] = []
    
    // 随机生成的模拟数据
    private var randomValues: [CGFloat] = []
    
    // 用于实现滑动功能的 UIScrollView
    private var scrollView: UIScrollView!
    
    // 放置折线图内容的 UIView，作为 scrollView 的子视图
    private var chartView: UIView!
    
    // 图表与边界的间距（用于上下左右留白）
    private var padding: CGFloat = 30
    
    // 两个点之间的水平间距
    private var pointSpacing: CGFloat = 50
    
    // Y 轴的最小值
    private var yAxisMin: CGFloat = 0
    
    // Y 轴的最大值
    private var yAxisMax: CGFloat = 500

    // 初始化方法，设置背景色并调用数据和视图初始化方法
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        setupData()        // 初始化数据
        setupScrollView()  // 初始化滑动视图
    }
    
    // 使用 NSCoder 初始化（当从 Interface Builder 加载时会调用）
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupData()
        setupScrollView()
    }
    
    // 初始化图表数据
    private func setupData() {
        // 生成 10 个随机值，范围在 50 到 200 之间
        randomValues = (0..<10).map { _ in CGFloat.random(in: 50...200) }
        
        // 将随机值赋值到 points 数组，作为 Y 轴数据
        points = randomValues
        
        // 根据随机值生成对应的标签，格式为 "Y = 值"
        labels = randomValues.map { "Y = \(Int($0))" }
        
        // 设置 Y 轴的最小值和最大值
        yAxisMin = 0       // 固定为 0
        yAxisMax = 300     // 固定为 300
    }
    
    // 初始化 UIScrollView（用于支持横向滚动）
    private func setupScrollView() {
        // 创建滑动视图，尺寸与整个视图相同
        scrollView = UIScrollView(frame: self.bounds)
        
        // 设置滑动区域的宽度（根据点的数量动态计算）
        scrollView.contentSize = CGSize(
            width: CGFloat(points.count - 1) * pointSpacing + 2 * padding,
            height: self.bounds.height
        )
        
        // 启用水平滚动
        scrollView.isScrollEnabled = true
        
        // 隐藏水平和垂直滚动条
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        
        // 将滑动视图添加到当前视图中
        self.addSubview(scrollView)
        
        // 创建用于放置折线图的视图，宽度为当前视图的两倍，避免内容超出显示范围
        chartView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.width * 2, height: self.bounds.height))
        
        // 将 chartView 添加到 scrollView 中
        scrollView.addSubview(chartView)
    }
    
    // 绘制折线图（包括 Y 轴、X 轴、折线、点及其标签）
    private func drawLineChart() {
        // 移除 chartView 中的所有图层，避免重复绘制
        chartView.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // 绘制 Y 轴
        drawYAxis()
        
        // 绘制 X 轴
        drawXAxis()
        
        // 计算图表的有效高度（去掉上下 padding 的部分）
        let height = chartView.bounds.height - 2 * padding
        
        // 创建贝塞尔路径，用于绘制折线
        let path = UIBezierPath()
        path.lineWidth = 2
        path.lineJoinStyle = .round   // 设置折线连接处为圆角
        path.lineCapStyle = .round    // 设置折线终点为圆角
        
        // 设置折线的起点（根据第一个点的 Y 值计算位置）
        path.move(to: CGPoint(
            x: padding,
            y: height - (points[0] - yAxisMin) / (yAxisMax - yAxisMin) * height + padding
        ))
        
        // 遍历 points 数组，从第二个点开始绘制折线
        for i in 1..<points.count {
            let xPosition = CGFloat(i) * pointSpacing + padding // 计算当前点的 X 坐标
            let yPosition = height - (points[i] - yAxisMin) / (yAxisMax - yAxisMin) * height + padding // 计算 Y 坐标
            path.addLine(to: CGPoint(x: xPosition, y: yPosition)) // 添加一段直线到路径中
        }
        
        // 创建 CAShapeLayer，用于显示折线
        let lineLayer = CAShapeLayer()
        lineLayer.path = path.cgPath         // 设置折线的路径
        lineLayer.strokeColor = UIColor.blue.cgColor // 折线颜色为蓝色
        lineLayer.fillColor = UIColor.clear.cgColor  // 填充颜色为空
        chartView.layer.addSublayer(lineLayer)       // 将折线图层添加到 chartView
        
        // 创建填充渐变层，绘制折线下方的渐变区域
        let fillLayer = createFillLayer(path: path, bounds: chartView.bounds)
        chartView.layer.addSublayer(fillLayer)

        // 遍历每个数据点，绘制圆点和标签
        for i in 0..<points.count {
            let xPosition = CGFloat(i) * pointSpacing + padding
            let yPosition = height - (points[i] - yAxisMin) / (yAxisMax - yAxisMin) * height + padding
            
            // 绘制红色圆点
            let pointLayer = CALayer()
            pointLayer.frame = CGRect(x: xPosition - 3, y: yPosition - 3, width: 6, height: 6)
            pointLayer.cornerRadius = 3
            pointLayer.backgroundColor = UIColor.red.cgColor
            chartView.layer.addSublayer(pointLayer)
            
            // 绘制对应的标签
            let label = UILabel()
            label.text = labels[i]
            label.font = UIFont.systemFont(ofSize: 10)
            label.textColor = .red
            label.sizeToFit()
            label.frame.origin = CGPoint(x: xPosition - label.bounds.width / 2, y: yPosition + 5)
            chartView.addSubview(label)
        }
    }

    // 创建渐变填充区域
    private func createFillLayer(path: UIBezierPath, bounds: CGRect) -> CAGradientLayer {
        // 获取最后一个点的 X 位置，确保渐变路径完全覆盖折线区域
        let lastXPosition = CGFloat(points.count - 1) * pointSpacing + padding
        
        // 创建一个闭合路径，包括折线下方到 X 轴的区域
        let fillPath = UIBezierPath(cgPath: path.cgPath) // 使用折线路径初始化填充路径
        fillPath.addLine(to: CGPoint(x: lastXPosition, y: bounds.height - padding)) // 将路径延伸到最后的 X 轴位置
        fillPath.addLine(to: CGPoint(x: padding, y: bounds.height - padding)) // 从最后 X 轴位置延伸到左下角
        fillPath.close() // 闭合路径，形成一个多边形
        
        // 创建一个图层作为填充区域
        let fillLayer = CAShapeLayer()
        fillLayer.path = fillPath.cgPath // 使用闭合路径作为填充图层的形状
        fillLayer.fillColor = UIColor.white.cgColor // 设置填充颜色（这里作为渐变的 mask 使用）
        
        // 创建一个渐变图层，颜色从蓝色到透明
        let fillGradientLayer = CAGradientLayer()
        fillGradientLayer.frame = bounds // 渐变图层大小与视图范围一致
        fillGradientLayer.colors = [
            UIColor.blue.withAlphaComponent(0.5).cgColor, // 渐变开始：蓝色，带透明度
            UIColor.clear.cgColor // 渐变结束：完全透明
        ]
        fillGradientLayer.startPoint = CGPoint(x: 0, y: 0)  // 渐变的起点（顶部）
        fillGradientLayer.endPoint = CGPoint(x: 0, y: 1)    // 渐变的终点（底部）
        
        // 使用填充路径作为渐变图层的遮罩，只显示折线下方的渐变部分
        fillGradientLayer.mask = fillLayer
        return fillGradientLayer
    }
    
    // 绘制 Y 轴和对应的刻度
    private func drawYAxis() {
        // 创建 Y 轴路径
        let yAxisPath = UIBezierPath()
        yAxisPath.move(to: CGPoint(x: padding, y: padding)) // 从顶部开始
        yAxisPath.addLine(to: CGPoint(x: padding, y: chartView.bounds.height - padding)) // 延伸到底部
        
        // 用路径绘制一条直线作为 Y 轴
        let yAxisLayer = CAShapeLayer()
        yAxisLayer.path = yAxisPath.cgPath // 将路径赋值给图层
        yAxisLayer.strokeColor = UIColor.black.cgColor // 设置 Y 轴的颜色
        yAxisLayer.lineWidth = 2 // 设置线宽
        chartView.layer.addSublayer(yAxisLayer) // 将 Y 轴图层添加到 chartView 中
        
        // 绘制 Y 轴上的刻度标签和网格线
        let count = 7 // 刻度数量
        for i in 0..<count {
            // 计算每个刻度的位置
            let yPosition = CGFloat(i) * (chartView.bounds.height - 2 * padding) / CGFloat(count - 1) + padding
            
            // 创建刻度标签，表示数值
            let label = UILabel()
            label.text = "\(Int(CGFloat(count - 1 - i) * (yAxisMax - yAxisMin) / CGFloat(count - 1) + yAxisMin))" // 从最大值到最小值递减
            label.font = UIFont.systemFont(ofSize: 10) // 设置字体大小
            label.textColor = .black // 设置字体颜色
            label.sizeToFit() // 自动调整标签大小
            label.frame.origin = CGPoint(x: padding - label.bounds.width - 5, y: yPosition - label.bounds.height / 2) // 设置标签位置
            chartView.addSubview(label) // 将标签添加到 chartView
            
            // 绘制刻度对应的横向网格线（虚线）
            let gridPath = UIBezierPath()
            let lastXPosition = CGFloat(points.count - 1) * pointSpacing + padding // X 轴的最远点
            gridPath.move(to: CGPoint(x: padding, y: yPosition)) // 从 Y 轴开始
            gridPath.addLine(to: CGPoint(x: lastXPosition, y: yPosition)) // 延伸到最远点
            
            let gridLayer = CAShapeLayer()
            gridLayer.path = gridPath.cgPath // 将路径赋值给图层
            gridLayer.strokeColor = UIColor.gray.cgColor // 设置虚线颜色
            gridLayer.lineWidth = 1 // 设置线宽
            gridLayer.lineDashPattern = [4, 4] // 设置虚线样式（长度为4，间距为4）
//            chartView.layer.addSublayer(gridLayer) // 添加虚线网格到 chartView（可取消注释显示）
        }
    }

    // 绘制 X 轴和对应的刻度
    private func drawXAxis() {
        // 创建 X 轴路径
        let xAxisPath = UIBezierPath()
        xAxisPath.move(to: CGPoint(x: padding, y: chartView.bounds.height - padding)) // 起点在左下角
        let lastXPosition = CGFloat(points.count - 1) * pointSpacing + padding // X 轴终点
        xAxisPath.addLine(to: CGPoint(x: lastXPosition, y: chartView.bounds.height - padding)) // 延伸到右下角
        
        // 用路径绘制一条直线作为 X 轴
        let xAxisLayer = CAShapeLayer()
        xAxisLayer.path = xAxisPath.cgPath // 将路径赋值给图层
        xAxisLayer.strokeColor = UIColor.black.cgColor // 设置 X 轴的颜色
        xAxisLayer.lineWidth = 2 // 设置线宽
        chartView.layer.addSublayer(xAxisLayer) // 将 X 轴图层添加到 chartView 中
        
        // 绘制 X 轴上的刻度标签
        for i in 0..<points.count {
            let xPosition = CGFloat(i) * pointSpacing + padding // 每个刻度的 X 位置
            let label = UILabel()
            label.text = "\(i + 1)" // 标签内容为对应点的索引值（从 1 开始）
            label.font = UIFont.systemFont(ofSize: 10) // 设置字体大小
            label.textColor = .black // 设置字体颜色
            label.sizeToFit() // 自动调整标签大小
            label.frame.origin = CGPoint(x: xPosition - label.bounds.width / 2, y: chartView.bounds.height - padding + 5) // 设置标签位置
            chartView.addSubview(label) // 将标签添加到 chartView
            
            // 绘制竖直网格线
            let gridPath = UIBezierPath()
            let yPositionForGridLine = getYPositionForGridLine(at: i) // 根据折线动态计算网格线的终点 Y 位置 让Y轴线不超过折线 如果要Y轴线都是从顶到底可修改
            gridPath.move(to: CGPoint(x: xPosition, y: padding)) // 起点在顶部
            gridPath.addLine(to: CGPoint(x: xPosition, y: yPositionForGridLine)) // 终点位置
            
            let gridLayer = CAShapeLayer()
            gridLayer.path = gridPath.cgPath // 将路径赋值给图层
            gridLayer.strokeColor = UIColor.gray.cgColor // 设置网格线颜色
            gridLayer.lineWidth = 1 // 设置线宽
            gridLayer.lineDashPattern = [4, 4] // 设置虚线样式
            chartView.layer.addSublayer(gridLayer) // 添加网格线图层到 chartView
        }
    }
    
    // 获取网格线的 Y 坐标位置，确保它不会超过折线下方
    private func getYPositionForGridLine(at index: Int) -> CGFloat {
        let height = chartView.bounds.height - 2 * padding
        
        // 获取折线对应点的 Y 坐标
        let yPosition = height - (points[index] - yAxisMin) / (yAxisMax - yAxisMin) * height + padding
        
        // 返回根据折线动态调整的 Y 坐标
        return yPosition
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        drawLineChart() // 在布局更新时重新绘制折线图
    }
}
