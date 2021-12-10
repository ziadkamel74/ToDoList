//
//  SignUpVC.swift
//  Rabel
//
//  Created by Ziad on 06/11/2021.
//

import UIKit
import TextFieldEffects

class SignUpVC: UIViewController {

    // MARK:- Outlets
    @IBOutlet weak var nameTextField: HoshiTextField!
    @IBOutlet weak var nameImage: UIImageView!
    @IBOutlet weak var nameErrorLabel: UILabel!
    @IBOutlet weak var emailTextField: HoshiTextField!
    @IBOutlet weak var emailImage: UIImageView!
    @IBOutlet weak var emailErrorLabel: UILabel!
    @IBOutlet weak var passwordTextField: HoshiTextField!
    @IBOutlet weak var passwordImage: UIImageView!
    @IBOutlet weak var showHidePasswordButton: UIButton!
    @IBOutlet weak var passwordErrorLabel: UILabel!
    @IBOutlet weak var getStartedButton: UIButton!
    @IBOutlet weak var getStartedImage: UIImageView!
    
    // MARK:- LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    // MARK:- Public Methods
    class func create() -> SignUpVC {
        let signUpVC = UIViewController.create(storyboardName: Storyboards.signUp, identifier: VCs.signUp) as! SignUpVC
        return signUpVC
    }
    
    // MARK:- Actions
    @IBAction func showHidePasswordTapped(_ sender: UIButton) {
        sender.isSelected.toggle()
        passwordTextField.isSecureTextEntry.toggle()
    }
    
    @IBAction func getStartedTapped(_ sender: UIButton) {
        view.endEditing(true)
        view.showActivityIndicator()
        FirebaseManager.shared.register(email: emailTextField.text!.trimmed, name: nameTextField.text!.trimmed, password: passwordTextField.text!) { [weak self] success, error in
            self?.view.hideActivityIndicator()
            self?.handleResponse(success, error)
        }
    }
}

// MARK:- Private Methods
extension SignUpVC {
    private func setupViews() {
        title = "Sign Up"
        setupTextFields()
        setupShowHidePasswordButton()
        setupGetStartedButton()
    }
    
    private func setupTextFields() {
        setupTextfield(nameTextField, tag: 1)
        setupTextfield(emailTextField, tag: 2)
        setupTextfield(passwordTextField, tag: 3)
    }
    
    private func setupTextfield(_ textfield: HoshiTextField, tag: Int) {
        textfield.placeholderColor = .systemGray
        textfield.textColor = .systemGray
        textfield.tag = tag
        textfield.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
    }
    
    @objc private func textDidChange(_ sender: HoshiTextField) {
        if sender.tag == 1 {
            validateName(textField: sender)
        } else if sender.tag == 2 {
            validateEmail(textField: sender)
        } else if sender.tag == 3 {
            validatePassword(textField: sender)
        }
        handleGetStartedButton()
    }
    
    private func setupShowHidePasswordButton() {
        showHidePasswordButton.setImage(UIImage(named: "showPassword"), for: .selected)
        showHidePasswordButton.setImage(UIImage(named: "hidePassword"), for: .normal)
    }
    
    private func validateName(textField: HoshiTextField) {
        if let nameError = ValidationManager.shared().isValid(.name(textField.text)) {
            nameErrorLabel.text = nameError
            nameImage.image = UIImage(named: "error")
            textField.placeholderColor = .systemRed
        } else {
            nameErrorLabel.text = nil
            nameImage.image = UIImage(named: "done")
            textField.placeholderColor = .systemGray
        }
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
    
    private func setupGetStartedButton() {
        getStartedButton.layer.cornerRadius = 16
    }
    
    private func handleGetStartedButton() {
        if ValidationManager.shared().isValid(.name(nameTextField.text)) == nil, ValidationManager.shared().isValid(.password(passwordTextField.text)) == nil, ValidationManager.shared().isValid(.email(emailTextField.text)) == nil {
            setGetStartedButtonEnabled(true, alpha: 1)
        } else {
            setGetStartedButtonEnabled(false, alpha: 0.6)
        }
    }
    
    private func setGetStartedButtonEnabled(_ enabled: Bool, alpha: CGFloat) {
        getStartedButton.isEnabled = enabled
        getStartedButton.alpha = alpha
        getStartedImage.alpha = alpha
    }
    
    private func handleResponse(_ success: Bool, _ error: String?) {
        if let error = error {
            showAlert(title: "Sorry", message: error)
        } else if success {
            switchToMainState()
        }
    }
}
