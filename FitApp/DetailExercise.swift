//
//  DetailExercise.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 01/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class DetailExercise: UIViewController {
    let spinner = UIActivityIndicatorView(style: .gray)
    
    @IBOutlet weak var imageView: UIImageView!
    var exercise: exercise!
   
    var practiceId = ""
    var flagBar = false
    var nameApparatus = String()
    var nameMeasurement = String()
    var imageApparatus = Data()
    @IBOutlet weak var nameExercise: UILabel!
    
    @IBOutlet weak var measure_Unitlabel: UILabel!
    @IBOutlet weak var num_measureLabel: UILabel!
    @IBOutlet weak var apparatusLabel: UILabel!
    @IBOutlet weak var num_repLabel: UILabel!
    @IBOutlet weak var num_tryLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func EditExercise(_ sender: UIBarButtonItem) {
    }
    func stopSpinner(spinner: UIActivityIndicatorView) {
        DispatchQueue.main.async {
            spinner.stopAnimating()
            spinner.removeFromSuperview()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboardWhenTappedAround() 
        NotificationCenter.default.addObserver(self, selector: #selector(reloadApparatus(notification:)), name: .reloadAppararus, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMeasure(notification:)), name: .reloadMeasure, object: nil)
        self.spinner.color = UIColor(red: 0.35, green: 0.34, blue: 0.84, alpha: 1)
        self.spinner.center = view.center
        self.spinner.hidesWhenStopped = false
        self.spinner.startAnimating()
        view.addSubview(self.spinner)
        self.requestApparatus(apparatusId: self.exercise.apparatusId)
        self.requestMeasurement(measurementId: self.exercise.measureUnitId)
        self.title = self.exercise.name
        if self.flagBar == true {
            self.navigationItem.rightBarButtonItem = nil
            self.nameExercise.isHidden = true/////убрать
        }
        else {
            
            self.nameExercise.isHidden = true////убрать
        }
        if self.exercise.status == false {
            self.editButton.isEnabled = false
            
        }
        
        
      if exercise != nil {
            
        
        self.nameExercise.text = exercise.name
        
        self.num_repLabel.text = String(exercise.num_rep)
        self.num_tryLabel.text = String(exercise.num_try)
            self.apparatusLabel.text = self.nameApparatus
              let imageData = Data.init(base64Encoded: self.imageApparatus, options: .init(rawValue: 0))
            self.imageView.image = UIImage(data: (imageData ?? (UIImage(named: "noImage")?.pngData())!)) ??  UIImage(named: "noImage")
        
        self.num_measureLabel.text = String(exercise.num_measure)
            self.measure_Unitlabel.text = self.nameMeasurement
        }
        
    }
    private func requestMeasurement(measurementId: String) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/measureunits/" + measurementId)!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                print(data)
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                if let dict =  jsonObject as? Dictionary<String, String> {
                    print(dict)
                    self.nameMeasurement = dict["name"] ?? "Без названия"
                }
                else {
                    print("no")
                }
                NotificationCenter.default.post(name: .reloadMeasure, object: nil)
                //self.stopSpinner(spinner: self.spinner)
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    private func requestApparatus(apparatusId: String) {
       // var newApparatus = Apparatus.self
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/apparatuses/" + apparatusId )!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                print(data)
                let jsonObject = try JSONSerialization.jsonObject(with: data)
                
               // if jsonObject as? Dictionary<String, String> != nil {
                    if let dict =  jsonObject as? Dictionary<String, String> {
                    print(dict)
                    self.nameApparatus = dict["name"] ?? "Без названия"
                    if let image = dict["image"] {
                    self.imageApparatus = Data(image.utf8)
                        }
                    }
                    else {
                        print("no")
                    }
                NotificationCenter.default.post(name: .reloadAppararus, object: nil)
                self.stopSpinner(spinner: self.spinner)
               
            } catch let error {
                print(error.localizedDescription)
            }
            
        }
        dataTask.resume()
    
        
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.flagBar == true {
            return false
        } else {
            return true
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editExercise" {
            let addExercise: AddNewExercise = segue.destination as! AddNewExercise
            addExercise.nameFromEdit = self.nameExercise.text ?? ""
            addExercise.flagEdit = true
            addExercise.practiceid = self.practiceId
          
            addExercise.idOfEditedExercise = self.exercise.id
            
        }
    }
    @objc func reloadApparatus(notification: Notification) {
        DispatchQueue.main.async {
            self.apparatusLabel.text = self.nameApparatus
            let imageData = Data.init(base64Encoded: self.imageApparatus, options: .init(rawValue: 0))
            self.imageView.image = UIImage(data: (imageData ?? (UIImage(named: "noImage")?.pngData())!)) ??  UIImage(named: "noImage")
        }
        
    }
    @objc func reloadMeasure(notification: Notification) {
        DispatchQueue.main.async {
             self.measure_Unitlabel.text = self.nameMeasurement
        }
    }
    
    
}
extension Notification.Name {
    static let reloadAppararus = Notification.Name("reloadApparatus")
    static let reloadMeasure = Notification.Name("reloadMeasure")
}
