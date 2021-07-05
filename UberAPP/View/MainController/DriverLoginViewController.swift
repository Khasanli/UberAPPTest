//
//  DriverLoginViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 27.06.21.
//

import UIKit

class DriverLoginViewController: UIViewController {
    var driverVM = DriverViewModel()
    let loginText: UILabel = {
        let text = UILabel()
        text.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        text.text = "Login as Driver"
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    let errorText: UILabel = {
        let text = UILabel()
        text.textColor = .red
        text.text = ""
        text.numberOfLines = 0
        text.textAlignment = .center
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    var phoneNumberField: UITextField = {
        var field = UITextField()
        field.placeholder = "Phone Number"
        field.layer.borderWidth = 2
        field.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.keyboardType = .numberPad
        field.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.backgroundColor = .white
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    var passworddField: UITextField = {
        var field = UITextField()
        field.placeholder = "Password"
        field.layer.borderWidth = 2
        field.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.backgroundColor = .white
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
    }()
    
    let loginButton : UIButton = {
        let button  = UIButton()
        button.setTitle("Login", for: .normal)
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(loginText)
        view.addSubview(phoneNumberField)
        view.addSubview(passworddField)
        view.addSubview(errorText)
        view.addSubview(loginButton)
        errorText.isHidden = true
        setSubviews()
    }
    private func setSubviews() {
        loginText.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.size.height/16).isActive = true
        loginText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        loginText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        loginText.font = loginText.font.withSize(view.frame.size.height/32)

        phoneNumberField.topAnchor.constraint(equalTo: loginText.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        phoneNumberField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        phoneNumberField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        phoneNumberField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        phoneNumberField.layer.cornerRadius = view.frame.size.width/14
        phoneNumberField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        
        passworddField.topAnchor.constraint(equalTo: phoneNumberField.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        passworddField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        passworddField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        passworddField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        passworddField.layer.cornerRadius = view.frame.size.width/14
        passworddField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        
        loginButton.topAnchor.constraint(equalTo: passworddField.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        loginButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        loginButton.layer.cornerRadius = view.frame.size.width/14
        
        errorText.topAnchor.constraint(equalTo: loginButton.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        errorText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        errorText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        errorText.font = errorText.font.withSize(view.frame.size.height/60)
    }
    @objc private func loginButtonTapped(){
            if passworddField.text?.count ?? 0 < 6 {
                errorText.isHidden = false
                errorText.text = "Password should contain more than 6 characters!"
            } else {
                if phoneNumberField.text?.count ?? 0 != 9 {
                    errorText.isHidden = false
                    errorText.text = "Number is not correct!!"
                } else {
                    if locationAllowed == true {
                        driverVM.loginAsDriver(phoneNumber: self.phoneNumberField.text!, password: self.passworddField.text!) { user, status in
                            if status == true {
                                let vc = DriverHomeViewController()
                                vc.modalPresentationStyle = .fullScreen
                                self.present(vc, animated: true)
                            } else {
                                self.errorText.isHidden = false
                                self.errorText.text = "Invalid phone number!!"
                            }
                        }
                    }  else {
                        errorText.isHidden = false
                        errorText.text = "Location is not allowed, please add location!!"
                }
            }
        }
    }
}

