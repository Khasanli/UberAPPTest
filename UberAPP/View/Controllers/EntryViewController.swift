//
//  EntryViewController.swift
//  UberAPP
//
//  Created by Samir Hasanli on 18.06.21.
//

import UIKit

class EntryViewController: UIViewController {
    
//MARK:-OBJECTS
    let logo : UIImageView = {
        let image = UIImageView()
        image.image = UIImage(named: "frontal-taxi-cab-1")
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let userButton : UIButton = {
        let button  = UIButton()
        button.setTitle("Join as user", for: .normal)
        button.addTarget(self, action: #selector(userButtonTapped), for: .touchUpInside)
        button.layer.borderWidth = 2
        button.layer.borderColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        button.setTitleColor(#colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1), for: .normal)
        button.backgroundColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    let driverButton : UIButton = {
        let button  = UIButton()
        button.setTitle("Join as driver", for: .normal)
        button.addTarget(self, action: #selector(driverButtonTapped), for: .touchUpInside)
        button.backgroundColor = #colorLiteral(red: 0.5568627715, green: 0.3529411852, blue: 0.9686274529, alpha: 1)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
//MARK:-LYFECYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(logo)
        view.addSubview(userButton)
        view.addSubview(driverButton)
        setSubviews()

    }
//MARK:-SET SUBVIEWS
    private func setSubviews(){
        logo.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logo.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        logo.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        logo.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1/3).isActive = true
        
        userButton.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: view.frame.size.height/16).isActive = true
        userButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        userButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        userButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
        
        driverButton.topAnchor.constraint(equalTo: userButton.bottomAnchor, constant: view.frame.size.height/32).isActive = true
        driverButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        driverButton.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 2/3).isActive = true
        driverButton.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1/16).isActive = true
    }
//MARK:-FUNCTIONS
    @objc private func userButtonTapped(){
        let vc = UserViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }
    @objc private func driverButtonTapped(){
        let vc = DriverViewController()
        vc.modalPresentationStyle = .fullScreen
        present(vc, animated: true)
    }


}
