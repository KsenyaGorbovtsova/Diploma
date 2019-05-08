//
//  SignUpController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 24/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit


class SignUp: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    @IBOutlet weak var confirmPswdTextField: UITextField!
    let spinner = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let sub = Gradient()
        view.layer.insertSublayer(sub.setGradient(view: self.view), at: 0)
        self.firstNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.secondNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.emailTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.pswdTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.confirmPswdTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
           self.signUpButton.layer.cornerRadius = 5
        self.title = "Регистрация"
        
    }
    @IBOutlet weak var signUpButton: UIButton!
    
    /*@IBAction func cancelRegistration(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }*/
    @IBAction func signUpButton(_ sender: Any) {
        if (self.firstNameTextField.text?.isEmpty)! || (self.secondNameTextField.text?.isEmpty)! || (self.emailTextField.text?.isEmpty)! || (self.pswdTextField.text?.isEmpty)!
        {
            self.DisplayWarnining(warning: "Fill in all the fields", title: "Warning", dismissing: false)
            return
        }
        if (self.pswdTextField.text?.elementsEqual(self.confirmPswdTextField.text!))! != true
        {
            self.DisplayWarnining(warning: "Passwords are not equal", title: "Warning", dismissing: false)
            self.confirmPswdTextField.text = ""
            self.pswdTextField.text = ""
            return
        }
        
        
        self.spinner.color = UIColor.green
        self.spinner.center = view.center
        self.spinner.hidesWhenStopped = false
        self.spinner.startAnimating()
        view.addSubview(self.spinner)
        let user = self.prepareUser(firstName: self.firstNameTextField.text!, secondName: self.secondNameTextField.text!, email: self.emailTextField.text!, password: self.pswdTextField.text!)
        
        self.postNewUser(user: user)
    }
    
    func stopSpinner(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            self.spinner.stopAnimating()
            self.spinner.removeFromSuperview()
        }
    }
    
    func DisplayWarnining (warning: String, title: String, dismissing: Bool) -> Void {
        DispatchQueue.main.async {
            let warningController = UIAlertController(title: title, message: warning, preferredStyle: .alert)
            
            let buttonAction = UIAlertAction(title: "Got it!", style: .default)
            { (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    warningController.dismiss(animated: true, completion: nil)
                    if dismissing == true {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            warningController.addAction(buttonAction)
            self.present(warningController, animated: true, completion: nil)
        }
        
    }
    
    private func prepareUser (firstName: String, secondName: String, email: String, password: String) -> User {
        let newUser = User(email: email, password: password, firstName: firstName, secondName: secondName)
        return newUser
    }
    
    private func postNewUser(user: User) {
        let params = ["firstName": user.firstName, "secondName": user.secondName, "email": user.email, "password": user.password]
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            self.DisplayWarnining(warning: "Ooops! Error on our side. Try again, please :)", title: "Warning", dismissing: false)
            print (error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            self.stopSpinner(spinner: self.spinner)
            guard error == nil else {
                
                return
            }
            guard let data = data else {
                return
            }
            do {
                
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                    if let error = json["error"] {
                    if error as! Bool == true {
                        self.DisplayWarnining(warning: "User already exist", title: "Warning", dismissing: false )
                        self.emailTextField.text = ""
                        self.confirmPswdTextField.text = ""
                        self.pswdTextField.text = ""
                        }
                    }
                    else {
                        self.DisplayWarnining(warning: "Successful registration", title: "Congrats" + "🎉", dismissing: true)
                    }
                }
                
            } catch let error {
                self.DisplayWarnining(warning: "Try again, please", title: "Warning", dismissing: false)
                print(error.localizedDescription)
            }
        })
        
        task.resume()
    }
    
}
