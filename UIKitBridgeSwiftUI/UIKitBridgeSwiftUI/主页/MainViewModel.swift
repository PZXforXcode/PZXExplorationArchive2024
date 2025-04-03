//
//  MainModel.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import SwiftUI
import Combine

// MVVM架构中的ViewModel
class MainViewModel: ObservableObject {
    
    // @Published 属性包装器使得属性变化时自动通知UI更新
    // 当userInfo发生变化时，所有引用该属性的视图都会刷新
    @Published var userInfo: UserModel?
    
    // 是否正在加载数据
    @Published var isLoading: Bool = false
    
    // 错误信息
    @Published var errorMessage: String?
    
    // 可以被取消的订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // 初始化ViewModel
        print("MainViewModel 已初始化")
    }
    
    // 获取用户数据的方法
    func getUserData() {
        print("开始获取用户数据")
        
        // 标记为加载中状态
        self.isLoading = true
        self.errorMessage = nil
        
        // 模拟网络请求获取用户数据
        // 在实际应用中，这里应该是真实的网络请求，如使用URLSession或Alamofire
        
        // 模拟网络延迟
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // 模拟成功获取数据
            if Bool.random() { // 80%概率成功获取数据
                self.userInfo = UserModel(name: "KpengS", age: 18)
                print("用户数据获取成功: \(self.userInfo?.name ?? "未知")")
            } else {
                // 模拟请求失败情况
                self.errorMessage = "网络请求失败，请稍后重试"
                print("用户数据获取失败")
            }
            
            // 请求完成，结束加载状态
            self.isLoading = false
        }
    }
    
    // 重新加载数据
    func reloadData() {
        // 清空当前数据
        self.userInfo = nil
        // 重新请求
        getUserData()
    }
}
