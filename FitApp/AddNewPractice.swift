//
//  AddNewPractice.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 07/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class AddNewPractice: UIViewController {
    //var createdExercise = [String]()
    let spinner = UIActivityIndicatorView(style: .gray)
    var chosenExercises = [String]()
    var selectedFriends = [String:String]()
    var date = Date()
    var createdPacticeForUsers = String()
    var editPracticeFlag = true
    var repeatAfter1 = Int()
    var addPracticeToself = true
    
    @IBOutlet weak var repeatAfter: UITextField!
    @IBOutlet weak var numDay: UITextField!
    
    @IBOutlet weak var saveNewPractice: UIButton!
    
    @IBOutlet weak var PracticeNameTextField: UITextField!
   /* @IBAction func cancelAddPractice(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }*/
    
    @IBOutlet weak var swithEdit: UISwitch!
    @IBOutlet weak var addPractToSelf: UISwitch!
    
    @IBAction func savePractice(_ sender: UIButton) {
        self.spinner.color = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        self.spinner.center = view.center
        self.spinner.hidesWhenStopped = false
        self.spinner.startAnimating()
        view.addSubview(self.spinner)
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var params = [String:Any]()
        if self.dateInput.text != "" {
            print(self.dateInput.text)
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
           // formatter.dateFormat = "EEEE, dd MMM yyyy" // для телефона
           formatter.dateFormat = "EEEE, MMM dd, yyyy" // для компа
            if let date = self.dateInput.text {
                let dateform = formatter.date(from: date)
                let formatter2 = DateFormatter()
                formatter2.calendar = Calendar(identifier: .iso8601)
                //formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // для телефона
                formatter2.dateFormat = "yyyy-MM-dd'T'HH:mm:ssss'Z'" // для компа
                params["date"] = formatter2.string(from: dateform!)
                print(params["date"])
                params["repeatAfter"] = Int(self.repeatAfter.text ?? "0")
            }
        }
        if self.PracticeNameTextField.text == "" {
            self.DisplayWarnining(warning: "Дайте название тренировке", title: "Упс!", dismissing: false)
            return
        } else {
            params["name"] = self.PracticeNameTextField.text!
        }
        params["owner"] = userId!
        params["status"] = self.editPracticeFlag
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/practices")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
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
        let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
            self.stopSpinner(spinner: self.spinner)
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                if let json = try JSONSerialization.jsonObject(with: data) as? [String:Any] {
                    if json.keys.contains("error") {
                        self.DisplayWarnining(warning: "Попробуйте снова", title: "Что-то пошло не так", dismissing: false)
                    } else {
                    self.createdPacticeForUsers = json["id"] as! String
                    self.addExrToPractice(idPractice: self.createdPacticeForUsers, idsExr: self.chosenExercises)
                    self.addPracticeToUsers(idPractice: self.createdPacticeForUsers, idsUsers: self.selectedFriends)
                         NotificationCenter.default.post(name: .reloadPracticeList, object: nil)
                    self.DisplayWarnining(warning: "Пользователи получили тренировки", title: "Тренировка добавлена", dismissing: true)
                   
                    }
                }
            }
            catch let error {
                print(error.localizedDescription)
            }
        })
       dataTask.resume()
    }
    
    private func addExrToPractice (idPractice: String, idsExr: [String]) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var params = [String:Any]()
        for x in idsExr {
            params["contain"] = x
            let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/practices/" + self.createdPacticeForUsers + "/addExercise")!
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            do {
                 request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            catch let error {
                print(error.localizedDescription)
            }
            if var key = accessToken {
                key = "Bearer " + key
                request.setValue(key, forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard let error = error else {
                    return
                }
                guard let data = data else {
                    return
                }
                do {
                    if let json =  try JSONSerialization.jsonObject(with: data) as? [String:Any] {
                        if json.keys.contains("error") {
                            self.DisplayWarnining(warning: "Попробуйте снова", title: "Что-то пошло не так", dismissing: false)
                        }
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            })
            dataTask.resume()
            
        }
    }
    
    public func addPracticeToUsers (idPractice: String, idsUsers: [String:String]) {
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var params = [String:Any] ()
        var dictUsers = idsUsers
        if self.addPracticeToself == true {
            dictUsers["\(userId)"] = userId
        }
        for x in dictUsers {
            print(x.key, x.value)
            params["contain"] = idPractice
            let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + x.value + "/addpractice")!
            var request = URLRequest(url:url)
            request.httpMethod = "POST"
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            }
            catch let error {
                print(error.localizedDescription)
            }
            if var key = accessToken {
                key = "Bearer " + key
                request.setValue(key, forHTTPHeaderField: "Authorization")
            }
            request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: { data, response, error in
                guard let error = error else {
                    return
                }
                guard let data = data else {
                    return
                }
                do {
                    if let json =  try JSONSerialization.jsonObject(with: data) as? [String:Any] {
                        if json.keys.contains("error") {
                            self.DisplayWarnining(warning: "Попробуйте снова", title: "Что-то пошло не так", dismissing: false)
                        }
                    }
                }
                catch let error {
                    print(error.localizedDescription)
                }
            })
            dataTask.resume()
        }
    }
    
    @IBOutlet weak var dateInput: UITextField!
    
    @IBAction func dateInput(_ sender: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = UIDatePicker.Mode.date
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(AddNewPractice.datePickerValueChanged), for: UIControl.Event.valueChanged)
    }
    
    @objc func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = Calendar(identifier: .iso8601)
        // formatter.dateFormat = "EEEE, dd MMM yyyy" // для телефона
        dateFormatter.dateFormat = "EEEE, MMM dd, yyyy" // для компа
        /*let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.full
        dateFormatter.timeStyle = DateFormatter.Style.none*/
        dateInput.text = dateFormatter.string(from: sender.date)
    }
    @objc func switchIsChanged(_: UISwitch) {
        if self.swithEdit.isOn {
            self.editPracticeFlag  = true
        } else {
            self.editPracticeFlag  = false
        }
    }
    @objc func switch2IsChanged(_: UISwitch) {
        if self.swithEdit.isOn {
            self.addPracticeToself  = true
        } else {
            self.addPracticeToself  = false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        self.title = "Новая тренировка"
       
        NotificationCenter.default.addObserver(self, selector: #selector(setChosenExercises(notification:)), name: .chosenExercise, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(setChosenFriends(notification:)), name: .chosenfriends, object: nil)
        self.PracticeNameTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.dateInput.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
         self.numDay.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.saveNewPractice.layer.cornerRadius = 5
        self.saveNewPractice.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        self.swithEdit.addTarget(self, action: #selector(self.switchIsChanged(_:)), for: UIControl.Event.valueChanged)
        self.addPractToSelf.onTintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        self.swithEdit.onTintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
         self.addPractToSelf.addTarget(self, action: #selector(self.switch2IsChanged(_:)), for: UIControl.Event.valueChanged)
        //datePicker.maximumDate = Date()
        print(chosenExercises)
        
        
    }
  
    
    func stopSpinner(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
   
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromAddNewPractice" {
            let addNewExercise: AddNewExercise = segue.destination as! AddNewExercise
            addNewExercise.flagConnectionIds = false
        }
        if segue.identifier == "selectFriends" {
            let navController = segue.destination as! UINavigationController
            let friendList = navController.topViewController as! Friends
            friendList.flagCreateNewPractice = true
            friendList.chosenFriends = self.selectedFriends

        }
        if segue.identifier == "addExerToNewPract" {
            let exercisesList: AllExerciseControler = segue.destination as! AllExerciseControler
            exercisesList.tabBar = false
        }
    }
    @objc func setChosenFriends(notification: Notification) {
        if let data = notification.userInfo as? [String:String] {
            self.selectedFriends = data
        }
    }
    
    
    @objc func setChosenExercises(notification: Notification) {
        if let data = notification.userInfo as? [String:String] {
            for x in data {
                self.chosenExercises.append(x.value)
                print(chosenExercises)
            }
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
                        self.navigationController?.popViewController(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            warningController.addAction(buttonAction)
            self.present(warningController, animated: true, completion: nil)
        }
        
    }
   
    
}
extension Notification.Name {
    static let chosenExercise = Notification.Name("chosenExercise")
    static let chosenfriends = Notification.Name("chosenFriends")
  
}
