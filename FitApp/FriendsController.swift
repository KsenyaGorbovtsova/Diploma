//
//  FriendsController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 14/04/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//
import SwiftKeychainWrapper
import UIKit
class Friends: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate {
    @IBOutlet weak var addFriendsToNewPractice: UIBarButtonItem!
    
    
    @IBOutlet weak var navBarFriends: UINavigationItem!
    
    @IBOutlet weak var cancelAddFriendToNewPractice: UIBarButtonItem!
    var flagCreateNewPractice = false
    var flagChooseForPractice = false
    var flagInviteFriends = false
    var invitePractice = String()
  
    var friendsList = [User]()
    var chosenFriends = [String:String]()
    var search = UISearchController(searchResultsController: nil)
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround() 
        self.title = "Друзья"
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
         navigationController?.navigationBar.prefersLargeTitles = true
        self.tableView.allowsMultipleSelection = true
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewAfterAddingFriend(notifiction:)), name: .reloadListFriend, object: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Введите email для поиска"
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = search
        navigationItem.searchController?.searchBar.delegate = self
         UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Done"
        definesPresentationContext = true
        tableView.dataSource = self
        tableView.delegate = self
        requestFriends()
        if flagCreateNewPractice == false {
            self.navBarFriends.rightBarButtonItems = nil
            self.navBarFriends.leftBarButtonItem = nil
        }
       
        else {
            self.navBarFriends.rightBarButtonItem = self.addFriendsToNewPractice
            self.addFriendsToNewPractice.title = "Добавить"
            self.navBarFriends.leftBarButtonItem = self.cancelAddFriendToNewPractice
            self.cancelAddFriendToNewPractice.title = "Cancel"
        }
    }
    @objc func refresh(){
        NotificationCenter.default.post(name: .reloadListFriend, object: nil)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    @IBAction func addFriendsToNewPractice(_ sender: UIBarButtonItem) {
        self.selected()
        NotificationCenter.default.post(name: .chosenfriends, object: nil, userInfo: chosenFriends)
        dismiss(animated: true, completion: nil)
    }
    
    private func selected () {
        if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.chosenFriends[self.friendsList[x[1]].email] = self.friendsList[x[1]].uid
            }
        }
    }
    
    
    
    
    
    @IBAction func cancelAddingFriendsToNewPractice(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
    private func requestFriends() {
        if isInternetAvailable() {
        let userid: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + userid! + "/friends")!
        var request = URLRequest(url:url)
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
        
        else {
            DisplayWarnining(warning: "проверьте подключение к интернету", title: "Упс!", dismissing: false, sender: self)
        }
    }
    private func parseFriend(data: Data) -> [User] {
        var image = Data()
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        var userList = [User]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if jsonObject as? [Dictionary<String, Any>] != nil {
                for x in jsonObject as! [Dictionary<String,String>] {
                    let uid = x["id"]
                    if uid == userId || !(friendsList.filter{$0.uid == uid}).isEmpty {
                        continue
                    }
                    let firstName = x["firstName"]
                    let secondName = x["secondName"]
                    let email = x["email"] 
                    if  let imageData = x["image"] {
                        image = Data(imageData.utf8)
                    }
                    else {
                        image = (UIImage(named: "noPhoto")?.pngData())!
                    }
                    let newFriend = User(email: email!, uid: uid!, firstName: firstName!, secondName: secondName!, image: image )
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
            if self.filteredData.count == 0 {
                
                tableView.noCellsView(title: "🔍 Пользователи не найдены", message: "Проверьте написание email пользователя", image: "shark")
            }
            else {
                tableView.restore()
            }
             return self.filteredData.count
        }
        else {
            if self.friendsList.count == 0 {
                tableView.noCellsView(title: "У вас нет добавленных пользователей", message: "Потяните вниз для поиска", image: "shark")
            }
            else {
                tableView.restore()
            }
            return self.friendsList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
      
        if self.flagCreateNewPractice == false  {
            cell.selectionStyle = .none
        } else {
            cell.selectionStyle = .gray
        }
        if !isFiltering()  {
            
        let friend: User = self.friendsList[indexPath.row]
            if self.chosenFriends.values.contains(friend.uid) {
                cell.backgroundColor =  UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)

            }
            else {
                cell.backgroundColor = UIColor.white
                
            }
        cell.textLabel?.text = friend.email
        cell.detailTextLabel?.text = String(friend.firstName + " " + friend.secondName)
        
        return cell
        }
        else if isFiltering() {
            if filteredData.count != 0 {
                
            let friend: User = self.filteredData[indexPath.row]
                
                if self.chosenFriends.values.contains(friend.uid) {
                    cell.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
                   
                }
                else {
                    cell.backgroundColor = UIColor.white
                    
                }
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
        if isFiltering()  {//&& self.flagInviteFriends == false {
        let addFriend = UITableViewRowAction(style: .normal, title: "Добавить в друзья") {
            (action, indexPath) in
            let addId = self.filteredData[indexPath.row].uid
            self.addOrDeleteFriendToUser(idFriend: addId, action: "Add")
            self.friendsList.append(self.filteredData[indexPath.row])
           // let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath)
            let cell = tableView.cellForRow(at: indexPath)
            cell?.backgroundColor = UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
            cell?.textLabel?.textColor = UIColor.lightGray
            cell?.detailTextLabel?.textColor = UIColor.lightGray
           
        }
        addFriend.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        return [addFriend]
        }
        else if !isFiltering() && self.flagInviteFriends == true  {
            let addFriend = UITableViewRowAction(style: .normal, title: "Отправить тренировку") {
                (action, indexPath) in
                let addId = self.friendsList[indexPath.row].uid
                
               
                let pract = AddNewPractice()
                pract.addPracticeToUsers(idPractice: self.invitePractice, idsUsers: ["0" : addId])
               
               
                let cell = tableView.cellForRow(at: indexPath)
                cell?.backgroundColor = UIColor.init(displayP3Red: 0.78, green:0.78, blue:0.91, alpha: 1)
                cell?.textLabel?.textColor = UIColor.lightGray
                cell?.detailTextLabel?.textColor = UIColor.lightGray
                
                
            }
            addFriend.backgroundColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
            return [addFriend]
        }
        else {
            let deleteFriend = UITableViewRowAction(style: .destructive, title: "Удалить") {
                (action, indexPath) in
                let deleteId = self.friendsList[indexPath.row].uid
                self.addOrDeleteFriendToUser(idFriend: deleteId, action: "Delete")
                self.friendsList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            return [deleteFriend]
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        if self.flagCreateNewPractice == false || self.flagInviteFriends == false {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        else {
            cell.selectionStyle = .default
            cell.accessoryType = .checkmark
        }
        if cell.backgroundColor == UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1) {
            cell.selectionStyle = .none
            cell.accessoryType = .none
        }
        
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        if self.flagCreateNewPractice == false {
            return true
        }
        else {
            return false
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier == "userData" {
                let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
               // let navController = segue.destination as! UINavigationController
                //let detailFriend = navController.topViewController as! ProfileController
                let detailFriend: ProfileController = segue.destination as! ProfileController
                var userId = ""
                var firstName = ""
                var secondName = ""
                var email = ""
                var image = Data()
                var addFlag = false
                if isFiltering() {
                    userId = self.filteredData[indexPath!.row].uid
                    firstName = self.filteredData[indexPath!.row].firstName
                    secondName = self.filteredData[indexPath!.row].secondName
                    email = self.filteredData[indexPath!.row].email
                    image = self.filteredData[indexPath!.row].image
                }
                else {
                    userId = self.friendsList[indexPath!.row].uid
                    firstName = self.friendsList[indexPath!.row].firstName
                    secondName = self.friendsList[indexPath!.row].secondName
                    email = self.friendsList[indexPath!.row].email
                    image = self.friendsList[indexPath!.row].image
                    addFlag = true
                }
           
                detailFriend.idFriend = userId
                detailFriend.firstName = firstName
                detailFriend.secondName = secondName
                detailFriend.email = email
                detailFriend.image = image
                detailFriend.flagAddedFriend = addFlag
                detailFriend.fromFriend = true
                if self.flagInviteFriends == true {
                    
                    detailFriend.invitePractice = self.invitePractice
                    detailFriend.flagInvitefriend = true
                }
            
            
        }
    }
   
    func addOrDeleteFriendToUser (idFriend: String, action: String) {
        if isInternetAvailable() {
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
        
        else {
            DisplayWarnining(warning: "проверьте подключение к интернету", title: "Упс!", dismissing: false, sender: self)
        }
        
    }
    func updateSearchResults(for searchController: UISearchController) {
        filterForSearch(search.searchBar.text!)
    }
    var filteredData = [User]()
    func filterForSearch ( _ searchText: String, scope: String = "ALL") {
        if isInternetAvailable() {
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        if searchText == nil || searchText.latinCharactersOnly == false {
            return
        }
        var url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/search?email=\(searchText.lowercased())")
        var request = URLRequest(url: url!) // error если русские буквы
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
        }
        //self.tableView.reloadData()
        
        else {
            DisplayWarnining(warning: "проверьте подключение к интернету", title: "Упс!", dismissing: false, sender: self)
        }
    }
    
    func SearchBarIsEmpty() -> Bool {
        return search.searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        return search.isActive && !SearchBarIsEmpty()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
         NotificationCenter.default.post(name: .reloadListFriend, object: nil)
        /*NotificationCenter.default.addObserver(self, selector: #selector(reloadTableViewAfterAddingFriend(notifiction:)), name: .reloadListFriend, object: nil)*/
    }
    @objc func reloadTableViewAfterAddingFriend (notifiction: Notification) {
        self.friendsList.removeAll()
        self.requestFriends()
        print("work")
    }
    
}

extension Notification.Name {
    static let reloadListFriend = Notification.Name("reloadListFriend")
    }

extension UITableView{
    
    func noCellsView (title: String, message: String, image: String) {
        
        let emptyView = UIView(frame: CGRect(x: self.center.x, y: self.center.y, width: self.bounds.size.width, height: self.bounds.size.height))
        emptyView.backgroundColor =  UIColor.init(displayP3Red: 0.94, green: 0.94, blue: 0.94, alpha: 1)
        let titleLabel = UILabel()
        let messageLabel = UILabel()
        let imageView = UIImageView()
        
        imageView.image = UIImage(named: image)
        
        titleLabel.text = title
        messageLabel.text = message
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        imageView.translatesAutoresizingMaskIntoConstraints = false
        
        titleLabel.textColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1.0)
        messageLabel.textColor = UIColor.init(displayP3Red:0.35, green:0.34, blue:0.84, alpha:1.0)
        
        
        
        titleLabel.font = UIFont(name: "HelveticaNeue-Bold", size: 20)
        messageLabel.font = UIFont(name: "HelveticaNeue", size: 17)
        
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        
        emptyView.addSubview(messageLabel)
        emptyView.addSubview(titleLabel)
        emptyView.addSubview(imageView)
        imageView.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        imageView.bottomAnchor.constraint(equalTo: titleLabel.topAnchor, constant: -20).isActive = true
        //  imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y:100 , width: 20, height: 20)
        titleLabel.centerYAnchor.constraint(equalTo: emptyView.centerYAnchor).isActive = true
        titleLabel.centerXAnchor.constraint(equalTo: emptyView.centerXAnchor).isActive = true
        messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 20).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: emptyView.leftAnchor, constant: 20).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: emptyView.rightAnchor, constant: -20).isActive = true
        
        
        self.backgroundView = emptyView
        self.separatorStyle = .none
        
    }
    
    func restore() {
        self.backgroundView = nil
        self.separatorStyle = .singleLine
    }
}
extension String {
    var latinCharactersOnly: Bool {
        return self.range(of: "\\P{Latin}", options: .regularExpression) == nil
    }
}


