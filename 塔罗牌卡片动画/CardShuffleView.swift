import UIKit

class CardShuffleView: UIView {
    
    // 存储所有牌的视图
    var cards: [UIView] = []
    
    // 牌堆的中心点
    let cardDeckCenter = CGPoint(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY)
    
    // 牌展开时的半径范围
    let spreadRadius: CGFloat = 150
    
    // 牌的数量
    let numberOfCards = 50
    
    // 卡牌堆叠时的 y 轴偏移量
    let cardYOffset: CGFloat = 1
    
    // 用于控制动画的状态
    private var isShuffling = true
    
    // 初始化
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupCards()
        startSpreadAnimation()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCards()
        startSpreadAnimation()
    }
    
    // 设置牌的初始状态
    func setupCards() {
        for i in 0..<numberOfCards {
            let card = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 80))
            card.backgroundColor = UIColor.red
            // 初始位置在牌堆的中心，y轴堆叠效果
            let yOffset = cardDeckCenter.y + CGFloat(i) * cardYOffset
            card.center = CGPoint(x: cardDeckCenter.x, y: yOffset)
            card.layer.cornerRadius = 8
            card.layer.borderWidth = 0.5
            card.layer.borderColor = UIColor.black.cgColor
            cards.append(card)
            self.addSubview(card)
        }
    }
    
    // 展开动画
    func startSpreadAnimation() {
        UIView.animate(withDuration: 0.3, animations: { // 动画时长 0.3 秒
            for card in self.cards {
                // 控制50%的卡牌旋转角度在 90° 到 180° 或 -90° 到 -180°，剩下的在 -30° 到 30°
                let useLargeAngle = arc4random_uniform(100) < 50
                let angle: CGFloat
                if useLargeAngle {
                    // 90° 到 180° 或 -90° 到 -180°
                    angle = arc4random_uniform(2) == 0 ? CGFloat(arc4random_uniform(90)) + 90 : -(CGFloat(arc4random_uniform(90)) + 90)
                } else {
                    // -30° 到 30°
                    angle = CGFloat(arc4random_uniform(60)) - 30
                }
                card.transform = CGAffineTransform(rotationAngle: angle * .pi / 180)
                
                // 随机位置，保持在半径范围内
                let randomX = CGFloat(arc4random_uniform(UInt32(self.spreadRadius * 2))) - self.spreadRadius
                let randomY = CGFloat(arc4random_uniform(UInt32(self.spreadRadius * 2))) - self.spreadRadius
                card.center = CGPoint(x: self.cardDeckCenter.x + randomX, y: self.cardDeckCenter.y + randomY)
            }
        }) { _ in
            self.startShuffleAnimation()  // 展开动画完成后开始洗牌动画
        }
    }
    
    // 洗牌动画
    func startShuffleAnimation() {
        isShuffling = true // 设置为正在洗牌
        for card in cards {
            animateCard(card)
        }
    }
    
    // 对单张牌进行动画
    func animateCard(_ card: UIView) {
        guard isShuffling else { return } // 检查是否在洗牌中
        
        // 加快洗牌动画时间
        let randomDuration = TimeInterval(arc4random_uniform(3) + 1) / 2 // 0.5 到 2 秒之间

        UIView.animate(withDuration: randomDuration, delay: 0, options: [.curveEaseInOut, .allowUserInteraction], animations: {
            // 每张牌的新随机位置，保持在半径范围内
            let randomX = CGFloat(arc4random_uniform(UInt32(self.spreadRadius * 2))) - self.spreadRadius
            let randomY = CGFloat(arc4random_uniform(UInt32(self.spreadRadius * 2))) - self.spreadRadius
            card.center = CGPoint(x: self.cardDeckCenter.x + randomX, y: self.cardDeckCenter.y + randomY)

            // 控制50%的卡牌旋转角度在 90° 到 180° 或 -90° 到 -180°，剩下的在 -30° 到 30°
            let useLargeAngle = arc4random_uniform(100) < 50
            let angle: CGFloat
            if useLargeAngle {
                // 90° 到 180° 或 -90° 到 -180°
                angle = arc4random_uniform(2) == 0 ? CGFloat(arc4random_uniform(90)) + 90 : -(CGFloat(arc4random_uniform(90)) + 90)
            } else {
                // -30° 到 30°
                angle = CGFloat(arc4random_uniform(60)) - 30
            }
            card.transform = CGAffineTransform(rotationAngle: angle * .pi / 180)
        }) { _ in
            // 动画完成后递归调用，继续动画
            self.animateCard(card)
        }
    }
    
    // 收回动画
    func startCollectAnimation() {
        isShuffling = false // 停止洗牌动画
        
        // 获取每张牌的当前状态（通过 presentationLayer）
        for card in self.cards {
            if let presentationLayer = card.layer.presentation() {
                // 获取当前的 center 和 transform
                let currentCenter = presentationLayer.position
                let currentTransform = presentationLayer.transform
                
                // 停止当前动画，并锁定当前状态
                card.layer.removeAllAnimations()
                
                // 将牌的位置和变换设置为其 presentationLayer 的当前值
                card.center = currentCenter
                card.layer.transform = currentTransform
            }
        }
        
        // 开始从当前位置平滑靠拢到中心并堆叠
        UIView.animate(withDuration: 0.5, animations: {
            for (i, card) in self.cards.enumerated() {
                let yOffset = self.cardDeckCenter.y + CGFloat(i) * self.cardYOffset
                card.center = CGPoint(x: self.cardDeckCenter.x, y: yOffset) // 堆叠效果
                card.transform = CGAffineTransform.identity // 角度恢复为初始值
            }
        })
    }
    
    // 处理点击事件
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        startCollectAnimation()  // 用户点击后，开始收回动画
    }
}
