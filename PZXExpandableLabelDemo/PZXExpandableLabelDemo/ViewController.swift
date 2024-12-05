//
//  ViewController.swift
//  PZXExpandableLabelDemo
//
//  Created by 彭祖鑫 on 2024/10/16.
//


import UIKit
import SnapKit
class ViewController: UIViewController {
    
    var label = UILabel()
    var isFold = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        view.backgroundColor = .cyan
        view.addSubview(label)
        
        // Set constraints for the label
        label.snp.makeConstraints { make in
            make.left.equalToSuperview().offset(20)
            make.center.equalToSuperview()
            make.right.equalToSuperview().offset(-20)
        }
        //        label.backgroundColor = .orange
        label.rz.colorfulConfer { (confer) in
            confer.paragraphStyle?.lineSpacing(10).paragraphSpacingBefore(15)
            
            confer.image(UIImage.init(named: "indexMore"))?.bounds(CGRect.init(x: 0, y: 0, width: 20, height: 20))
            confer.text("  姓名 : ")?.font(UIFont.systemFont(ofSize: 15)).textColor(.gray)
            confer.text("rztime")?.font(UIFont.systemFont(ofSize: 15)).textColor(.black)
            confer.text("超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本超长文本")?.font(UIFont.systemFont(ofSize: 15)).textColor(.black)
            
        }
        
 
    
        
        let attributedString = NSAttributedString.rz.colorfulConfer { confer in
            let text =
            """
            “中国人的饭碗任何时候都要牢牢端在自己手中，饭碗主要装中国粮”“保证粮食安全，大家都有责任，党政同责要真正见效”，习近平总书记强调指出。
            民为国基，谷为民命。粮食问题不仅要算“经济账”，更要算“政治账”；不仅要顾当前，还要看长远。
            \n今年，我国粮食生产喜获丰收，产量保持在1.3万亿斤以上，为开新局、应变局、稳大局发挥重要作用。但也要看到，当前我国粮食需求刚性增长，资源环境约束日益趋紧
            \n粮食增面积、提产量的难度越来越大。全球新冠肺炎疫情持续蔓延，气候变化影响日益加剧，保障粮食供应链稳定难度加大。
            """
            confer.text(text)?.textColor(.black).font(.systemFont(ofSize: 16))
        }
        
        let showAll = NSAttributedString.rz.colorfulConfer { confer in
            confer.text("...全部")?.textColor(.red).font(.systemFont(ofSize: 16)).tapActionByLable("all")
        }
        let showFold = NSAttributedString.rz.colorfulConfer { confer in
            confer.text("...折叠")?.textColor(.red).font(.systemFont(ofSize: 16)).tapActionByLable("fold")
        }
 
      

        label.rz.tapAction { label, tapActionId,range in
            
            print("tapActionId:\(tapActionId)")

            if tapActionId == "all" {
                self.isFold = false
            } else if tapActionId == "fold" {
                self.isFold = true
            }
            self.reload(attributedString, self.isFold, showAll, showFold)

        }
        reload(attributedString, isFold, showAll, showFold)

        
        
    }
    
  

    fileprivate func reload(_ attributedString: NSAttributedString?, _ isFold: Bool, _ showAll: NSAttributedString?, _ showFold: NSAttributedString?) {
        label.rz.set(attributedString: attributedString, maxLine: 4, maxWidth: self.view.frame.size.width - 40, isFold: isFold, showAllText: showAll, showFoldText: showFold)
    }
    
}


