//
//  ListTrainings.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 25/02/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import SwiftKeychainWrapper
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
            print(jsonObject)
            if jsonObject as? [Dictionary<String,Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let owner = x["owner"] as? String
                    let status = x["status"] as? Bool
                    let name = x["name"] as? String
                    let newPractice = Practice(status: status!, uid: uid!, name: name!, owner: owner!)
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
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        //print(accessToken)
        let userid: String? = KeychainWrapper.standard.string(forKey: "userId")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/users/" + userid! + "/practices")!
        //print(url)
        var request = URLRequest(url: url)
         request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
            
        }
        
       // request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       // request.addValue("application/json", forHTTPHeaderField: "Content-Type")
       // request.addValue("application/json", forHTTPHeaderField: "Accept")
        //request.setValue( "Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        
        let dataTask = URLSession.shared.dataTask(with: request)  {data, response, error in
            print(String(decoding: data!, as: UTF8.self))
            
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            
            
            
        do {
            //create json object from data
            //if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                //print(json["id"] as! String)
                // let exerciseId = json["id"] as! String
                self.parsePractice(data: data)
                //print(self.practiceList)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            
        } catch let error {
            print(error.localizedDescription)
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
        //cell.detailTextLabel?.text = String(practice.date)
        
        return cell
    }
    
    private func deletePractice(id:String) {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userid: String? = KeychainWrapper.standard.string(forKey: "userId")
        let url = URL(string:"https://shielded-chamber-25933.herokuapp.com/users/\(userid)/delete")
        //let deletedURL = URL(string: url + id + "/delete")
        var request = URLRequest(url: url!)
        request.httpMethod = "DELETE"
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(String(describing: accessToken))", forHTTPHeaderField: "Authorization")
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
            let rights = self.practiceList[indexPath!.row].owner
            let detailPractice: DetailPractice = segue.destination as! DetailPractice
            detailPractice.practiceId = practice
            detailPractice.practiceOwner = rights
            detailPractice.practiceStatus = self.practiceList[indexPath!.row].status
        }
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
    

    

