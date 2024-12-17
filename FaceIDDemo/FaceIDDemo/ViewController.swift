//
//  ViewController.swift
//  FaceIDDemo
//
//  Created by 彭祖鑫 on 2024/10/14.
//

import LocalAuthentication
import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // 调用生物识别验证
        authenticateWithBiometrics()
    }

    @IBAction func buttonPressed(_ sender: Any) {
        authenticateWithBiometrics()

    }
    func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        // 检查设备是否支持生物识别或密码验证
//               if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error)
                    
        ///deviceOwnerAuthentication 如果生物识别不行会弹出密码验证
        ///deviceOwnerAuthenticationWithBiometrics 如果生物识别不行不会弹出密码验证
        // 检查设备是否支持生物识别
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {

            // 获取支持的生物识别类型
            let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"

            // 进行生物识别验证
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: "使用 \(biometricType) 进行身份验证") { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // 验证成功，处理成功逻辑
                        self.showAlert(message: "\(biometricType) 验证成功")
                    } else {
                        // 验证失败，处理失败逻辑
                        let errorMessage = authenticationError?.localizedDescription ?? "未知错误"
                        self.showAlert(message: "\(biometricType) 验证失败: \(errorMessage)")
                    }
                }
            }
        } else {
            // 设备不支持生物识别，显示错误信息
            let errorMessage = error?.localizedDescription ?? "设备不支持生物识别"
            showAlert(message: errorMessage)
        }
    }

    // 显示提示框
    func showAlert(message: String) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}


