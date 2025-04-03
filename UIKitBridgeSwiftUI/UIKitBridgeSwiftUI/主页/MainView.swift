//
//  MainView.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import SwiftUI

struct MainView: View {
    
    // 定义导航回调，将由UIKit控制器设置
    var onNavigateToDetail: (() -> Void)?
    
    init() {
        print("KpengS 初始化了")
    }
    
    /**
     @ObservedObject：
     适用于对象由父视图或其他外部来源提供的情况。
     例如，一个共享的 ViewModel 在多个视图之间传递时，使用 @ObservedObject。
     典型场景：父视图创建 ViewModel 并将其注入子视图。
     @StateObject：
     适用于对象由当前视图拥有并管理的情况。
     例如，一个视图需要一个专属的 ViewModel 来管理其状态时，使用 @StateObject。
     典型场景：视图内部需要一个独立的、可持久化的数据模型。
     */
//    @StateObject var viewModel = MainViewModel()
    @ObservedObject var viewModel = MainViewModel()

    func reloadData() {
        print("调用方法了")
        viewModel.reloadData()
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 标题部分
            Text("用户信息页面")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding(.top, 30)
            
            // 内容区域
            Group {
                if viewModel.isLoading {
                    // 加载中状态显示
                    loadingView
                } else if let errorMessage = viewModel.errorMessage {
                    // 错误状态显示
                    errorView(message: errorMessage)
                } else if let user = viewModel.userInfo {
                    // 数据加载成功状态
                    userInfoView(user: user)
                } else {
                    // 初始状态
                    Text("请点击下方按钮加载用户数据")
                        .foregroundColor(.gray)
                }
            }
            .frame(height: 200)
            
            // 操作按钮
            Button(action: {
                viewModel.getUserData()
            }) {
                Text(viewModel.userInfo == nil ? "加载数据" : "刷新数据")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 12)
                    .padding(.horizontal, 30)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .padding(.top, 20)
            .disabled(viewModel.isLoading) // 加载中时禁用按钮
            
            Spacer()
            
            Button(action:{
                // 调用导航回调函数
                onNavigateToDetail?()
            }) {
                Text("跳转详情")
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 20)
                    .background(Color.green)
                    .cornerRadius(8)
            }
            .padding(.bottom, 20)
        }
        .padding()
        // 当视图首次出现时自动加载数据
        .onAppear {
            print("KpengS onAppear")
            // 如果数据为空，则加载数据
            if viewModel.userInfo == nil && !viewModel.isLoading {
                viewModel.getUserData()
            }
        }
    }
    
    // MARK: - 子视图组件
    
    // 加载中视图
    private var loadingView: some View {
        VStack {
            Text("正在加载用户数据...")
                .foregroundColor(.gray)
            ProgressView()
                .scaleEffect(1.5)
                .padding(.top, 10)
        }
    }
    
    // 错误视图
    private func errorView(message: String) -> some View {
        VStack(spacing: 15) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 40))
                .foregroundColor(.orange)
            
            Text(message)
                .foregroundColor(.red)
                .multilineTextAlignment(.center)
            
            Button("重试") {
                viewModel.getUserData()
            }
            .foregroundColor(.blue)
        }
    }
    
    // 用户信息视图
    private func userInfoView(user: UserModel) -> some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
                
                VStack(alignment: .leading) {
                    Text("用户名: \(String(describing: user.name))")
                        .font(.title2)
                    
                    Text("年龄: \(String(describing: user.age))")
                        .font(.title3)
                        .foregroundColor(.gray)
                }
            }
            .padding()
            
            Text("用户ID: \(user.id)")
                .font(.caption)
                .foregroundColor(.gray)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    MainView()
}
