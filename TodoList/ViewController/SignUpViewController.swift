//
//  SignUpViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 18/6/24.
//

import Foundation
import UIKit
import ProgressHUD

class SignUpViewController : UIViewController{
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var repeatPasswordLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var reSendEmailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setupTextField()
        setupBackgroundTap()
    }
    
    @IBAction func registerButtonPressed(_ sender: Any) {
        if passwordTextField.text! == repeatPasswordTextField.text! {
            
            FirebaseUserListener.shared.registerUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
                
                if error == nil {
                    ProgressHUD.succeed("Verification email sent.")
                    self.reSendEmailButton.isHidden = false
                } else {
                    ProgressHUD.failed(error!.localizedDescription)
                }
            }
            
        } else {
            ProgressHUD.failed("The Passwords don't match")
        }
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView") as! LoginViewController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true,completion: nil)
    }
    
    @IBAction func resendEmailButtonPressed(_ sender: Any) {
        if emailTextField.text == "" {
            ProgressHUD.failed("Email is required")
            return
        }
        FirebaseUserListener.shared.resendVerificationEmail(email: emailTextField.text!) {
            (error) in
            if error == nil {
                ProgressHUD.success("New verification email sent.")
            }else{
                ProgressHUD.error(error?.localizedDescription)
            }
        }
        
    }
    
    private func setupTextField(){
        emailTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
        repeatPasswordTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFielDidChange(_ textField: UITextField){
        updatePlaceholderTextField(textField : textField)
    }
    
    private func updatePlaceholderTextField(textField : UITextField){
        switch textField{
        case emailTextField :
            emailLabel.text = textField.hasText ? "Email" : ""
        case passwordTextField:
            passwordLabel.text = textField.hasText ? "Password" : ""
        default:
            repeatPasswordLabel.text = textField.hasText ? "Repeat Password" : ""
        }
    }
    
    private func setupBackgroundTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroudTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroudTap(){
        view.endEditing(false)
    }
}
