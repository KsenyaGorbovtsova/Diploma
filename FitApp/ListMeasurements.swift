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
    
    
    var measurementsList = [measurement]()
    var chosenMeasurement = String()
    var chosenIndexPath = IndexPath()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Параметры"
        NotificationCenter.default.addObserver(self, selector: #selector(reloadMeasureList(notification:)), name: .reloadMeasureList, object: nil)
        self.requestMeasurements()
    }
    
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.measurementsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "mentCell", for: indexPath)
        cell.selectionStyle = .none
       
        let ment: measurement = self.measurementsList[indexPath.row]
        cell.textLabel?.text = ment.name
        
        if ment.id == self.chosenMeasurement {

            cell.backgroundColor =  UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            self.chosenIndexPath = indexPath
        }
        return  cell
    }
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let addMent = UITableViewRowAction(style: .normal, title: "Добавить") {
            (action, indexPath) in
            if self.chosenMeasurement != "" {
                let cell = tableView.cellForRow(at: self.chosenIndexPath)
                cell?.backgroundColor = UIColor.white
                cell?.textLabel?.textColor = UIColor.black
                
            }
        
            self.chosenMeasurement = self.measurementsList[indexPath.row].id
            self.chosenIndexPath = indexPath
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor =  UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            cell?.textLabel?.textColor = .black
            NotificationCenter.default.post(name: .measurementId, object: nil, userInfo: ["0":self.chosenMeasurement])
            self.dismiss(animated: true, completion: nil)
        }
        
        addMent.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        return [addMent]
    }
    /*   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showMent" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let detailMent: DetailMeasurement = segue.destination as! DetailMeasurement
            detailMent.flagShow = true
            detailMent.name = self.measurementsList[indexPath!.row].name
            detailMent.showMentId = ["0":self.measurementsList[indexPath!.row].uid]
        }
    }*/
  
    private func requestMeasurements() {
        if isInternetAvailable() {
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
        
        else {
            DisplayWarnining(warning: "проверьте подключение к интернету", title: "Упс!", dismissing: false, sender: self)
        }
    }
    
    private func parseMeasurements(data: Data) -> [measurement] {
        var mentList = [measurement]()
        let decoder = JSONDecoder()
        let resp = try! decoder.decode([measurement].self, from: data)
        mentList = mentList + resp
        return mentList
    }
    @objc func reloadMeasureList(notification: Notification) {
        self.measurementsList.removeAll()
        self.requestMeasurements()
    }
}
extension Notification.Name {
    static let reloadMeasureList = Notification.Name("reloadMeasureList")
}
