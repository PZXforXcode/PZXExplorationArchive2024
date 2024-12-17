//
//  ViewController.swift
//  KeyChainDemo
//
//  Created by 彭祖鑫 on 2024/10/14.
//

import UIKit
import Security

class ViewController: UIViewController {

    let service = "com.example.myapp"
    let account = "userAccount"

    @IBOutlet weak var tf: UITextField!
    
    @IBOutlet weak var saveLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()



        // 读取数据
        if let retrievedData = loadFromKeychain(service: service, account: account),
           let retrievedPassword = String(data: retrievedData, encoding: .utf8) {
            print("Retrieved password: \(retrievedPassword)")
            saveLabel.text = retrievedPassword
        }

    }
    
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        
        // 保存数据
        let password = tf.text ?? ""
        if let passwordData = password.data(using: .utf8) {
            let status = saveToKeychain(service: service, account: account, data: passwordData)
            print("Save status: \(status)")
        }
    }
    
    @IBAction func loadButtonPressed(_ sender: UIButton) {
        
        // 读取数据
        if let retrievedData = loadFromKeychain(service: service, account: account),
           let retrievedPassword = String(data: retrievedData, encoding: .utf8) {
            print("Retrieved password: \(retrievedPassword)")
            saveLabel.text = retrievedPassword
        }
    }
    

    // 保存到 Keychain
    func saveToKeychain(service: String, account: String, data: Data) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]

        SecItemDelete(query as CFDictionary)
        return SecItemAdd(query as CFDictionary, nil)
    }

    // 从 Keychain 读取
    func loadFromKeychain(service: String, account: String) -> Data? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: kCFBooleanTrue!,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess {
            return dataTypeRef as? Data
        } else {
            return nil
        }
    }

    // 删除 Keychain 中的数据
    func deleteFromKeychain(service: String, account: String) -> OSStatus {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]

        return SecItemDelete(query as CFDictionary)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

