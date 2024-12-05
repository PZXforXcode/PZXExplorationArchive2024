//
//  ShareViewController.swift
//  share
//
//  Created by 彭祖鑫 on 2024/11/12.
//

import UIKit
import Social

class ShareViewController: SLComposeServiceViewController {
    
    var customShareView = CustomShareView()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .red
        
        // 移除自带的文本输入框
        self.textView.removeFromSuperview()
           
        customShareView = CustomShareView(frame: self.view.bounds)
        customShareView.translatesAutoresizingMaskIntoConstraints = false
        customShareView.shareButtonAction = {
            self.performCustomShare()
        }
        customShareView.cancelButtonAction = {
            self.extensionContext!.cancelRequest(withError: NSError(
                domain: "CustomShare",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "用户取消分享"]
            ))
        }
        self.view.addSubview(customShareView)
        
        // 修改约束设置
        NSLayoutConstraint.activate(
[
            customShareView.leadingAnchor
                .constraint(
                    equalTo: self.view.safeAreaLayoutGuide.leadingAnchor
                ),
            customShareView.trailingAnchor
                .constraint(
                    equalTo: self.view.safeAreaLayoutGuide.trailingAnchor
                ),
            customShareView.topAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor),
            customShareView.bottomAnchor
                .constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor)
]
        )
        
    }
    
    private func performCustomShare() {
        // 执行自定义分享逻辑
        print("执行自定义分享操作")
        
        
        if let items = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in items {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        if attachment
                            .hasItemConformingToTypeIdentifier("public.url") {
                            // 处理URL类型
                            attachment
                                .loadItem(forTypeIdentifier: "public.url", options: nil) { (
                                    url,
                                    error
                                ) in
                                    if let shareURL = url as? URL {
                                        print("分享的URL: \(shareURL)")
                                        // 这里处理获取到的URL
                                        DispatchQueue.main.async {
                                            self.customShareView.shareContent = shareURL.absoluteString
                                        }
                                        
                                        self.openMainApp(shareURL.absoluteString)

                                    }
                                }
                        } else if attachment.hasItemConformingToTypeIdentifier(
                            "public.text"
                        ) {
                            // 处理文本类型
                            attachment
                                .loadItem(forTypeIdentifier: "public.text", options: nil) { (
                                    text,
                                    error
                                ) in
                                    if let shareText = text as? String {
                                        print("分享的文本: \(shareText)")
                                        // 这里处理获取到的文本
                                    }
                                }
                        }
                    }
                }
            }
        }
        
        self.extensionContext!
            .completeRequest(returningItems: [], completionHandler: nil)
    }
    
    
    private func openMainApp(_ url: String) {
        var responder: UIResponder? = self
        while responder != nil {
            if let application = responder as? UIApplication {
                let encodedURL = url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let fullURL = "PZXShare://PZXShare.com?url=\(encodedURL ?? "")"
                if let url = URL(string: fullURL) {
                    application.open(url)
                }
            }
            responder = responder?.next
        }
    }

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }

    
    
    
    
    
    override func didSelectPost() {
        print("进入了 didSelectPost")
        // 获取所有输入项
        if let items = extensionContext?.inputItems as? [NSExtensionItem] {
            for item in items {
                if let attachments = item.attachments {
                    for attachment in attachments {
                        if attachment
                            .hasItemConformingToTypeIdentifier("public.url") {
                            // 处理URL类型
                            attachment
                                .loadItem(forTypeIdentifier: "public.url", options: nil) { (
                                    url,
                                    error
                                ) in
                                    if let shareURL = url as? URL {
                                        print("分享的URL: \(shareURL)")
                                        // 这里处理获取到的URL
                                    }
                                }
                        } else if attachment.hasItemConformingToTypeIdentifier(
                            "public.text"
                        ) {
                            // 处理文本类型
                            attachment
                                .loadItem(forTypeIdentifier: "public.text", options: nil) { (
                                    text,
                                    error
                                ) in
                                    if let shareText = text as? String {
                                        print("分享的文本: \(shareText)")
                                        // 这里处理获取到的文本
                                    }
                                }
                        }
                    }
                }
            }
        }
        
        // 处理完成后关闭分享扩展
//        self.extensionContext?
//            .completeRequest(returningItems: [], completionHandler: nil)
    }

    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }

}
