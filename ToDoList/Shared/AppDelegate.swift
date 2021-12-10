//
//  AppDelegate.swift
//  ToDoList
//
//  Created by Ziad on 20/11/2021.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        checkAuthStatus()
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        if let toDoListNav = window?.rootViewController as? UINavigationController, let toDoListVC = toDoListNav.viewControllers.first as? ToDoListVC {
            toDoListVC.startLocationAnimation()
        }
    }
    
    private func checkAuthStatus() {
        if UserDefaultsManager.shared.token != nil {
            switchToMainState()
        } else {
            switchToAuthState()
        }
    }
    
    func switchToMainState() {
        let toDoListVC = ToDoListVC.create()
        let toDoNav = UINavigationController(rootViewController: toDoListVC)
        window?.rootViewController = toDoNav
    }
    
    func switchToAuthState() {
        let loginVC = LoginVC.create()
        let loginNav = UINavigationController(rootViewController: loginVC)
        window?.rootViewController = loginNav
    }
}

