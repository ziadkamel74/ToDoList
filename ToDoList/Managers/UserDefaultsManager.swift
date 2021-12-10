//
//  UserDefaultsManager.swift
//  Rabel
//
//  Created by Ziad on 06/11/2021.
//

import Foundation

class UserDefaultsManager {
    
    // MARK:- Singleton
    static let shared = UserDefaultsManager()
    private init() {}
    
    // MARK:- Properties
    var token: String? {
        set {
            UserDefaults.standard.setValue(newValue, forKey: "token")
        } get {
            return UserDefaults.standard.string(forKey: "token")
        }
    }
}
