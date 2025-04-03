//
//  UserModel.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import Foundation

// 用户数据模型
struct UserModel: Identifiable, Equatable, Codable {
    let id = UUID() // 自动生成唯一标识符
    let name: String
    let age: Int
    
    // 其他可选属性可以根据需要添加
    // let avatar: String?
    // let email: String?
    // let phoneNumber: String?
} 