//
//  CustomCollectionViewCell.swift
//  PZX瀑布流
//
//  Created by 彭祖鑫 on 2024/10/17.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(label)
        // 设置 Auto Layout 约束
//        NSLayoutConstraint.activate([
//            label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
//            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 0),
//            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: 0),
//            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: 0)
//        ])
           NSLayoutConstraint.activate([
               label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
               label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
               label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
               label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
           ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


