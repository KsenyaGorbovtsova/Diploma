//
//  DetailTraining.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class DetailPractice: UITableViewController {
    
    
  
    
    
    @IBOutlet weak var AddExercise: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if self.practiceStatus == false {
            print(practiceStatus)
            self.AddExercise.isEnabled = false
        }
        tableView.dataSource = self
        tableView.delegate = self
        requestExercise(id: practiceId)
    }
    
    var practiceId: String = ""
    var practiceStatus: Bool = false
    var exerciseList = [Exercise]()
    private func parseExercise(data: Data) {
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String,Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let measureUnitId = x["measure_unitId"] as? String
                    let num_measure = x["num_measure"] as? Int
                    let num_rep = x["num_rep"] as? Int
                    let num_try = x["num_try"] as? Int
                    let apparatusId = x["apparatusId"] as? String
                    let status = x["status"] as? Bool
                    let name = x["name"] as? String
                    let newExercise = Exercise(name: name!, uid: uid!, num_try: num_try!, num_rep: num_rep!, num_measure: num_measure!, measureUnitId: measureUnitId!, apparatusId: apparatusId!, status: status!)
                    self.exerciseList.append(newExercise)
                }
            }
            else {
                print("Invalid JSON format")
                return
            }
        } catch {
            print ("JSON parsing error:"+error.localizedDescription)
        }
    }
    
    
    private func requestExercise(id: String) {
        let url = "https://shielded-chamber-25933.herokuapp.com/practices/"
        let urlEndpoint = URL(string: url + id + "/contain")!
        let dataTask = URLSession.shared.dataTask(with: urlEndpoint) { data, response, error in
            guard
                error == nil,
                (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
                else {
                    print ("network err")
                    return
            }
            self.parseExercise(data: data)
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
        return self.exerciseList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        let exercise: Exercise = self.exerciseList[indexPath.row]
        
        cell.textLabel?.text = exercise.name
        cell.detailTextLabel?.text = String(exercise.status)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailExercise" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let exercise = self.exerciseList[indexPath!.row]
            let detailExercise: DetailExercise = segue.destination as! DetailExercise
            detailExercise.exercise = exercise
        
        }
        
        if segue.identifier == "addExercise" {
            let addExercise: AddNewExercise = segue.destination as! AddNewExercise
            addExercise.practiceid = self.practiceId
            
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.practiceStatus
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            let deletedId = self.exerciseList[indexPath.row].uid
            self.exerciseList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteExercise(id: deletedId)
        }
        return [delete]
        
    }
    
    private func deleteExercise(id: String) {
        let url = "https://shielded-chamber-25933.herokuapp.com/exercises/"
        let deletedURL = URL(string: url + id + "/delete")
        var request = URLRequest(url: deletedURL!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
  
    

}
