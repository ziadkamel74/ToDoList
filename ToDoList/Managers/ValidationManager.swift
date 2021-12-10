
import Foundation

//MARK:- Enum
enum ValidationError {
    case email(_ email: String?)
    case password(_ password: String?)
    case name(_ name: String?)
    case title(_ title: String?)

    var emptyField: Bool {
        switch self {
        case .email(let text), .password(let text), .name(let text), .title(let text):
            guard let trimmedText = text?.trimmed else { return false }
            return !trimmedText.isEmpty
        }
    }
    
    var validate: Bool {
        switch self {
        case .email(let email):
            return email!.trimmed.isValidEmail
        case .password(let password):
            return password!.isValidPassword
        case .name(let name):
            return name!.trimmed.count > 2
        case .title(let title):
            return title!.trimmed.count > 0
        }
    }
    
    var errorMessage: (emptyMessage: String, invalidMessage: String) {
        switch self {
        case .email:
            return ("email field is empty", "email should be: example@mail.com")
        case .password:
            return ("password field is empty", "password must be at least 6 characters")
        case .name:
            return ("name field is empty", "name must be at least 3 characters")
        case .title:
            return ("title field is empty", "title should be at least 1 character")
        }
    }
}

class ValidationManager {
    
    // MARK:- Singleton
    private static let sharedInstance = ValidationManager()
    
    //MARK:- Public Methods
    class func shared() -> ValidationManager {
        return ValidationManager.sharedInstance
    }
    
    func isValid(_ validationType: ValidationError) -> String? {
        if !validationType.emptyField {
            return validationType.errorMessage.emptyMessage
        }
        
        if !validationType.validate {
            return validationType.errorMessage.invalidMessage
        }
        return nil
    }
}
