//
//  LoginVC.swift
//  Rabel
//
//  Created by Ziad on 03/11/2021.
//

import UIKit
import TextFieldEffects

class LoginVC: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var showHidePasswordButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var logInImage: UIImageView!
    
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK:- Public Methods
    class func create() -> LoginVC {
        let loginVC = UIViewController.create(storyboardName: Storyboards.login, identifier: VCs.login) as! LoginVC
        return loginVC
    }

    // MARK:- Actions
    @IBAction func showHidePasswordTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func forgotPasswordTapped(_ sender: UIButton) {
        view.endEditing(true)
        let alert = UIAlertController(title: "Your Email", message: "Please enter your email to reset your password", preferredStyle: .alert)
        alert.addTextField { [weak self] textField in
            textField.placeholder = "Email Address"
            if ValidationManager.shared().isValid(.email(self?.emailTextField.text)) == nil {
                textField.text = self?.emailTextField.text
            }
        }
        alert.addAction(UIAlertAction(title: "Send", style: .destructive, handler: { [weak self] _ in
            self?.resetPassword(email: alert.textFields?.first?.text?.trimmed)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    private func resetPassword(email: String?) {
        if let emailError = ValidationManager.shared().isValid(.email(email)) {
            self.showAlert(title: "Sorry", message: emailError)
        } else {
            view.showActivityIndicator()
            FirebaseManager.shared.resetPassword(email: email!) { [weak self] success, error in
                self?.view.hideActivityIndicator()
                if let error = error {
                    self?.showAlert(title: "Sorry", message: error)
                } else if success {
                    self?.showAlert(title: "Done!", message: "Email was sent, please follow the instructions and login again")
                }
            }
        }
    }
    
    @IBAction func signUpTapped(_ sender: UIButton) {
        let signUpVC = SignUpVC.create()
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        view.endEditing(true)
        view.showActivityIndicator()
        FirebaseManager.shared.login(email: emailTextField.text!.trimmed, password: passwordTextField.text!) { [weak self] success, error in
            self?.view.hideActivityIndicator()
            if let error = error {
                self?.showAlert(title: "Sorry", message: error)
            } else if success {
                self?.switchToMainState()
            }
        }
    }
    
}

// MARK:- Private Methods
extension LoginVC {
    private func setupViews() {
        setupNavigationController()
        setupTextFields()
        setupShowHidePasswordButton()
        setupLogInButton()
    }
    
    private func setupNavigationController() {
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Log In"
    }
    
    private func setupTextFields() {
        setupTextfield(emailTextField, tag: 1)
        setupTextfield(passwordTextField, tag: 2)
    }
    
    private func setupTextfield(_ textfield: HoshiTextField, tag: Int) {
        textfield.placeholderColor = .systemGray
        textfield.textColor = .systemGray
        textfield.tag = tag
        textfield.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    private func setupLogInButton() {
        loginButton.layer.cornerRadius = 16
    }
    
    @objc private func textDidChange(_ sender: HoshiTextField) {
        if sender.tag == 1 {
            validateEmail(textField: sender)
        } else if sender.tag == 2 {
            validatePassword(textField: sender)
        }
        handleLoginButton()
    }
    
    private func setupShowHidePasswordButton() {
        showHidePasswordButton.setImage(UIImage(named: "showPassword"), for: .selected)
        showHidePasswordButton.setImage(UIImage(named: "hidePassword"), for: .normal)
    }
    
    private func validateEmail(textField: HoshiTextField) {
        if let emailError = ValidationManager.shared().isValid(.email(textField.text)) {
            emailErrorLabel.text = emailError
            emailImage.image = UIImage(named: "error")
            textField.placeholderColor = .systemRed
        } else {
            emailErrorLabel.text = nil
            emailImage.image = UIImage(named: "done")
            textField.placeholderColor = .systemGray
        }
    }
    
    private func validatePassword(textField: HoshiTextField) {
        if let passwordError = ValidationManager.shared().isValid(.password(textField.text)) {
            passwordErrorLabel.text = passwordError
            passwordImage.image = UIImage(named: "error")
            textField.placeholderColor = .systemRed
        } else {
            passwordErrorLabel.text = nil
            passwordImage.image = UIImage(named: "done")
            textField.placeholderColor = .systemGray
        }
    }
    
    private func handleLoginButton() {
        if ValidationManager.shared().isValid(.password(passwordTextField.text)) == nil, ValidationManager.shared().isValid(.email(emailTextField.text)) == nil {
            setLogInButtonEnabled(true, alpha: 1)
        } else {
            setLogInButtonEnabled(false, alpha: 0.6)
        }
    }
    
    private func setLogInButtonEnabled(_ enabled: Bool, alpha: CGFloat) {
        loginButton.isEnabled = enabled
        loginButton.alpha = alpha
        logInImage.alpha = alpha
    }
}
