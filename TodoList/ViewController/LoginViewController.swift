//
//  LoginViewController.swift
//  TodoList
//
//  Created by KhoaLA8 on 17/6/24.
//

import Foundation
import UIKit
import ProgressHUD
import FirebaseAuth

class LoginViewController: UIViewController {
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var signUpLabel: UILabel!
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        hideActivityIndicator()
        setupTextField()
        setupBackgroundTap()
    }
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        if isDataInputed(type: "login"){
            showActivityIndicator()
            loginUser()
        }else{
            ProgressHUD.failed("All Fields are required")
        }
    }
    
    @IBAction func forgotPasswordPressed(_ sender: Any) {
        if isDataInputed(type: "password"){
            resetPassword()
        }else{
            ProgressHUD.failed("Email is required")
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: UIButton) {
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "signUpView") as! SignUpViewController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true,completion: nil)
    }
    
    func loginUser(){
        FirebaseUserListener.shared.loginUserWithEmail(email: emailTextField.text!, password: passwordTextField.text!) {error,isEmailVerified in
            self.hideActivityIndicator()
            if error == nil {
                if isEmailVerified {
                    self.gotoAapp()
                    print("login success",User.currentUser?.email)
                }else{
                    ProgressHUD.failed("Please verify email.")
                }
            }
            if let error = error as? NSError, let code = AuthErrorCode.Code(rawValue: error.code){
                if code == AuthErrorCode.networkError {
                    // Handle the case where the device is offline
                    DispatchQueue.main.async {
                        ProgressHUD.failed("The Internet connection is offline, please try again later.")
                    }
                    return
                }
            }
            else{
                ProgressHUD.failed("email or password incorrect")
            }
        }
    }
    
    private func gotoAapp(){
        let mainView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainView") as! UITabBarController
        
        mainView.modalPresentationStyle = .fullScreen
        self.present(mainView, animated: true,completion: nil)
    }
    
    private func resetPassword(){
        FirebaseUserListener.shared.resetPasswordFor(email: emailTextField.text!) {
            (error) in
            if error == nil {
                ProgressHUD.success("Reset link sent to email.")
            }
            if let error = error as? NSError, let code = AuthErrorCode.Code(rawValue: error.code){
                if code == AuthErrorCode.networkError {
                    // Handle the case where the device is offline
                    DispatchQueue.main.async {
                        ProgressHUD.failed("The Internet connection is offline, please try again later.")
                    }
                    return
                }
            }
            else{
                ProgressHUD.error(error?.localizedDescription)
            }
        }
    }
    
    private func setupTextField(){
        emailTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
        passwordTextField.addTarget(self, action: #selector(textFielDidChange(_:)), for: .editingChanged)
    }
    
    @objc func textFielDidChange(_ textField: UITextField){
        updatePlaceholderTextField(textField : textField)
    }
    
    private func updatePlaceholderTextField(textField : UITextField){
        switch textField{
        case emailTextField :
            emailLabel.text = textField.hasText ? "Email" : ""
        default:
            passwordLabel.text = textField.hasText ? "Password" : ""
        }
    }
    
    private func setupBackgroundTap(){
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroudTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func backgroudTap(){
        view.endEditing(false)
    }
    
    
    private func isDataInputed(type: String)-> Bool{
        switch type{
        case"login" :
            return emailTextField.text != "" && passwordTextField.text != ""
            
        default:
            return emailTextField.text != ""
        }
        
    }
    
    func showActivityIndicator() {
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
    }
}
