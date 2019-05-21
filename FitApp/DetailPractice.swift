//
//  DetailTraining.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
import UIKit

class DetailPractice: UITableViewController {
    
    @objc func reloadTableViewAfterAddingExr (notifiction: Notification) {
        self.exerciseList.removeAll()
        self.requestExercise(id: self.practiceId)
    }
  
    
    
    @IBOutlet weak var inviteFriend: UIBarButtonItem!
    @IBOutlet weak var searchAndAdd: UIBarButtonItem!
    @IBOutlet weak var AddExercise: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        self.hideKeyboardWhenTappedAround() 
        self.title = self.practiceName
        if self.practiceStatus == false || self.practiceOwner != KeychainWrapper.standard.string(forKey: "userId") {
            print(practiceStatus)
            self.AddExercise.isEnabled = false
            self.searchAndAdd.isEnabled = false
            self.inviteFriend.isEnabled = false
            
        }
        tableView.dataSource = self
        tableView.delegate = self
       
        requestExercise(id: practiceId)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewAfterAddingExr(notifiction:)), name: .reloadListExr, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(connectPracticeWithExercSearch(notification:)), name: .searchExerAndAdd, object: nil)
    }
    @objc func refresh(){
        NotificationCenter.default.post(name: .reloadListExr, object: nil)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
   
    var practiceId: String = ""
    var practiceName: String = ""
    var practiceOwner: String = ""
    var practiceStatus: Bool = false
    var exerciseList = [exercise]()
    var newExerList: String = ""
    private func parseExercise(data: Data) {
        let decoder = JSONDecoder()
        let resp = try! decoder.decode([exercise].self, from: data)
        self.exerciseList = self.exerciseList + resp
    }
    
    
    public func requestExercise(id: String) {
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
        let exercise: exercise = self.exerciseList[indexPath.row]
        cell.textLabel?.text = exercise.name
        cell.detailTextLabel?.text = String(exercise.status)
        return cell
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailExercise" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let exercise = self.exerciseList[indexPath!.row]
            let detailExercise: DetailExercise = segue.destination as! DetailExercise
            print(exercise)
            detailExercise.exercise = exercise
            detailExercise.practiceId = self.practiceId
        }
        
        if segue.identifier == "addExercise" {
            let addExercise: AddNewExercise = segue.destination as! AddNewExercise
            addExercise.practiceid = self.practiceId
        }
        if segue.identifier == "SearchFromDetailPractice" {
           //let navController = segue.destination as! UINavigationController
            let allExercises = segue.destination as! AllExerciseControler
            allExercises.detailExerFlag = true
            allExercises.tabBar = false
        }
        if segue.identifier == "inviteFriend" {
            let addFriend = segue.destination as! Friends
            addFriend.flagInviteFriends = true
            addFriend.invitePractice = practiceId
        }
    }
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return self.practiceStatus
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            let deletedId = self.exerciseList[indexPath.row].id
            self.exerciseList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.deleteExercise(exerciseId: deletedId )
        }
        return [delete]
        
    }
    
    private func deleteExercise( exerciseId: String) {
         let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        var params = ["delete" : exerciseId ]
        let url = "https://shielded-chamber-25933.herokuapp.com/practices/"
        let deletedURL = URL(string: url + self.practiceId + "/deleteExercise")
        var request = URLRequest(url: deletedURL!)
        request.httpMethod = "DELETE"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }
    @objc func connectPracticeWithExercSearch(notification: Notification) {
        
        if let data = notification.userInfo as? [String:String] {
            for x in data {
                self.connectPracticeExer(practiceId: self.practiceId, exerciseId: x.value)
            }
            self.exerciseList.removeAll()
            self.requestExercise(id: self.practiceId)
        }
        
    }
    func connectPracticeExer (practiceId: String, exerciseId: String) {
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
                
                if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers ) as? [String: Any] {
                    
                    if let error = json["error"], let reason = json["reason"]  {
                        if error as! Bool == true && reason as! String == "no such uid"{
                        DispatchQueue.main.async {
                            self.DisplayWarnining(warning: "Try again, please", title: "Application Error", dismissing: false)
                        }
                    }
                }
            }
                
            } catch let error {
                print(error.localizedDescription)
            }
            
        })
        task.resume()
    }
    func DisplayWarnining (warning: String, title: String, dismissing: Bool) -> Void {
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
            warningController.addAction(buttonAction)
            self.present(warningController, animated: true, completion: nil)
        }
        
    }
    

}
extension Notification.Name {
    static let reloadListExr = Notification.Name("reloadListExr")
    static let searchExerAndAdd = Notification.Name("SearchAndAdd")
}
