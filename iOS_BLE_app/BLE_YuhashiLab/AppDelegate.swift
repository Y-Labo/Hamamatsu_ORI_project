//
//  AppDelegate.swift
//  BLE_YuhashiLab
//
//  Created by 和田颯太郎 on 2020/12/08.
//  changed by takagi 2021/09/23
//

import UIKit
import Amplify
import AWSAPIPlugin
import AWSCognitoAuthPlugin

@main

class AppDelegate: UIResponder, UIApplicationDelegate {



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        //amplify inisialized
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSAPIPlugin())
            try Amplify.configure()
            print("Amplify configured with API and Auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
        
        ApiClient.signInIfNot(username: "takagi.yohei.16@shizuoka.ac.jp", password: "mysweet32")
        return true
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


}

