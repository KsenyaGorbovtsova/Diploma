//
//  AllExerciseController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 12/03/2019.
//  Copyright © 2019 Gorbovtsova Ksenya. All rights reserved.
//

import Foundation
import UIKit

class AllExerciseControler: UITableViewController, UISearchResultsUpdating, UISearchBarDelegate  {
    
    
    
    var resultSearch = UISearchController(searchResultsController: nil)
   
    var exerciseList = [exercise]()
    var selectedExercises = [String:String] ()
   
    var filteredTableData = [exercise]()
    var tappededit = false
   
    var preparation = [exercise]()
    var flagEditTapped = false
    var detailExerFlag = false
    var tabBar = true
    
    @IBOutlet weak var addExrToBase: UIBarButtonItem!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var editButton: UIBarButtonItem!
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.tintColor = UIColor.init(displayP3Red: 0.35, green:0.34, blue:0.84, alpha:1)
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        self.refreshControl = refreshControl
        self.hideKeyboardWhenTappedAround() 
        NotificationCenter.default.addObserver(self, selector: #selector(reloadExrBase(notification:)), name: .reloadExrBase, object: nil)
        if self.tabBar == true {
            self.navigationItem.rightBarButtonItems = [self.addExrToBase]
        } else
        {
             self.navigationItem.rightBarButtonItems = [self.doneButton, self.editButton]
        }
         navigationController?.navigationBar.prefersLargeTitles = true
        resultSearch.searchResultsUpdater = self
        resultSearch.obscuresBackgroundDuringPresentation = false
        resultSearch.searchBar.placeholder = "Search Exercises"
        navigationItem.searchController?.hidesNavigationBarDuringPresentation = false
        navigationItem.searchController = resultSearch
        navigationItem.searchController?.searchBar.delegate = self
        definesPresentationContext = true
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Done"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.allowsMultipleSelection = true
       
        requestExercises()
        
    }
    @objc func refresh(){
        NotificationCenter.default.post(name: .reloadExrBase, object: nil)
        tableView.reloadData()
        refreshControl?.endRefreshing()
    }
    private func selected () {
        if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.selectedExercises[self.exerciseList[x[1]].name] = self.exerciseList[x[1]].id
                //self.selectedExercises.append(self.exerciseList[x[1]].uid)
                
            }
        }
    }
        
    @IBAction func doneAddingExercises(_ sender: UIBarButtonItem) {
        //dismiss(animated: true, completion: {
        if self.tappededit == false {
            if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.selectedExercises[self.exerciseList[x[1]].name] = self.exerciseList[x[1]].id
                }
            }}
           else {
             for x in self.preparation.reversed() {
                    print(x.name)
                self.selectedExercises[x.name] = x.id
                    
                    self.tappededit = false
                }
            }
               // print(selectedExercises)
                if self.detailExerFlag == false {
                    NotificationCenter.default.post(name:.chosenExercise, object: nil, userInfo: selectedExercises)
                }
                else if detailExerFlag == true {
                    NotificationCenter.default.post(name: .searchExerAndAdd, object: nil, userInfo: selectedExercises)
                }
            
            self.navigationController?.popViewController(animated: true)
        //})
    }
    
    
    @IBAction func reorderRows(_ sender: Any) {
        self.tappededit = !self.tappededit
        self.selected()
        self.preparation = self.exerciseList.filter({self.selectedExercises.values.contains($0.id)})
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        isEditing = !isEditing
    }
    
    
   /* @IBAction func cancel(_ sender: UIBarButtonItem) {
         dismiss(animated: true, completion: nil)
    }*/
    

    private func parseExercises (data: Data) {
        let decoder = JSONDecoder()
        let resp = try! decoder.decode([exercise].self, from: data)
        self.exerciseList = self.exerciseList + resp
        
    }
    private func requestExercises()  {
        if isInternetAvailable() {
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/exercises/")!
        let dataTask = URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                error == nil,
            (response as? HTTPURLResponse)?.statusCode == 200,
            let data = data
                else {
                    print("network err")
                    return
            }
            self.parseExercises(data: data)
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
        dataTask.resume()
        }
        
        else {
            DisplayWarnining(warning: "проверьте подключение к интернету", title: "Упс!", dismissing: false, sender: self)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.tappededit == false && !isFiltering() {
            return self.exerciseList.count
        }
        else if self.tappededit == false && isFiltering() {
             return filteredTableData.count
        }
        else {
            return  self.preparation.count
        }
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AllExerciseCell", for: indexPath)
        
        if self.tappededit == false && !isFiltering() {
            let exercise: exercise = self.exerciseList[indexPath.row]
            cell.textLabel?.text = exercise.name
            if self.tabBarController != nil {
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
            let selectedIndexPaths = tableView.indexPathsForSelectedRows
            let rowIsSelected = selectedIndexPaths != nil && selectedIndexPaths!.contains(indexPath)
            cell.accessoryType = rowIsSelected ? .checkmark : .none
            }
            return cell
        }
        else if self.tappededit == false && isFiltering() {
            let exercise: exercise = self.filteredTableData[indexPath.row]
            cell.textLabel?.text = exercise.name
            return cell
        }
            else if indexPath.row <= self.preparation.count-1 && self.tappededit == true   {
            let exercise: exercise = self.preparation[indexPath.row]
            cell.textLabel?.text = exercise.name
            return cell
        }
        else {
            return cell
        }
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let cell = tableView.cellForRow(at: indexPath)!
        if self.tabBar == true {
            let cell = tableView.cellForRow(at: indexPath)!
            cell.selectionStyle = .none
             cell.accessoryType = .none
            performSegue(withIdentifier: "showFromFirstTab", sender: indexPath.row)
        }else {
            cell.accessoryType = .checkmark
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showFromFirstTab" {
            //let indexPath = self.tableView.indexPath(for: (sender as! UITableViewCell))
            let exercise = self.exerciseList[sender as! Int]
            let showExr: DetailExercise = segue.destination as! DetailExercise
            showExr.exercise = exercise
            showExr.flagBar = true
        }
        if segue.identifier == "newExrFromTab" {
            let createExr = segue.destination as! AddNewExercise
            createExr.flagTabBar = true
        }
    }
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)!
        cell.accessoryType = .none
    }
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let exerciseToMove = self.preparation[sourceIndexPath.row]
        self.preparation.remove(at: sourceIndexPath.row)
        self.preparation.insert(exerciseToMove, at: destinationIndexPath.row)
        
    }
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
            return UITableViewCell.EditingStyle.none
    
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        filterForSearch(resultSearch.searchBar.text!)
        
    }
    func SearchBarIsEmpty() -> Bool {
        return resultSearch.searchBar.text?.isEmpty ?? true
    }
    func filterForSearch (_ searchText: String, scope: String = "ALL") {
        filteredTableData = exerciseList.filter ({(exercise: exercise) -> Bool in
            return exercise.name.lowercased().contains(searchText.lowercased())
        })
        
        self.tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return resultSearch.isActive && !SearchBarIsEmpty()
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        if  let selectedItems = self.tableView.indexPathsForSelectedRows {
            for x in selectedItems {
                self.selectedExercises[self.filteredTableData[x[1]].name] = self.filteredTableData[x[1]].id
            }
        }
        //print("searchBarCancelButtonClicked")
    }
    @objc func reloadExrBase (notification: Notification) {
        self.exerciseList.removeAll()
        self.requestExercises()
    }
    
}
extension Notification.Name {
    static let reloadExrBase = Notification.Name("reloadExrBase")
}
