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
    @IBOutlet weak var checkBoxStatus: UIButton!
    
    @IBAction func checkBoxStatus(_ sender: UIButton) {
        
        if (checkBoxStatus.isSelected == true) {
            let image = UIImage(named: "box") as UIImage?
            checkBoxStatus.layer.cornerRadius = self.checkBoxStatus.bounds.size.width / 2
            checkBoxStatus.setBackgroundImage(image, for: UIControl.State.normal)
            checkBoxStatus.isSelected = false
        } else {
            let image = UIImage(named: "checkbox") as UIImage?
            checkBoxStatus.setBackgroundImage(image, for: UIControl.State.normal)
            checkBoxStatus.layer.cornerRadius = self.checkBoxStatus.bounds.size.width / 2
            checkBoxStatus.isSelected = true
            print(checkBoxStatus.isSelected)
        }
        
    }
    
    @IBOutlet weak var numMeasureTextField: UITextField!
    @IBOutlet weak var exerciseNameTextfield: UITextField!
    @IBAction func cancelAddExercise(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func saveExercise(_ sender: UIBarButtonItem) {
        
        
            let name = self.exerciseNameTextfield.text ?? ""
            let apparatusId = "ABE20528-B13B-482D-8E85-9552464D4506"
            let measureId = "F90AF7F0-B396-4B0D-8C2E-68254E64D252"
            let numMeasure = Int(self.numMeasureTextField.text ?? "") ?? 0
            /*var status = false
             if self.checkBoxStatus.isSelected == true {
             status = true
             }*/
            let exerciseToSave = self.prepareExercise(name: name, numTry: self.numTry, numRep: self.numRep, apparatusId: apparatusId, measureUnitId: measureId, status: self.checkBoxStatus.isSelected, numMeasure: numMeasure)
                self.postExercise(exercise: exerciseToSave)
            NotificationCenter.default.post(name: .reloadListExr, object: nil)
            self.dismiss(animated: true, completion: nil)
       
        
        
        
    }
    
    @IBOutlet weak var picker: UIPickerView!
    var pickerData: [[String]] = [[String]]()
    var numTry: Int = 0
    var numRep: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //self.checkBoxStatus.isSelected = false
        let image = UIImage(named: "box") as UIImage?
        self.checkBoxStatus.layer.cornerRadius = self.checkBoxStatus.bounds.size.width / 2
        self.checkBoxStatus.setBackgroundImage(image, for: UIControl.State.normal)
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
                    if self.flagConnectionIds == true || self.flagEdit == true {
                    self.connectPracticeExercise(practiceId: self.practiceid, exerciseId: json["id"] as! String)
                    } else {
                        self.idOfCreatedExercise = json["id"] as! String
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
        
    
}