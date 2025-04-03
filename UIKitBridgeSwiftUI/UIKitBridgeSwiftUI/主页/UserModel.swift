//
//  UserModel.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import UIKit

class UserModel: Codable {
    var id = UUID() // 添加唯一标识符
    var name : String?
    var age  : Int?
    
    init(name: String? = nil, age: Int? = nil) {
        self.name = name
        self.age = age
    }

}
