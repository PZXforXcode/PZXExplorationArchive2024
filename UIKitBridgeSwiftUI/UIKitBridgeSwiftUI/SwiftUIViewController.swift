//
//  SwiftUIViewController.swift
//  UIKitBridgeSwiftUI
//
//  Created by 彭祖鑫 on 2025/4/3.
//

import UIKit
import SwiftUI

open class SwiftUIViewController<Content: View>: UIViewController{
    
     var rootView: Content
    
    public init(rootView: Content) {
        self.rootView = rootView
        super.init(nibName: nil, bundle: nil)
    }
    
    @MainActor required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    @MainActor required public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
//        fatalError("init(nibName:bundle:) has not been implemented")
//    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        
        let hostingController = UIHostingController(rootView: rootView)
        addChild(hostingController)
        view.addSubview(hostingController.view)
        view.backgroundColor = .white
        hostingController.didMove(toParent: self)
        
        // 设置原生 Auto Layout 约束
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

}
