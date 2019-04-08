//
//  AddNewPractice.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 07/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class AddNewPractice: UIViewController {
    //var createdExercise = [String]()
    var chosenExercises = [String]()
    @IBOutlet weak var PracticeNameTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBAction func cancelAddPractice(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func savePractice(_ sender: UIBarButtonItem) {
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(setChosenExercises(notification:)), name: .chosenExercise, object: nil)
        datePicker.maximumDate = Date()
        print(chosenExercises)
        
        
    }
    
    private func preparePractice (name: String, status: Bool, owner: String ) -> Practice {
        let newPractice = Practice(status: status, name: name,  owner: owner)
        return newPractice
    }
    
    private func postPractice(practice: Practice) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "fromAddNewPractice" {
            let addNewExercise: AddNewExercise = segue.destination as! AddNewExercise
            addNewExercise.flagConnectionIds = false
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
    
}
extension Notification.Name {
    static let chosenExercise = Notification.Name("chosenExercise")
}
