//
//  ViewController.swift
//  YLWeightLineChart
//
//  Created by 彭祖鑫 on 2024/11/27.
//

import UIKit
import DGCharts

class ViewController: UIViewController {
    var lineChartView: LineChartView!
    var limitLineView: UIView!
    var dataSet = LineChartDataSet()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        // 初始化折线图
        lineChartView = LineChartView()
        lineChartView.frame = CGRect(
            x: 10,
            y: 100,
            width: view.frame.width - 20,
            height: 300
        )
        view.addSubview(lineChartView)

        // 设置数据
        setChartData()
        let marker = CustomMarkerView(
            frame: CGRect(x: 0, y: 0, width: 80, height: 40)
        )
        marker.chartView = lineChartView
        lineChartView.marker = marker // 关联 MarkerView
        // 默认选中 31号的数据（56.5）
        highlightData()




    }
    
    

    func setChartData() {
        // 固定的日期范围（X轴坐标）
        let dates = ["27", "28", "29", "30", "31", "1", "2"]
        
        // 对应的体重数据，注意29号和2号没有数据
        let weights = [
            Double.nan,
            60.0,
            Double.nan,
            56.0,
            56.5,
            58.0,
            Double.nan
        ] // 29号和2号没有数据，所以为 NaN

        // 创建数据点
        var entries: [ChartDataEntry] = []
        for (index, weight) in weights.enumerated() {
            // 如果weight为NaN，则跳过
            if weight.isNaN {
                continue
            }
            entries.append(ChartDataEntry(x: Double(index), y: weight))
        }

        // 创建数据集
        dataSet = LineChartDataSet(entries: entries, label: "")
        dataSet.colors = [.blue]               // 折线颜色
        dataSet.circleColors = [.blue,.clear]         // 圆点颜色
        dataSet.circleRadius = 4.0             // 圆点半径
        dataSet.lineWidth = 2.0                // 折线宽度
        dataSet.drawValuesEnabled = false      // 不显示每个点的数值标签
        dataSet.drawFilledEnabled = true       // 启用填充
        dataSet.drawCirclesEnabled = true      // 启用圆点显示（圆点仅显示有数据的日期）
        // 渐变填充
        let gradientColors = [
            UIColor.blue.cgColor,
            UIColor.blue.cgColor,
            UIColor.clear.cgColor
        ] // 渐变颜色：蓝色到透明
        let gradient = CGGradient(
            colorsSpace: nil,
            colors: gradientColors as CFArray,
            locations: nil
        )
        dataSet.fill = LinearGradientFill(gradient: gradient!, angle: -90.0)

        // 设置数据
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
        lineChartView.legend.enabled = false

        // 禁用滑动和缩放
        lineChartView.dragEnabled = false  // 禁用拖动
        lineChartView.setScaleEnabled(false)  // 禁用缩放
        lineChartView.pinchZoomEnabled = false // 禁用双指缩放
        lineChartView.doubleTapToZoomEnabled = false // 禁用双击缩放
        // 自定义 X 轴
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(
            values: dates
        )
        lineChartView.xAxis.axisMinimum = 0
        lineChartView.xAxis.axisMaximum = 6
        lineChartView.xAxis.labelCount = 5
        lineChartView.xAxis.granularity = 1
        lineChartView.xAxis.labelPosition = .bottom
        lineChartView.xAxis.drawGridLinesEnabled = true    // 保留竖线
    
        // 自定义 Y 轴
        lineChartView.leftAxis.axisMinimum = 50.0
        lineChartView.leftAxis.axisMaximum = 70.0
        lineChartView.leftAxis.labelCount = 5
        lineChartView.rightAxis.enabled = false
        //        lineChartView.renderer = customRenderer

        // 隐藏横线网格
        lineChartView.leftAxis.drawGridLinesEnabled = false // 隐藏横线
        lineChartView.rightAxis.drawGridLinesEnabled = false // 隐藏横线
        //        lineChartView.highlightPerTapEnabled = false
        dataSet.drawHorizontalHighlightIndicatorEnabled = false // 禁用横向高亮线
        dataSet.drawVerticalHighlightIndicatorEnabled = false   // 禁用竖向高亮线
        

        // 在 Y 轴的 56 位置添加一条虚线
        let limitLine = ChartLimitLine(limit: 56.0, label: "56 kg")  // 位置和标签
        limitLine.lineColor = .blue                          // 设置虚线颜色
        limitLine.lineWidth = 1.5                           // 线宽
        limitLine.lineDashLengths = [5.0, 5.0]              // 设置虚线样式
        limitLine.labelPosition = .leftTop                 // 标签位置
        limitLine.valueFont = UIFont.systemFont(ofSize: 12)  // 设置标签字体
        limitLine.valueTextColor = .white                    // 设置标签文字颜色
        // 将限值线添加到 Y 轴
        lineChartView.leftAxis.addLimitLine(limitLine)
        
        //自定义Renderer
        let customRenderer = CustomYAxisRenderer(
            viewPortHandler: lineChartView.viewPortHandler,
            axis: lineChartView.leftAxis,
            transformer: lineChartView.getTransformer(forAxis: .left)
        )
        lineChartView.leftYAxisRenderer = customRenderer
    }

    func highlightData() {
        // 确定要高亮的点在数据集中的索引
        let indexToHighlight = 4 // 对应 31 号数据点（56.5）在 weights 数组中的索引
        
        // 创建 Highlight 对象
        let highlight = Highlight(
            x: Double(indexToHighlight),
            y: 56.5,
            dataSetIndex: 0
        )
        
        // 触发高亮
        lineChartView.highlightValue(highlight)
    }


}

