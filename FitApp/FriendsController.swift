//
//  FriendsController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 14/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//
import SwiftKeychainWrapper
import UIKit

class Friends: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {
    
    
    var flagChooseForPractice = false
    var friendsList = [User]()
    var search = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Search Users"
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.searchController?.searchBar.delegate = self
         UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Done"
        definesPresentationContext = true
        tableView.dataSource = self
        tableView.delegate = self
        requestFriends()
    }
    
    private func requestFriends() {
        let userid: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + userid! + "/friends")!
        var request = URLRequest(url:url)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
        }
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                self.friendsList = self.parseFriend(data: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    private func parseFriend(data: Data) -> [User] {
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        var userList = [User]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String, Any>] != nil {
                for x in jsonObject as! [Dictionary<String,Any>] {
                    let uid = x["id"] as? String
                    if uid == userId || !(friendsList.filter{$0.uid == uid}).isEmpty {
                        continue
                    }
                    let firstName = x["firstName"] as? String
                    let secondName = x["secondName"] as? String
                    let email = x["email"] as? String
                    let newFriend = User(email: email!, uid: uid!, firstName: firstName!, secondName: secondName!)
                    userList.append(newFriend)
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
        return userList
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering() {
             return self.filteredData.count
        }
        else {
            return self.friendsList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
        cell.backgroundColor = UIColor.white
        cell.textLabel?.textColor = UIColor.black
        cell.detailTextLabel?.textColor = UIColor.black
        if !isFiltering() {
            
        let friend: User = self.friendsList[indexPath.row]
        
        cell.textLabel?.text = friend.email
        cell.detailTextLabel?.text = String(friend.firstName + " " + friend.secondName)
        return cell
        }
        else if isFiltering() {
            if filteredData.count != 0 {
                
            let friend: User = self.filteredData[indexPath.row]
            cell.textLabel?.text = friend.email
            cell.detailTextLabel?.text = String(friend.firstName + " " + friend.secondName)
            }
            else {
                cell.textLabel?.text = "We couldn't find your friend"
                cell.detailTextLabel?.text = "Please, check the input :)"
            }
            return cell
        }
        else {
            return cell
        }
    }
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if isFiltering() {
        let addFriend = UITableViewRowAction(style: .normal, title: "Add") {
            (action, indexPath) in
            let addId = self.filteredData[indexPath.row].uid
            self.addOrDeleteFriendToUser(idFriend: addId, action: "Add")
            self.friendsList.append(self.filteredData[indexPath.row])
           // let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor.init(displayP3Red: 0.85, green: 0.92, blue: 0.83, alpha: 1)
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.detailTextLabel?.textColor = UIColor.lightGray
        }
        addFriend.backgroundColor = UIColor.green
        return [addFriend]
        }
        else {
            let deleteFriend = UITableViewRowAction(style: .destructive, title: "Delete") {
                (action, indexPath) in
                let deleteId = self.friendsList[indexPath.row].uid
                self.addOrDeleteFriendToUser(idFriend: deleteId, action: "Delete")
                self.friendsList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            return [deleteFriend]
        }
    }
   
    func addOrDeleteFriendToUser (idFriend: String, action: String) {
        var endPoint = ""
        var params = [String : Any]()
        var httpMethod = ""
        if action == "Add" {
            endPoint = "addfriend"
            params = ["makeFriend" : idFriend]
            httpMethod = "POST"
        }
        if action == "Delete" {
            endPoint = "deletefriend"
            params = ["delete" : idFriend]
            httpMethod = "DELETE"
        }
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/\(userId!)/\(endPoint)")!
        var request = URLRequest(url: url)
        request.httpMethod = httpMethod
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
            
        }
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
        } catch let error {
            print(error.localizedDescription)
        }
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
       request.addValue("application/json", forHTTPHeaderField: "Accept")
        let task = URLSession.shared.dataTask(with: request as URLRequest)
        task.resume()
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterForSearch(search.searchBar.text!)
    }
    var filteredData = [User]()
    func filterForSearch ( _ searchText: String, scope: String = "ALL") {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if searchText == nil {
            return
        }
        var url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/search?email=\(searchText.lowercased())")
        var request = URLRequest(url: url!)
        request.httpMethod = "GET"
        if var key = accessToken {
            key = "Bearer " + key
            request.setValue( "Bearer" + key, forHTTPHeaderField: "Authorization")
        
        }
        let dataTask = URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                return
            }
            guard let data = data else {
                return
            }
            do {
                self.filteredData = self.parseFriend(data: data)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            } catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
        //self.tableView.reloadData()
    }
    
    func SearchBarIsEmpty() -> Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return search.isActive && !SearchBarIsEmpty()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewAfterAddingFriend(notifiction:)), name: .reloadListFriend, object: nil)
    }
    @objc func reloadTableViewAfterAddingFriend (notifiction: Notification) {
        self.friendsList.removeAll()
        self.requestFriends()
    }
    
    
    
}
extension Notification.Name {
    static let reloadListFriend = Notification.Name("reloadFriend")
}





