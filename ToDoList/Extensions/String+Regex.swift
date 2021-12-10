//
//  String+Regex.swift
//  Rabel
//
//  Created by Ziad on 03/11/2021.
//


import Foundation

extension String {

    var isValidEmail: Bool {
        get {
            let regularExpressionForEmail = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
            let testEmail = NSPredicate(format:"SELF MATCHES %@", regularExpressionForEmail)
            return testEmail.evaluate(with: self)
        }
    }

   var isValidPassword: Bool {
        get {
            return self.count >= 6
        }
    }

    var isValidName: Bool {
        get {
            guard self.count >= 3, self.count < 18 else { return false }
            let regularExpressionForName = "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$"
            let testPassword = NSPredicate(format: "SELF MATCHES %@", regularExpressionForName)
            return testPassword.evaluate(with: self)
        }
    }
    var isValidFirstAndLastName: Bool {
        get {
            guard self.count >= 3, self.count < 18  else { return false }
            let regularExpressionForName = "^(([^ ]?)(^[a-zA-Z].*[a-zA-Z]$)([^ ]?))$"
            let testPassword = NSPredicate(format: "SELF MATCHES %@", regularExpressionForName)
            return testPassword.evaluate(with: self)
        }
    }
    
    var isValidPhone: Bool {
        get {
            let phoneRegex = "^[0-9]{11}$"
            let testPassword = NSPredicate(format:"SELF MATCHES %@", phoneRegex)
            return testPassword.evaluate(with: self)
        }
    }
    var isValidUserName: Bool {
        get {
            guard self.count >= 3, self.count < 18 else { return false }
            let regularExpressionForName =  "\\w{3,18}"
            let testPassword = NSPredicate(format: "SELF MATCHES %@", regularExpressionForName)
            return testPassword.evaluate(with: self)
        }
    }


}
