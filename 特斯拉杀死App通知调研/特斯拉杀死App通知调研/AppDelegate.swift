//
//  AppDelegate.swift
//  特斯拉杀死App通知调研
//
//  Created by 彭祖鑫 on 2024/12/17.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate,UNUserNotificationCenterDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        UIApplication.shared.registerForRemoteNotifications()
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    //在应用内展示通知
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                           willPresent notification: UNNotification,
                           withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void)
        {
            completionHandler([.banner, .sound])

            // 如果不想显示某个通知，可以直接用空 options 调用 completionHandler:
            // completionHandler([])
        }
    //对通知进行响应，收到通知响应时的处理工作，用户与你推送的通知进行交互时被调用；
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    
    func scheduleAppKilledNotification() {
        let content = UNMutableNotificationContent()
        content.title = "保持App应用运行"
        content.body = "以获得最佳手机钥匙使用体验"
        content.sound = UNNotificationSound.default

        // 设置通知触发时间，比如 1 秒后
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "AppKilledReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("通知注册失败: \(error.localizedDescription)")
            } else {
                print("App 被杀死前已注册通知")
            }
        }
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        print("applicationWillResignActive")

    }
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("applicationDidEnterBackground")
        scheduleAppKilledNotification()
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        print("applicationWillTerminate")

        scheduleAppKilledNotification()
    }


}

