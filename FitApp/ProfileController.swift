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
    var flagInvitefriend = false
    var userData = User()
    var fromFriend = false
    var invitePractice = String()
    @IBOutlet weak var secondNameTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    
    @IBOutlet weak var confirmpswdTextField: UITextField!
    @IBOutlet weak var pswdTextField: UITextField!
    
    @IBOutlet weak var emaiTextField: UITextField!
    
    @IBOutlet weak var emailLabel: UILabel!
   
    
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
    var flagAddedFriend = false // friend from filteredData - false, friend from friendList - true
    
    @IBOutlet weak var SignOutButton: UIButton!
    
    
    @IBAction func photoPickerClicked(_ sender: UIButton) {
        self.photoPicker.present(from: sender)
    }
    
    @IBOutlet weak var photoPickerButton: UIButton!
    
    @IBOutlet weak var addOrDeleteFriend: UIButton!
    
   
    
    @IBOutlet weak var zamer: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        self.hideKeyboardWhenTappedAround() 
        self.spinner.color = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1)
        self.spinner.center = view.center
        self.spinner.hidesWhenStopped = false
        self.addOrDeleteFriend.setTitleColor(.white, for: .normal)
        self.addOrDeleteFriend.layer.cornerRadius = 5
         navigationController?.navigationBar.prefersLargeTitles = true
        if self.fromFriend == true {
       // if self.tabBarController == nil{
            self.title = "Профиль"
            self.zamer.isHidden = true
            self.firstNameLabel.text = self.firstName
            self.secondNameLabel.text = self.secondName
            self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.imageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 40).isActive = true
            self.imageView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -40).isActive = true
            
            self.emailLabel.text = self.email
            if self.image.count == 0 {
                self.imageView.image = UIImage(named: "noPhoto")
            }
            else {
            let imageData = Data.init(base64Encoded: self.image, options: .init(rawValue: 0))
                self.imageView.image = UIImage(data: imageData ?? (UIImage(named: "noPhoto")?.pngData())!)
            }
            self.firstNameTextField.isHidden = true
            self.secondNameTextField.isHidden = true
            self.emaiTextField.isHidden = true
            self.pswdTextField.isHidden = true
            self.confirmpswdTextField.isHidden = true
            if self.flagAddedFriend == false  {
                self.addOrDeleteFriend.setTitle("Добавить", for: .normal)
               
                self.addOrDeleteFriend.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
                
                
            }
            else {
                
                if self.flagInvitefriend == false {
                self.addOrDeleteFriend.setTitle("Удалить из друзей", for: .normal)
                self.addOrDeleteFriend.backgroundColor = UIColor(displayP3Red: 1.00, green:0.23, blue:0.19, alpha:1.0)
                } else {
                     self.addOrDeleteFriend.setTitle("Отправить тренировку", for: .normal)
                     self.addOrDeleteFriend.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
                }
                
            }
            self.confirmPswdLine.isHidden = true
            self.newPswdLine.isHidden = true
            self.photoPickerButton.isHidden = true
            self.SignOutButton.isHidden = true
            
        }
        else {
            
            NotificationCenter.default.addObserver(self, selector: #selector(reloadView(notidication:)), name: .reloadView, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(reloadUserData(notification:)), name: .updateInfo, object: nil)
            
            self.spinner.startAnimating()
            view.addSubview(self.spinner)
            self.requestUserData()
            //sleep(20)
            self.title = "Личный кабинет"
          
            self.photoPickerButton.isHidden = false
            self.zamer.isHidden = false
            self.photoPicker = PhotoPicker(presentationController: self, delegate: self)
            
           /*if self.userData.image.count == 0 {
                self.userData.image = (UIImage(named: "noPhoto")?.pngData())!
                self.requestUserData()
            }*/
            let imageData = Data.init(base64Encoded: self.userData.image, options: .init(rawValue: 0))
            self.imageView.image = UIImage(data: (imageData ?? (UIImage(named: "noPhoto")?.pngData())!)) ??  UIImage(named: "noPhoto")
            //self.imageView.image = UIImage(data: Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))!)
            self.emailLabel.isHidden = true
            self.firstNameLabel.isHidden = true
            self.firstNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
            self.secondNameLabel.isHidden = true
            self.firstNameTextField.isHidden = false
            self.firstNameTextField.text = self.userData.firstName
            self.secondNameTextField.isHidden = false
            self.secondNameTextField.text = self.userData.secondName
            self.secondNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
            self.emaiTextField.isHidden = false
            self.emaiTextField.text = self.userData.email
            self.emaiTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
            self.pswdTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
            self.confirmpswdTextField.isHidden = false
           self.confirmpswdTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
             self.addOrDeleteFriend.setTitle("Сохранить", for: .normal)
            
            self.addOrDeleteFriend.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
            
            self.SignOutButton.isHidden = false
        }
    }
   
    @IBAction func signOut(_ sender: UIButton) {
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/users/" + userId! + "/logout")!
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
       
        let dataTask = URLSession.shared.dataTask(with: request)
        dataTask.resume()
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        
        let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "signInNav") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = signInPage
    }
    
    @IBAction func addOrDeleteButtom(_ sender: UIButton) {
        if self.fromFriend == true  && self.flagAddedFriend == false && self.flagInvitefriend == false {
            self.addOrDeleteFriendToUser(idFriend: self.idFriend, action: "Add")
            NotificationCenter.default.post(name: .reloadListFriend, object: nil)
            navigationController?.popViewController(animated: true)
            
        }
        else  if self.fromFriend == true  && self.flagAddedFriend == true && self.flagInvitefriend == false {
            self.addOrDeleteFriendToUser(idFriend: self.idFriend, action: "Delete")
            NotificationCenter.default.post(name: .reloadListFriend, object: nil)
            navigationController?.popViewController(animated: true)
           
            
        }
        else if self.flagInvitefriend == true {
           let invite = AddNewPractice()
            invite.addPracticeToUsers(idPractice: self.invitePractice, idsUsers: ["0" : idFriend])
            self.navigationController?.popViewController(animated: true)
            
        }
        else {
            self.spinner.startAnimating()
            view.addSubview(self.spinner)
            self.updateUserInformation()
            NotificationCenter.default.post(name: .updateInfo, object: nil)
        }
    }
    @IBAction func righButtonClicked(_ sender: UIBarButtonItem) {
       
        if self.flagUserOrFriend == false && self.flagAddedFriend == false {
            self.addOrDeleteFriendToUser(idFriend: self.idFriend, action: "Add")
            // NotificationCenter.default.post(name: .reloadListFriend, object: nil)
            dismiss(animated: true, completion: nil)
            
            
        }
        else if self.flagUserOrFriend == false && self.flagAddedFriend == true {
            self.addOrDeleteFriendToUser(idFriend: self.idFriend, action: "Delete")
            //NotificationCenter.default.post(name: .reloadListFriend, object: nil)
             dismiss(animated: true, completion: nil)
           
        }
        else {
           
            self.spinner.startAnimating()
            view.addSubview(self.spinner)
            self.updateUserInformation()
            NotificationCenter.default.post(name: .updateInfo, object: nil)
        }
        
    }
    
    
    @IBAction func doneButton(_ sender: UIButton) {
        NotificationCenter.default.post(name: .updateInfo, object: nil)
        dismiss(animated: true, completion: nil)
    }
    
    @IBOutlet weak var doneButton: UIButton!
    
    private func updateUserInformation() {
        var params = [String:Any]()
        if self.firstNameTextField.text != self.userData.firstName {
            params["firstName"] = self.firstNameTextField.text
        }
        if self.secondNameTextField.text != self.userData.secondName {
            params["secondName"] = self.secondNameTextField.text
        }
        if self.emaiTextField.text != self.userData.email {
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
      //  UIImage(data:Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))!)?.pngData()!
        //let test = Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))
        if self.imageView.image?.pngData() != UIImage(data: self.userData.image)?.pngData() {
           
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
           NotificationCenter.default.post(name: .updateInfo, object: nil)
            
        }
        dataTask.resume()
    }
    func stopSpinner(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
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
    
    func addOrDeleteFriendToUser (idFriend: String, action: String) {
        var endPoint = ""
        var params = [String : Any]()
        var httpMethod = ""
        if action == "Add" {
            endPoint = "addfriend"
            params = ["makeFriend" : idFriend]
            httpMethod = "POST"
        }
        if action == "Delete" {
            endPoint = "deletefriend"
            params = ["delete" : idFriend]
            httpMethod = "DELETE"
        }
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/\(userId!)/\(endPoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
            
        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
        NotificationCenter.default.post(name: .reloadListFriend, object: nil)
    }
    private func requestUserData(){
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + userId!)!
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
           self.stopSpinner(spinner: self.spinner)
            print(data)
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            print(data)
            self.parseUser(data: data)
           
        }
        dataTask.resume()
    }
    
    private func parseUser(data: Data)  {
        var firstName = String()
        var secondName = String()
        var email = String()
        var image = Data()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if var jsonDict: [String:String ] = jsonObject as? [String : String] {
                firstName = jsonDict["firstName"]!
                secondName = jsonDict["secondName"]!
                email = jsonDict["email"]!
                if  let imageData = jsonDict["image"] {
                    image = Data(imageData.utf8)
                }
                else {
                    image = (UIImage(named: "noPhoto")?.pngData())!
                }
                self.userData = User(email: email, uid: "0", firstName: firstName, secondName: secondName, image: image)
                NotificationCenter.default.post(name: .reloadView, object: nil)
                self.stopSpinner(spinner: self.spinner)
            }
            else {
                print("Invalid JSON")
            }
        }
        catch {
            print ("JSON parsing error:"+error.localizedDescription)
            
        }
        
    }
    @objc func reloadUserData(notification: NSNotification) {
        self.requestUserData()
    }

    
    @objc func reloadView(notidication: Notification) {
        DispatchQueue.main.async {
        let imageData = Data.init(base64Encoded: self.userData.image, options: .init(rawValue: 0))
        self.imageView.image = UIImage(data: (imageData ?? (UIImage(named: "noPhoto")?.pngData())!)) ??  UIImage(named: "noPhoto")
        self.firstNameTextField.text = self.userData.firstName
        self.secondNameTextField.text = self.userData.secondName
        self.emaiTextField.text = self.userData.email
            }
        }
    }
extension ProfileController: PickerDelegate {
    func didSelect(image: UIImage?) {
        self.imageView.image = image
    }
}

extension Notification.Name {
    static let reloadView = Notification.Name("reloadView")
  

    
}
extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
