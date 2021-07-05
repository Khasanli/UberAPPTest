//
//  DriverRegisterViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 27.06.21.
//

import UIKit

class DriverRegisterViewController: UIViewController {
    var driverVM = DriverViewModel()
    let registerText: UILabel = {
        let text = UILabel()
        text.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        text.text = "Register as Driver"
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

    var nameTextField: UITextField = {
        var field = UITextField()
        field.placeholder = "Username"
        field.layer.borderWidth = 2
        field.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.textColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        field.backgroundColor = .white
        field.leftViewMode = .always
        field.translatesAutoresizingMaskIntoConstraints = false
        return field
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
    
    let registerButton : UIButton = {
        let button  = UIButton()
        button.setTitle("Register", for: .normal)
        button.addTarget(self, action: #selector(registerButtonTapped), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(nameTextField)
        view.addSubview(registerText)
        view.addSubview(phoneNumberField)
        view.addSubview(passworddField)
        view.addSubview(errorText)
        view.addSubview(registerButton)
        errorText.isHidden = true
        setSubviews()
    }
    private func setSubviews() {
        registerText.topAnchor.constraint(equalTo: view.topAnchor, constant: view.frame.size.height/16).isActive = true
        registerText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        registerText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        registerText.font = registerText.font.withSize(view.frame.size.height/32)

        nameTextField.topAnchor.constraint(equalTo: registerText.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        nameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        nameTextField.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        nameTextField.layer.cornerRadius = view.frame.size.width/14
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        
        phoneNumberField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: view.frame.size.height/32).isActive = true
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
        
        registerButton.topAnchor.constraint(equalTo: passworddField.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        registerButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        registerButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        registerButton.layer.cornerRadius = view.frame.size.width/14
        
        errorText.topAnchor.constraint(equalTo: registerButton.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        errorText.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        errorText.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 3/4).isActive = true
        errorText.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        errorText.font = errorText.font.withSize(view.frame.size.height/60)
    }
    
    @objc private func registerButtonTapped(){
        if nameTextField.text?.count ?? 0 < 6 {
            errorText.isHidden = false
            errorText.text = "Name should contain more than 6 characters!"
        } else {
            if passworddField.text?.count ?? 0 < 6 {
                errorText.isHidden = false
                errorText.text = "Password should contain more than 6 characters!"
            } else {
                if phoneNumberField.text?.count ?? 0 != 9 {
                    errorText.isHidden = false
                    errorText.text = "Number is not correct!!"
                } else {
                    if locationAllowed == true {
                        driverVM.registerAsDriver(name: self.nameTextField.text!, phoneNumber: self.phoneNumberField.text!, password: self.passworddField.text!, latitude: 1234567, longitude: 2343777) { user, status in
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
}
