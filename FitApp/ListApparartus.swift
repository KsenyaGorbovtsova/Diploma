//
//  ListApparartus.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 29/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ListApparatus: UITableViewController {
    
    var apparatusList = [Apparatus] ()
    var chosenApparatus = String()
    var chosenIndexPath = IndexPath()
    
    @IBOutlet weak var addNewAppar: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadApparatusList(notification:)), name: .reloadApparatusList, object: nil)
        self.title = "Оборудование"
        
        self.navigationController?.navigationItem.rightBarButtonItem = self.addNewAppar
        
        self.requestApparatuses()
    }
  
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.apparatusList.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "apparatusCell", for: indexPath)
        let apparatus: Apparatus = self.apparatusList[indexPath.row]
        cell.textLabel?.text = apparatus.name
        if apparatus.uid == self.chosenApparatus {
            cell.backgroundColor =  UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            self.chosenIndexPath = indexPath
        }
        return  cell
    }
   
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let addApparatus = UITableViewRowAction(style: .normal, title: "Add") {
            (action, indexPath) in
            if self.chosenApparatus != "" {
                let cell = tableView.cellForRow(at: self.chosenIndexPath)
                cell?.backgroundColor = UIColor.white
                cell?.textLabel?.textColor = UIColor.black
                
            }
            self.chosenApparatus = self.apparatusList[indexPath.row].uid
            self.chosenIndexPath = indexPath
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor =  UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            cell?.textLabel?.textColor = UIColor.black
            NotificationCenter.default.post(name: .apparatusId, object: nil, userInfo: ["0":self.chosenApparatus])
            self.dismiss(animated: true, completion: nil)
        }
        
        addApparatus.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        return [addApparatus]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showApparatus" {
            let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let detailApparatus: DetailApparatus = segue.destination as! DetailApparatus
            detailApparatus.flagShow = true
            detailApparatus.name = self.apparatusList[indexPath!.row].name
            detailApparatus.imageSegue = self.apparatusList[indexPath!.row].image
            detailApparatus.showApparatusId = ["0":self.apparatusList[indexPath!.row].uid]
        }
        
       // if segue.identifier =="detailNewApparatus"
    }
    
    private func requestApparatuses() {
       
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/apparatuses")!
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
                self.apparatusList = self.parseApparatus(data: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error {
                 print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    private func parseApparatus(data: Data) -> [Apparatus] {
        var apparatusList = [Apparatus]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String, Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    let name = x["name"] as? String
                    let image = x["image"] as? String
                    let newApparatus = Apparatus(uid: uid!, image: Data(image!.utf8) ?? (UIImage(named: "noImage")?.pngData()!)!, name: name!)
                    apparatusList.append(newApparatus)
                    }
            }
            else {
                print("Invalid json")
            }
        }
        catch {
            print ("JSON parsing error:"+error.localizedDescription)
        }
        return apparatusList
    }
    @objc func reloadApparatusList(notification: Notification){
        self.apparatusList.removeAll()
         self.requestApparatuses()
    }
}
extension Notification.Name {
    static let reloadApparatusList = Notification.Name("reloadApparatusList")
}
