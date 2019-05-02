//
//  ListMeasurements.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 03/05/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper


class  ListMeasurements: UITableViewController {
    
    var measurementsList = [Measurements]()
    var chosenMeasurement = String()
    var chosenIndexPath = IndexPath()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.requestMeasurements()
    }
    
    @IBAction func cancelButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.measurementsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mentCell", for: indexPath)
        let ment: Measurements = self.measurementsList[indexPath.row]
        cell.textLabel?.text = ment.name
        if ment.uid == self.chosenMeasurement {
            cell.backgroundColor = UIColor.green
            self.chosenIndexPath = indexPath
        }
        return  cell
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let addMent = UITableViewRowAction(style: .normal, title: "Add") {
            (action, indexPath) in
            if self.chosenMeasurement != "" {
                let cell = tableView.cellForRow(at: self.chosenIndexPath)
                cell?.backgroundColor = UIColor.white
                cell?.textLabel?.textColor = UIColor.black
                
            }
            self.chosenMeasurement = self.measurementsList[indexPath.row].uid
            self.chosenIndexPath = indexPath
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor.init(displayP3Red: 0.85, green: 0.92, blue: 0.83, alpha: 1)
            cell?.textLabel?.textColor = UIColor.lightGray
            NotificationCenter.default.post(name: .measurementId, object: nil, userInfo: ["0":self.chosenMeasurement])
            self.dismiss(animated: true, completion: nil)
        }
        
        addMent.backgroundColor = UIColor.green
        return [addMent]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMent" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let detailMent: DetailMeasurement = segue.destination as! DetailMeasurement
            detailMent.flagShow = true
            detailMent.name = self.measurementsList[indexPath!.row].name
            detailMent.showMentId = ["0":self.measurementsList[indexPath!.row].uid]
        }
    }
    
    private func requestMeasurements() {
        
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/measureunits")!
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
                self.measurementsList = self.parseMeasurements(data: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    private func parseMeasurements(data: Data) -> [Measurements] {
        var mentList = [Measurements]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String, Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let name = x["name"] as? String
                    let newMent = Measurements(uid: uid!, name: name!)
                    mentList.append(newMent)
                }
            }
            else {
                print("Invalid json")
            }
        }
        catch {
            print ("JSON parsing error:"+error.localizedDescription)
        }
        return mentList
    }
}
