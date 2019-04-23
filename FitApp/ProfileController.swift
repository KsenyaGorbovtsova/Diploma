//
//  ProfileController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 21/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class ProfileController: UIViewController {
    let spinner = UIActivityIndicatorView(style: .gray)
    var firstNameSegue = ""
    var secondNameSegue = ""
    var emailSegue = ""
    var imageSegue = Data()
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var confirmpswdTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    
    @IBOutlet weak var emaiTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var rightButton: UIBarButtonItem!
    
    @IBOutlet weak var newPswdLine: UILabel!
    
    @IBOutlet weak var confirmPswdLine: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    var photoPicker: PhotoPicker!
    @IBOutlet weak var secondNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    var idFriend = ""
    var firstName = ""
    var secondName = ""
    var email = ""
    var image: Data = Data()
    var flagUserOrFriend = false // user - true, friend - false
    
    @IBAction func photoPickerClicked(_ sender: UIButton) {
        self.photoPicker.present(from: sender)
    }
    
    @IBOutlet weak var photoPickerButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.flagUserOrFriend == false {
            self.firstNameLabel.text = self.firstName
            self.secondNameLabel.text = self.secondName
            self.emailLabel.text = self.email
            self.imageView.image = UIImage(data: image)
            self.firstNameTextField.isHidden = true
            self.secondNameTextField.isHidden = true
            self.emaiTextField.isHidden = true
            self.pswdTextField.isHidden = true
            self.confirmpswdTextField.isHidden = true
            self.rightButton.title = "Добавить"
            self.confirmPswdLine.isHidden = true
            self.newPswdLine.isHidden = true
            self.photoPickerButton.isHidden = true
            
        }
        else {
            self.photoPickerButton.isHidden = false
            self.photoPicker = PhotoPicker(presentationController: self, delegate: self)
            if self.imageSegue.count == 0 {
                self.imageSegue = (UIImage(named: "noPhoto")?.pngData())!
            }
            let imageData = Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))
            self.imageView.image = UIImage(data: imageData!)
            self.emailLabel.isHidden = true
            self.firstNameLabel.isHidden = true
            self.secondNameLabel.isHidden = true
            self.firstNameTextField.isHidden = false
            self.firstNameTextField.text = self.firstNameSegue
            self.secondNameTextField.isHidden = false
            self.secondNameTextField.text = self.secondNameSegue
            self.emaiTextField.isHidden = false
            self.emaiTextField.text = self.emailSegue
            self.pswdTextField.isHidden = false
            self.confirmpswdTextField.isHidden = false
            self.rightButton.title = "Сохранить"
        }
    }
    @IBAction func righButtonClicked(_ sender: UIBarButtonItem) {
        if self.flagUserOrFriend == false {
            
        }
        else {
            self.spinner.color = UIColor.green
            self.spinner.center = view.center
            self.spinner.hidesWhenStopped = false
            self.spinner.startAnimating()
            view.addSubview(self.spinner)
            self.updateUserInformation()
        }
    }
    
    @IBAction func doneButton(_ sender: UIBarButtonItem) {
        NotificationCenter.default.post(name: .updateInfo, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    
    private func updateUserInformation() {
        var params = [String:Any]()
        if self.firstNameTextField.text != self.firstNameSegue {
            params["firstName"] = self.firstNameTextField.text
        }
        if self.secondNameTextField.text != self.secondNameSegue {
            params["secondName"] = self.secondNameTextField.text
        }
        if self.emaiTextField.text != self.emailSegue {
            params["email"] = self.emaiTextField.text
        }
        if self.pswdTextField.text != "" && self.confirmpswdTextField.text == self.pswdTextField.text {
            params["password"] = self.pswdTextField.text
        }
        else if self.confirmpswdTextField.text != self.pswdTextField.text {
            self.DisplayWarnining(warning: "Проверьте правильность ввода паролей", title: "Ooops", dismissing: false)
            self.confirmpswdTextField.text = ""
            self.pswdTextField.text = ""
        }
        
        if self.imageView.image?.pngData() != UIImage(data:Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))!)?.pngData()! {
           
            let imageData:NSData = self.imageView.image!.jpegData(compressionQuality: 0.5)! as NSData //UIImagePNGRepresentation(img)
            let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
            params["image"] = imgString
           // print(params["image"])
        }
        if params.count == 0 {
            
            self.stopSpinner(spinner: self.spinner)
            dismiss(animated: true, completion: nil)
            return
        }
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/users/" + userId!)!
        var request = URLRequest(url:url)
        request.httpMethod = "PATCH"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            self.stopSpinner(spinner: self.spinner)
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            self.DisplayWarnining(warning: "Изменения сохранены", title: "Congrats" + "🎉", dismissing: true)
        }
        dataTask.resume()
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
    
}
extension ProfileController: PickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}
