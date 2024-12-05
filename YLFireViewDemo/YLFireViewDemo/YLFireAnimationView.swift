//
//  YLFireAnimationView.swift
//  YLFireViewDemo
//
//  Created by 彭祖鑫 on 2024/11/27.
//

import UIKit

import UIKit

class YLFireAnimationView: UIView {
    
    // 粒子发射器：火焰和烟雾的发射器
    private var fireEmitter: CAEmitterLayer!  // 火焰的发射器
    private var smokeEmitter: CAEmitterLayer! // 烟雾的发射器
    
    // 初始化方法，设置视图并初始化粒子效果
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFireAndSmoke()  // 设置火焰和烟雾效果
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupFireAndSmoke()  // 设置火焰和烟雾效果
    }
    
    // 设置火焰和烟雾的粒子效果
    private func setupFireAndSmoke() {
        self.backgroundColor = .black  // 设置背景颜色为黑色，模拟夜晚或者火焰的环境
        
        // 配置火焰粒子
        let fire = CAEmitterCell()  // 创建一个火焰粒子
        fire.name = "fire"  // 火焰粒子的名称
        fire.birthRate = 100  // 火焰粒子的出生率，即每秒产生的粒子数
        fire.lifetime = 50  // 火焰粒子的生命周期，单位是秒
        fire.lifetimeRange = 50 * 0.35  // 生命周期的范围，粒子的生命周期可以有波动
        fire.emissionLongitude = .pi  // 火焰的发射方向，.pi 表示向左
        fire.emissionRange = 0.5  // 火焰发射角度的范围，1.1 使得火焰稍微散开
        fire.velocity = -90  // 火焰粒子的速度，负值表示向上
        fire.yAcceleration = -200  // 火焰粒子的垂直加速度，使其向上加速
        fire.scaleSpeed = 0.3  // 火焰粒子缩放的速度，0.3 表示每秒粒子逐渐变小
        fire.color = UIColor(
            red: 0.8,
            green: 0.4,
            blue: 0.2,
            alpha: 0.1
        ).cgColor  // 火焰粒子的颜色，设置为橙色，透明度较低
        fire.contents = UIImage(named: "DazFire")?.cgImage  // 设置火焰的图像为自定义图片
        
        // 配置烟雾粒子
        let smoke = CAEmitterCell()  // 创建一个烟雾粒子
        smoke.name = "smoke"  // 烟雾粒子的名称
        smoke.birthRate = 11  // 烟雾粒子的出生率，每秒产生11个
        smoke.emissionLongitude = -CGFloat.pi / 2  // 烟雾的发射方向，-π/2 表示向右
        smoke.emissionRange = .pi / 4  // 烟雾的发射角度范围，π/4 使烟雾略微扩散
        smoke.lifetime = 10  // 烟雾粒子的生命周期，单位秒
        smoke.velocity = -40  // 烟雾粒子的初始速度，向上
        smoke.velocityRange = 20  // 烟雾速度的范围，增加变化
        smoke.spin = 1  // 烟雾粒子的旋转速度
        smoke.spinRange = 6  // 烟雾旋转的范围，使其旋转不规则
        smoke.yAcceleration = -160  // 烟雾粒子的垂直加速度，向上
        smoke.contents = UIImage(named: "DazSmoke")?.cgImage  // 设置烟雾的图像为自定义图片
        smoke.scale = 0.1  // 烟雾粒子的初始大小
        smoke.alphaSpeed = -0.12  // 烟雾粒子的透明度变化速度，负值使其逐渐消失
        smoke.scaleSpeed = 0.7  // 烟雾粒子的缩放速度，逐渐变大
        
        // 设置火焰发射器
        fireEmitter = CAEmitterLayer()  // 创建火焰的发射器
        fireEmitter.emitterPosition = CGPoint(
            x: bounds.midX,
            y: bounds.maxY
        )  // 设置火焰发射器的起始位置，位于视图底部中央
        fireEmitter.emitterSize = CGSize(
            width: bounds.width / 2,
            height: 0
        )  // 设置发射区域的大小，宽度为视图的一半，高度为0
        fireEmitter.emitterMode = .outline  // 火焰发射器的模式为outline，表示沿着边界发射
        fireEmitter.emitterShape = .line  // 发射器的形状为线，表示发射沿着一条线
        fireEmitter.renderMode = .additive  // 渲染模式为叠加，使火焰的效果更强
        fireEmitter.emitterCells = [fire]  // 将火焰粒子添加到发射器中
        
        // 设置烟雾发射器
        smokeEmitter = CAEmitterLayer()  // 创建烟雾的发射器
        smokeEmitter.emitterPosition = CGPoint(
            x: bounds.midX,
            y: bounds.maxY
        )  // 设置烟雾发射器的起始位置，位于视图底部中央
        smokeEmitter.emitterMode = .points  // 烟雾发射器的模式为points，表示每次发射一个粒子
        smokeEmitter.emitterCells = [smoke]  // 将烟雾粒子添加到发射器中
        
        // 将火焰和烟雾发射器添加到视图的图层
        layer.addSublayer(smokeEmitter)  // 将烟雾发射器添加为子图层
        layer.addSublayer(fireEmitter)   // 将火焰发射器添加为子图层
        
        // 初始化火焰强度为较低值
        setFireAmount(0.3)
    }
    
    // 设置火焰的强度
    private func setFireAmount(_ zeorToOne: Float) {
        // 设置火焰的出生率
        fireEmitter
            .setValue(
                NSNumber(value: 300),
                forKeyPath: "emitterCells.fire.birthRate"
            )  // 固定设置为300
        // 设置火焰的生命周期
        fireEmitter
            .setValue(
                NSNumber(value: zeorToOne),
                forKeyPath: "emitterCells.fire.lifetime"
            )
        // 设置火焰生命周期的变化范围
        fireEmitter
            .setValue(
                NSNumber(value: zeorToOne * 0.35),
                forKeyPath: "emitterCells.fire.lifetimeRange"
            )
        // 设置发射区域的宽度，按照强度调整
        fireEmitter.emitterSize = CGSize(
            width: 50 * CGFloat(zeorToOne),
            height: 0
        )
        
        // 设置烟雾的生命周期
        smokeEmitter
            .setValue(
                NSNumber(value: zeorToOne * 4),
                forKeyPath: "emitterCells.smoke.lifetime"
            )
        // 设置烟雾的颜色，透明度与火焰强度相关
        smokeEmitter
            .setValue(
                UIColor.white
                    .withAlphaComponent(CGFloat(zeorToOne * 0.3)).cgColor,
                forKeyPath: "emitterCells.smoke.color"
            )
    }
    
    // 触摸控制火焰的高度
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        controlFireHeight(event)  // 触摸开始时调整火焰高度
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        controlFireHeight(event)  // 触摸移动时调整火焰高度
    }
    
    // 控制火焰的高度
    private func controlFireHeight(_ event: UIEvent?) {
        guard let touches = event?.allTouches?.first else { return }  // 获取触摸事件
        let touchLocation = touches.location(in: self)  // 获取触摸点的位置
        
        // 计算触摸点到视图底部的距离，并将其转换为百分比
        let distanceToBottom = bounds.height - touchLocation.y
        var percentage = distanceToBottom / bounds.height
        percentage = max(min(percentage, 1.0), 0.1)  // 确保百分比在0.1到1.0之间
        
        // 调整火焰强度
        setFireAmount(Float(0.4))
    }
}
