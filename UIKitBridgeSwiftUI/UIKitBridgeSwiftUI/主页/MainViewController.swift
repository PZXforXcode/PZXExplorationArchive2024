//
//  MainViewController.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import UIKit
import SwiftUI

class MainViewController: SwiftUIViewController<MainView> {
    
    // 存储ViewModel的引用，方便获取数据

    override init(rootView: MainView) {
        super.init(rootView: rootView)
        // 初始化完成后设置回调
        setupNavigationCallback()
         
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 设置导航回调的方法
    private func setupNavigationCallback() {
        
        self.rootView.onNavigateToDetail = { [weak self] in
            self?.navigateToDetailView()
        }
    }
    
    //MARK: - lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置导航标题
        title = "SwiftUI与UIKit桥接示例"
        
        // 添加右上角刷新按钮
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .refresh,
            target: self,
            action: #selector(refreshData)
        )
        

    }
    
    //MARK: - 导航方法
    private func navigateToDetailView() {
        // 创建详情控制器
        let detailVC = DetailViewController(rootView: DetailView())
                // 使用UIKit导航控制器进行跳转
        navigationController?.pushViewController(detailVC, animated: true)
        
        print("跳转到详情页面")
    }
    
    //MARK: - 操作方法
    @objc private func refreshData() {
        rootView.reloadData();
    }
}
