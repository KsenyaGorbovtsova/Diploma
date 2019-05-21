//
//  DetailMeasurement.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 03/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class  DetailMeasurement: UIViewController {
    
    
    @IBOutlet weak var nameTextLabel: UITextField!
    @IBOutlet weak var actionButton: UIButton!
    let spinner = UIActivityIndicatorView(style: .gray)
    var name = String()
    var flagCreateNew = false
    var flagShow = false
    var showMentId = [String:String]()
    var newMentId = [String:String]()
    override func viewDidLoad() {
        super.viewDidLoad()
         self.hideKeyboardWhenTappedAround() 
        self.actionButton.layer.cornerRadius = 5
      /*  if self.flagShow == true {
            self.title = self.name
            self.nameTextLabel.isHidden = true
            self.actionButton.setTitle("Выбрать", for: .normal)
        }
        else {*/
            self.title = "Новый параметр"
           
            self.nameTextLabel.isHidden = false
            self.nameTextLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
            self.actionButton.setTitle("Сохранить", for: .normal)
            self.actionButton.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
            
        //}
    }
    
    
    @IBAction func actionButtonClecked(_ sender: UIButton) {
        if self.flagShow == false {
            self.spinner.color = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1)
            self.spinner.center = view.center
            self.spinner.hidesWhenStopped = false
            self.spinner.startAnimating()
            view.addSubview(self.spinner)
            self.postMent()
            NotificationCenter.default.post(name: .reloadMeasureList, object: nil)
        }
        else {
            NotificationCenter.default.post(name: .measurementId, object: nil, userInfo: self.showMentId)
            dismiss(animated: true, completion: nil)
        }
    }
    private func postMent() {
        var params = [String:Any]()
        if let newName = self.nameTextLabel.text {
            params["name"] = newName
        }
        
        if params["name"] as? String == ""{
            self.stopSpinner(spinner: self.spinner)
            self.DisplayWarnining(warning: "Заполните поле \"название\"", title: "Недостаточно информации", dismissing: false, numButtons: 1)
            return
        }
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/measureunits")!
        var request = URLRequest(url:url)
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
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            self.stopSpinner(spinner: self.spinner)
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String:String] {
                    print(json)
                    self.newMentId = ["0": json["id"] ?? ""]
                    self.DisplayWarnining(warning: "Новый параметр создан", title: "Добавить его к упражнению?", dismissing: true, numButtons: 2)
                } else {
                     self.DisplayWarnining(warning: "Попробуйте еще раз", title: "Сервер козлит", dismissing: false, numButtons: 1)
                }
                
                
            }
            catch let error {
                print(error.localizedDescription)
            }
            
        }
        dataTask.resume()
    }
    func stopSpinner(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.stopAnimating()
           spinner.removeFromSuperview()
        }
    }
    func DisplayWarnining (warning: String, title: String, dismissing: Bool, numButtons: Int) -> Void {
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
            let agreeAction = UIAlertAction(title: "Да", style: .default)
            { (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .measurementId, object: nil, userInfo: self.newMentId)
                    warningController.dismiss(animated: true, completion: nil)
                    if dismissing == true {
                       self.navigationController?.popViewController(animated: true)
                    }
                }
            }
            let disagreeAction = UIAlertAction(title: "Нет", style: .default)
            { (action: UIAlertAction!) in
                DispatchQueue.main.async {
                    warningController.dismiss(animated: true, completion: nil)
                    if dismissing == true {
                        self.dismiss(animated: true, completion: nil)
                    }
                }
            }
            if numButtons == 1 {
                warningController.addAction(buttonAction)
            }
            else {
                warningController.addAction(agreeAction)
                warningController.addAction(disagreeAction)
            }
            self.present(warningController, animated: true, completion: nil)
        }
        
    }
    
}
