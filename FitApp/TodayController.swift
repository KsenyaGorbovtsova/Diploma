//
//  TodayController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 10/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class todayController: UIViewController, UITableViewDataSource, UITableViewDelegate{
  var chosenPractice = ""
    var chosenIndex = IndexPath()
   var practicesToday = [Practice]()
    var showPlate = false
    
    @IBOutlet weak var exrTable: UITableView!
    
    @IBOutlet weak var plate: UIView!
    var exerToday = [Exercise]()
    @IBOutlet weak var tableViewPractice: UITableView!
    @IBOutlet weak var dateField: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableViewPractice.refreshControl = refreshControl
        self.title = "Сегодня"
        self.navigationController?.navigationBar.prefersLargeTitles = true
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .iso8601)
        formatter.dateFormat = "dd MMMM yyyy"
        self.dateField.text = formatter.string(from: Date())
        tableViewPractice.dataSource = self
        self.tableViewPractice.delegate = self
        exrTable.dataSource = self
        self.exrTable.delegate = self
        requestTodayPlan()
        self.plate.clipsToBounds = false
        self.plate.layer.cornerRadius = self.plate.frame.size.height/15
       self.plate.layer.borderWidth = CGFloat(1)
        self.plate.layer.borderColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1).cgColor
        
        
    }
    @objc func refresh(){
        NotificationCenter.default.post(name: .reloadPracticeList, object: nil)
        tableViewPractice.reloadData()
        tableViewPractice.refreshControl?.endRefreshing()
    }
    func close() {
        showPlate = true
        UIView.animate(withDuration: 0.5, delay: 0.35, options: .curveEaseOut, animations: { var plateTop = self.plate.frame
            plateTop.origin.y -= plateTop.size.height + 100
            self.plate.frame = plateTop}, completion: nil)
        
    }
    func open(){
        exerToday.removeAll()
        showPlate = false
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: { var plateTop = self.plate.frame
            plateTop.origin.y += plateTop.size.height + 100
            self.plate.frame = plateTop}, completion: nil)
       
       
    }
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if tableView == tableViewPractice {
        return practicesToday.count
    }
    else if tableView == exrTable {
        return exerToday.count
    }
    return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == tableViewPractice {
        let cell = tableView.dequeueReusableCell(withIdentifier: "exerciseCell", for: indexPath)
        let practice: Practice = practicesToday[indexPath.row]
        cell.textLabel?.text = practice.name
        cell.selectionStyle = .none
            
        return cell
        }
        else if tableView == exrTable {
            let cell = exrTable.dequeueReusableCell(withIdentifier: "todayExr", for: indexPath)
            let exercise: Exercise = exerToday[indexPath.row]
           
            cell.textLabel?.text = exercise.name
            cell.detailTextLabel?.numberOfLines = 2
            cell.detailTextLabel?.text = "Кол-во подходов: " + String(exercise.num_try) + "\nКол-во повторений: " + String(exercise.num_rep)
            cell.selectionStyle = .none
            return cell
        }
        return UITableViewCell()
    }
  
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if chosenIndex != indexPath && chosenIndex.count != 0{
            open()
            let cell = tableView.cellForRow(at: chosenIndex)!
            cell.backgroundColor = .white
         
        }
        if tableView == tableViewPractice {
            
        let cell = tableView.cellForRow(at: indexPath)!
        let practice = practicesToday[indexPath.row].uid
        chosenIndex = indexPath
        if cell.backgroundColor == UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1) {
            open()
            cell.backgroundColor = .white
            chosenIndex  = IndexPath()
            
        }else{
            self.requestExercise(id: practice)
            close()
            cell.backgroundColor = UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            chosenIndex = indexPath
            
        }
        } else {
            exrTable.allowsSelection = false
        }
        
    }
 

    private func requestTodayPlan() {
        let userid: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
       
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + userid! + "/todayPractices")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue(key, forHTTPHeaderField: "Authorization")
        }
        
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                
                self.practicesToday = self.parsePractices(data: data)
                DispatchQueue.main.async {
                    self.tableViewPractice.reloadData()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
        
    }
    
    private func parsePractices(data: Data) -> [Practice] {
        var practiceList = [Practice]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
           
            if jsonObject as? [Dictionary<String, Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let name = x["name"] as? String
                    let status = x["status"] as? Bool
                    let owner = x["owner"] as? String
                    let date = x["date"] as? String
                    let repeatAfter = x["repeatAfter"] as? Int
                    let newPractice = Practice(status: status!, uid: uid!, name: name!, owner: owner!, date: date!, repeatAfter: repeatAfter!)
                     practiceList.append(newPractice)
                }
            }
            else {
                print("Invalid json")
                //return
            }
        }
        catch {
            print ("JSON parsing error:"+error.localizedDescription)
        }
        return practiceList
    }
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
                    self.exerToday.append(newExercise)
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
             self.exrTable.reloadData()
             }
        }
        dataTask.resume()
}
    
        
    
}


