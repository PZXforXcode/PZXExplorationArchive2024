//
//  WaterfallFlowLayout.swift
//  PZX瀑布流
//
//  Created by 彭祖鑫 on 2024/10/17.
//

import UIKit


class WaterfallFlowLayout: UICollectionViewFlowLayout {
    
    var columnCount = 2   // 列数，可以根据需求自定义
    var cellPadding: CGFloat = 8 // Cell 之间的间距
    var dataSource: [String] = [] // 数据源，存储每个 Cell 的文本内容
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    private var contentHeight: CGFloat = 0
    
    override func prepare() {
        guard cache.isEmpty, let collectionView = collectionView else { return }
        
        // 根据列数和 cellPadding 动态计算每个 column 的宽度
        let columnWidth = (collectionView.bounds.width - (CGFloat(columnCount + 1) * cellPadding)) / CGFloat(columnCount)
        var xOffset: [CGFloat] = []
        for column in 0..<columnCount {
            xOffset.append(CGFloat(column) * columnWidth + CGFloat(column + 1) * cellPadding)
        }
        
        var column = 0
        var yOffset: [CGFloat] = Array(repeating: 0, count: columnCount)
        
        for item in 0..<dataSource.count { // 遍历数据源
            let indexPath = IndexPath(item: item, section: 0)
            
            let width = columnWidth
            
            // 创建一个 UILabel 用于计算文本高度
            let label = UILabel()
            label.text = dataSource[item]
            label.numberOfLines = 0 // 允许多行
            
            // 设置 preferredMaxLayoutWidth 为 label 的最大宽度
            label.preferredMaxLayoutWidth = width - cellPadding * 2
            
            // 动态计算 UILabel 的文本高度，并根据宽度适配性调整
            let size = CGSize(width: width - cellPadding * 2 , height: .greatestFiniteMagnitude)
            let labelHeight = label.sizeThatFits(size).height
            
            // 计算 Cell 高度：包括上下的 cellPadding（label 高度 + 上下 padding）
            let cellHeight = labelHeight + cellPadding * 2
            
            // 设置每个 Cell 的 frame
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: width, height: cellHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            // 更新 contentHeight 并且 yOffset 也要考虑 Cell 的高度和 Cell 之间的间距
            contentHeight = max(contentHeight, frame.maxY)
            yOffset[column] = yOffset[column] + cellHeight + cellPadding
            
            column = column < (columnCount - 1) ? (column + 1) : 0
        }
    }


    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: collectionView?.bounds.width ?? 0, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return cache.filter { $0.frame.intersects(rect) }
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
}
