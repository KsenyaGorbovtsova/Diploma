//
//  AddNewExercise.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 04/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class AddNewExercise: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var nameFromEdit: String = ""
    var practiceid: String = ""
    var flagConnectionIds = true
    var flagEdit = false
    var idOfCreatedExercise: String = ""
    var idOfEditedExercise = ""
    var apparatusId = String()
    var measurementId = String()
   var editPermission = true
    var flagTabBar = false
    
    @IBOutlet weak var switchEdit: UISwitch!
    
    @IBOutlet weak var saveExercise: UIButton!
    
    @IBOutlet weak var numMeasureTextField: UITextField!
    @IBOutlet weak var exerciseNameTextfield: UITextField!
   /* @IBAction func cancelAddExercise(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }*/
    @IBAction func saveExercise(_ sender: UIButton) {
 
            let name = self.exerciseNameTextfield.text ?? ""
            if self.apparatusId == "" {
                self.apparatusId = "5F067340-E82A-4362-A2FD-11E3AD7C4F8D"
            }
        if self.measurementId == "" {
            self.measurementId = "BA5258F3-FC50-44C8-9271-4C9B18BE7835"
        }
        
            let numMeasure = Int(self.numMeasureTextField.text ?? "") ?? 0
            /*var status = false
             if self.checkBoxStatus.isSelected == true {
             status = true
             }*/
            let exerciseToSave = self.prepareExercise(name: name, numTry: self.numTry, numRep: self.numRep, apparatusId: self.apparatusId, measureUnitId: self.measurementId, status: self.editPermission, numMeasure: numMeasure)
                self.postExercise(exercise: exerciseToSave)
            NotificationCenter.default.post(name: .reloadListExr, object: nil)
            self.navigationController?.popViewController(animated: true)
    }
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [[String]] = [[String]]()
    var numTry: Int = 0
    var numRep: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if flagEdit == true {
            self.title = "Редактирование"
        }
        self.hideKeyboardWhenTappedAround() 
        navigationController?.navigationBar.prefersLargeTitles = true
        self.saveExercise.layer.cornerRadius = 5
        self.saveExercise.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        self.saveExercise.setTitleColor(UIColor.white, for: .normal)
        self.exerciseNameTextfield.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        self.numMeasureTextField.backgroundColor = UIColor(red: 0.95, green: 0.95, blue: 0.95, alpha: 0.76)
        NotificationCenter.default.addObserver(self, selector: #selector(addApparatusId(notification:)), name: .apparatusId, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(addMeasurementId(notification:)), name: .measurementId, object: nil)
        self.switchEdit.addTarget(self, action: #selector(self.switchIsChanged(_:)), for: UIControl.Event.valueChanged)
        self.switchEdit.onTintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        
        let arr = (0...100).map {"\($0)"}
        self.pickerData.append(arr)
        self.pickerData.append(arr)
        picker.delegate = self
        picker.dataSource = self
        self.exerciseNameTextfield.text = self.nameFromEdit 
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return pickerData[0].count
        }
        return pickerData[1].count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return pickerData[0][row]
        }
        return pickerData[1][row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.numTry = picker.selectedRow(inComponent: 0)
        self.numRep = picker.selectedRow(inComponent: 1)
        print (self.numRep, self.numTry)
    }
    
    private func prepareExercise(name: String, numTry: Int, numRep: Int, apparatusId: String, measureUnitId: String, status: Bool, numMeasure: Int) -> Exercise {
        print(status)
        let newExercisice  = Exercise(name: name, num_try: numTry, num_rep: numRep, num_measure: numMeasure, measureUnitId: measureUnitId, apparatusId: apparatusId, status: status)
        
        return newExercisice
    }
    private func postExercise(exercise: Exercise) {
        let params = ["measure_unitId":exercise.measureUnitId, "num_measure" : exercise.num_measure, "num_rep": exercise.num_rep, "num_try" : exercise.num_try, "apparatusId" : exercise.apparatusId, "status" : exercise.status, "name" : exercise.name] as [String : Any]
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/exercises")
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                //create json object from data
                if let json = try JSONSerialization.jsonObject(with: data) as? [String:Any]   {
                    
                   // let exerciseId = json["id"] as! String
                  //  for x in json {
                    if self.flagTabBar == false {
                    if self.flagConnectionIds == true || self.flagEdit == true  {
                    self.connectPracticeExercise(practiceId: self.practiceid, exerciseId: json["id"] as! String)
                    } else {
                        self.idOfCreatedExercise = json["id"] as! String
                    }
                    } else {
                        NotificationCenter.default.post(name: .reloadExrBase, object: nil)
                    }
                 //   }
                    
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        })
        task.resume()
        
    }
    
    private func connectPracticeExercise(practiceId: String, exerciseId:String) {
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/practices/" + practiceId + "/addExercise")
        let params = ["contain" : exerciseId]
        var request = URLRequest(url: url!)
        request.httpMethod = "POST"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request as URLRequest, completionHandler: {data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? Dictionary<String,Any> {
                    if self.flagEdit == true {
                        DispatchQueue.main.async {
                        self.DisplayWarnining(warning: "Do you want delete old version of the exercise?", title: "Delete or not?")
                    }
                    }
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "newExercise" {
            let newPractice: AddNewPractice = segue.destination as! AddNewPractice
            newPractice.chosenExercises.append(self.idOfCreatedExercise)
        }
        if segue.identifier == "chooseApparatusButton" {
            // let navController = segue.destination as! UINavigationController
            let apparatusList = segue.destination as!  ListApparatus
            apparatusList.chosenApparatus = self.apparatusId
        }
        if segue.identifier == "addMeasurement"{
            //let navController = segue.destination as! UINavigationController
            let mentList = segue.destination as!  ListMeasurements
            mentList.chosenMeasurement = self.measurementId
        }
        
    }
    private func deleteExerciseFromPractice(practiceId: String, exerciseId: String) {
        //let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/practices/\(self.practiceid)/deleteExercise")
        let params = ["delete" : self.idOfEditedExercise]
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.addValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    @objc func switchIsChanged(_: UISwitch) {
        if self.switchEdit.isOn {
            self.editPermission  = true
        } else {
            self.editPermission = false
        }
    }
    
    func DisplayWarnining (warning: String, title: String) -> Void {
        
            let warningController = UIAlertController(title: title, message: warning, preferredStyle: .alert)
            
            warningController.addAction(UIAlertAction(title: "Yes", style: .default, handler: {(_: UIAlertAction!) in
                DispatchQueue.main.async {
                    
                self.deleteExerciseFromPractice(practiceId: self.practiceid, exerciseId: self.idOfEditedExercise)
                self.dismiss(animated: true, completion: nil)
                }
            }))
           warningController.addAction(UIAlertAction(title: "No", style: .default, handler: {(_: UIAlertAction!) in
                DispatchQueue.main.async {
                    warningController.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
                }))
            
            self.present(warningController, animated: true, completion: nil)
        }
    @objc func addApparatusId (notification: Notification) {
        if let data = notification.userInfo as? [String:String]{
            for x in data {
                self.apparatusId = x.value
            }
            print(self.apparatusId)
        }
    }
    @objc func addMeasurementId (notification: Notification) {
        if let data = notification.userInfo as? [String:String] {
            for x in data {
                self.measurementId = x.value
            }
            print(self.measurementId)
        }
    }
}

extension Notification.Name {
    static let apparatusId = Notification.Name("apparatusId")
    static let measurementId = Notification.Name("measurementId")
}
