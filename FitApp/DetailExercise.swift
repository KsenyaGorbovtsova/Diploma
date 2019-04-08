//
//  DetailExercise.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 01/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class DetailExercise: UIViewController {
    
    var exercise: Exercise!
    var practiceId = ""
    
    @IBOutlet weak var nameExercise: UILabel!
    
    @IBOutlet weak var measure_Unitlabel: UILabel!
    @IBOutlet weak var num_measureLabel: UILabel!
    @IBOutlet weak var apparatusLabel: UILabel!
    @IBOutlet weak var num_repLabel: UILabel!
    @IBOutlet weak var num_tryLabel: UILabel!
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    @IBAction func EditExercise(_ sender: UIBarButtonItem) {
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.exercise.status == false {
            self.editButton.isEnabled = false
            
        }
        
        if exercise != nil {
            self.nameExercise.text = exercise.name
            self.num_repLabel.text = String(exercise.num_rep)
            self.num_tryLabel.text = String(exercise.num_try)
            self.apparatusLabel.text = exercise.apparatusId
            self.num_measureLabel.text = String(exercise.num_measure)
            self.measure_Unitlabel.text = String(exercise.measureUnitId)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "editExercise" {
            let addExercise: AddNewExercise = segue.destination as! AddNewExercise
            addExercise.nameFromEdit = self.nameExercise.text ?? ""
            addExercise.flagEdit = true
            addExercise.practiceid = self.practiceId
            addExercise.idOfEditedExercise = self.exercise.uid
            
        }
    }
    
    
    
}
