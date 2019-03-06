//
//  ListTrainings.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class ListPractice: UITableViewController  {
    
   
    
    var practiceList = [Practice]()
  /*  override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        requestPractice()
        
    }
 
    */
   override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        requestPractice()
        //tableView.reloadData()
        
    }
 
    
    private func parsePractice (data: Data){
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String,Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let date = x["date"] as? String
                    let status = x["status"] as? Bool
                    let newPractice = Practice(date: date!, status: status!, uid: uid!)
                    self.practiceList.append(newPractice)
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
    
    private func requestPractice(){
        let url = URL (string: "https://shielded-chamber-25933.herokuapp.com/practices/")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
            (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
                else {
                    print ("network err")
                    return
            }
            self.parsePractice(data: data)
            //print(self.practiceList)
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
        return self.practiceList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let practice: Practice = self.practiceList[indexPath.row]
        
        cell.textLabel?.text = practice.name
        cell.detailTextLabel?.text = String(practice.status)
        
        return cell
    }
    
    private func deletePractice(id:String) {
        let url = "https://shielded-chamber-25933.herokuapp.com/practices/"
        let deletedURL = URL(string: url + id + "/delete")
        var request = URLRequest(url: deletedURL!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let task = URLSession.shared.dataTask(with: request)
        task.resume()
    }

    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let delete = UITableViewRowAction(style: .destructive, title: "Удалить") { (action, indexPath) in
            let deletedId = self.practiceList[indexPath.row].uid
            self.practiceList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            self.deletePractice(id: deletedId)
        
            /*
             let params = ["delete" : deletedId]
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted) // pass dictionary to nsdata object and set it as request body
            } catch let error {
                print(error.localizedDescription)
            }
             */
        }
        return [delete]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "detailPractice" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let practice = self.practiceList[indexPath!.row].uid
            let detailPractice: DetailPractice = segue.destination as! DetailPractice
            detailPractice.practiceId = practice
            detailPractice.practiceStatus = self.practiceList[indexPath!.row].status
        }
    }

    
    }
    
    
    

