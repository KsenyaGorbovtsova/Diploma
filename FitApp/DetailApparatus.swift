//
//  DetailApparatus.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 29/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
class DetailApparatus: UIViewController {
    let spinner = UIActivityIndicatorView(style: .gray)
    var name = String()
    var flagCreateNew = false
    var flagShow = false
    var imageSegue = Data()
    var showApparatusId = [String:String]()
    var newApparatusId = [String:String]()
    
    @IBOutlet weak var nameTitle: UILabel!
    @IBOutlet weak var imageApparatus: UIImageView!
    @IBOutlet weak var addImageButton: UIButton!
   // @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nameTextLabel: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    var photoPicker: PhotoPicker!
    
    @IBAction func addImageButton(_ sender: UIButton) {
        self.photoPicker.present(from: sender)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.flagShow == true {
            self.hideKeyboardWhenTappedAround() 
            self.title = self.name
            self.addImageButton.isHidden = true
            self.nameTextLabel.isHidden = true
            self.nameTitle.isHidden = true
            //self.nameLabel.isHidden = false
           // self.nameLabel.text = self.name
            self.saveButton.isHidden = false
             self.saveButton.setTitle("Выбрать", for: .normal)
        }
        else {
            self.title = "Новое оборудование"
            self.nameTitle.isHidden = false
            self.addImageButton.isHidden = false
            self.addImageButton.layer.cornerRadius = 5
            self.photoPicker = PhotoPicker(presentationController: self, delegate: self)
            self.nameTextLabel.isHidden = false
            self.nameTextLabel.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
           // self.nameLabel.isHidden = true
            self.saveButton.isHidden = false
            self.saveButton.setTitle("Сохранить", for: .normal)
            self.saveButton.layer.cornerRadius = 5
        }
        if self.imageSegue.count == 0 {
            self.imageApparatus.image = UIImage(named: "noImage")
        }
        else {
            let imageData = Data.init(base64Encoded: self.imageSegue, options: .init(rawValue: 0))
            self.imageApparatus.image = UIImage(data: imageData!)
        }
    }
    
    
    @IBAction func saveButtonClicked(_ sender: UIButton) {
        if self.flagShow == false {
        self.spinner.color = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1)
        self.spinner.center = view.center
        self.spinner.hidesWhenStopped = false
        self.spinner.startAnimating()
        view.addSubview(self.spinner)
        self.postApparatus()
        NotificationCenter.default.post(name: .reloadApparatusList, object: nil)
        }
        else {
             NotificationCenter.default.post(name: .apparatusId, object: nil, userInfo: self.showApparatusId)
            self.navigationController?.popViewController(animated: true)
        }
    }
    private func postApparatus() {
        var params = [String:Any]()
        if let newName = self.nameTextLabel.text {
            params["name"] = newName
        }
        if self.imageApparatus.image == nil {
            self.imageApparatus.image = UIImage(named: "noImage")
        }
        if params["name"] as? String == ""{
            self.stopSpinner(spinner: self.spinner)
            self.DisplayWarnining(warning: "Заполните поле \"название\"", title: "Недостаточно информации", dismissing: false, numButtons: 1)
            return
        }
        let newImage:NSData = self.imageApparatus.image!.jpegData(compressionQuality: 0.5)! as NSData
        
        let imageString = newImage.base64EncodedString(options: .init(rawValue: 0))
        
        params["image"] = imageString
        
        
         let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/apparatuses/create")!
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
                    self.newApparatusId = ["0": json["id"] ?? ""]
                    self.DisplayWarnining(warning: "Новое оборудование создано", title: "Добавить его к упражнению?", dismissing: true, numButtons: 2)
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
                    NotificationCenter.default.post(name: .apparatusId, object: nil, userInfo: self.newApparatusId)
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
extension DetailApparatus: PickerDelegate{
    func didSelect(image: UIImage?) {
        self.imageApparatus.image = image
    }
}

