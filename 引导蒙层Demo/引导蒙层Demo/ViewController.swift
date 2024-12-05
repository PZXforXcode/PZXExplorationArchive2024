//
//  ViewController.swift
//  引导蒙层Demo
//
//  Created by 彭祖鑫 on 2024/9/20.
//

import UIKit

class ViewController: UIViewController {

    // 创建蒙层视图
    let overlayView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 添加一个按钮，作为需要高亮的控件
        let highlightButton = UIButton(frame: CGRect(x: 100, y: 300, width: 200, height: 50))
        highlightButton.setTitle("需要高亮的按钮", for: .normal)
        highlightButton.backgroundColor = .systemBlue
        highlightButton.layer.cornerRadius = 10
        view.addSubview(highlightButton)
        
        // 添加引导蒙层
        setupGuideOverlay(for: highlightButton)
    }
    
    func setupGuideOverlay(for targetView: UIView) {
        // 设置蒙层大小
        overlayView.frame = view.bounds
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        view.addSubview(overlayView)
        
        // 创建一个用于裁剪的路径
        let path = UIBezierPath(rect: overlayView.bounds)
        
        // 获取控件的相对于屏幕的frame
        let targetFrame = targetView.convert(targetView.bounds, to: view)
        
        // 在蒙层上裁剪出目标控件的区域（圆形或矩形）
        let highlightPath = UIBezierPath(roundedRect: targetFrame, cornerRadius: 10)
        path.append(highlightPath)
        path.usesEvenOddFillRule = true
        
        // 创建一个shapeLayer来应用裁剪路径
        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        maskLayer.fillRule = .evenOdd
        
        // 把裁剪的图层添加到蒙层上
        overlayView.layer.mask = maskLayer
        
        // 添加点击事件，点击后移除蒙层
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissOverlay))
        overlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissOverlay() {
        // 移除蒙层
        overlayView.removeFromSuperview()
    }

}

