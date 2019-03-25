//
//  AllExerciseController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 12/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class AllExerciseControler: UITableViewController {
    var exerciseList = [Exercise]()
    var selectedExercises = [String] ()
    private func selected () {
        if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.selectedExercises.append(self.exerciseList[x[1]].uid)
            }
        }
    }
        
    @IBAction func doneAddingExercises(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: {
            if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.selectedExercises.append(self.exerciseList[x[1]].uid)
                }
            }
        })
    }
    
    var tappededit = false
    var preparation = [Exercise]()
    @IBAction func reorderRows(_ sender: Any) {
        self.tappededit = !self.tappededit
        self.selected()
        self.preparation = self.exerciseList.filter({self.selectedExercises.contains($0.uid)})
        //print(self.preparation)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        isEditing = !isEditing
    }
    
    
   /* @IBAction func cancel(_ sender: UIBarButtonItem) {
         dismiss(animated: true, completion: nil)
    }*/
    
    override func viewDidLoad() {
            super.viewDidLoad()
            tableView.dataSource = self
            tableView.delegate = self
            tableView.allowsMultipleSelection = true
            requestExercises()
        }
    private func parseExercises (data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String,Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let name = x["name"] as? String
                    let measureUnitId = x["measure_unitId"] as? String
                    let num_measure = x["num_measure"] as? Int
                    let num_rep = x["num_rep"] as? Int
                    let num_try = x["num_try"] as? Int
                    let apparatusId = x["apparatusId"] as? String
                    let status = x["status"] as? Bool
                    
                    let newExercise = Exercise(name: name!, uid: uid!, num_try: num_try!, num_rep: num_rep!, num_measure: num_measure!, measureUnitId: measureUnitId!, apparatusId: apparatusId!, status: status!)
                    self.exerciseList.append(newExercise)
                }
            }
            else {
                print ("Invalid json format")
                return
            }
        } catch {
            print ("JSON parsing error:"+error.localizedDescription)
        }
        
    }
    private func requestExercises() {
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/exercises/")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
            (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
                else {
                    print("network err")
                    return
            }
            self.parseExercises(data: data)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        dataTask.resume()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tappededit == false {
        return self.exerciseList.count
        }
        else {
           return  self.preparation.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllExerciseCell", for: indexPath)
        if self.tappededit == false {
            let exercise: Exercise = self.exerciseList[indexPath.row]
            cell.textLabel?.text = exercise.name
            let selectedIndexPaths = tableView.indexPathsForSelectedRows
            let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
            cell.accessoryType = rowIsSelected ? .checkmark : .none
            return cell
        }
        else if indexPath.row <= self.preparation.count-1 && self.tappededit == true   {
            
           // while indexPath.row < preparation.count {
            print (self.preparation)
            print(indexPath.row)
            let exercise: Exercise = self.preparation[indexPath.row]
            cell.textLabel?.text = exercise.name
            return cell
           // }
        }
        else {
            return cell
        }
        
        
       
       // return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .checkmark
        
    }
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "chosenExercises" {
            let newPractice: AddNewPractice = segue.destination as! AddNewPractice
            newPractice.chosenExercises = self.selectedExercises
        }
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let exerciseToMove = self.exerciseList[sourceIndexPath.row]
        self.exerciseList.remove(at: sourceIndexPath.row)
        self.exerciseList.insert(exerciseToMove, at: destinationIndexPath.row)
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        
            return UITableViewCell.EditingStyle.none
    
    }
    
    
    
    
}
