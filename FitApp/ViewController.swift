//
//  ViewController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 22/10/2018.
//  Copyright © 2018 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class ViewController: UIViewController {
    var userData = User()
  
    @IBAction func signOutButton(_ sender: UIBarButtonItem) {
        KeychainWrapper.standard.removeObject(forKey: "accessToken")
        KeychainWrapper.standard.removeObject(forKey: "userId")
        
        let signInPage = self.storyboard?.instantiateViewController(withIdentifier: "signInNav") as! UINavigationController
        let appDelegate = UIApplication.shared.delegate
        appDelegate?.window??.rootViewController = signInPage
    }
    
   
    
  

    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
      self.requestUserData()
        NotificationCenter.default.addObserver(self, selector: #selector(reloadUserData(notification:)), name: .updateInfo, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "userSettings" {
            
            let navController = segue.destination as! UINavigationController
            let detailUser = navController.topViewController as! ProfileController
            detailUser.flagUserOrFriend = true

            
        }
    }
    
    
    
    private func requestUserData(){
        let userId: String? = KeychainWrapper.standard.string(forKey: "userId")
        let accessToken: String? = KeychainWrapper.standard.string(forKey: "accessToken")
        let url = URL(string: "https://shielded-chamber-25933.herokuapp.com/users/" + userId!)!
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
                
                self.parseUser(data: data)
            }
            catch let error {
                print(error.localizedDescription)
            }
        }
        dataTask.resume()
    }
    
    private func parseUser(data: Data)  {
        var firstName = String()
        var secondName = String()
        var email = String()
        var image = Data()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data)
            if var jsonDict: [String:String ] = jsonObject as? [String : String] {
                firstName = jsonDict["firstName"]!
                secondName = jsonDict["secondName"]!
                email = jsonDict["email"]!
                if  let imageData = jsonDict["image"] {
                    image = Data(imageData.utf8)
                }
                else {
                    image = (UIImage(named: "noPhoto")?.pngData())!
                }
                self.userData = User(email: email, uid: "0", firstName: firstName, secondName: secondName, image: image)
                
            }
            else {
                print("Invalid JSON")
            }
        }
        catch {
            print ("JSON parsing error:"+error.localizedDescription)
            
        }
        
    }
    
    @objc func reloadUserData(notification: NSNotification) {
        self.requestUserData()
    }
    
}


extension Notification.Name {
    static let updateInfo = Notification.Name("updateInfo")
}
