//
//  ViewController.swift
//  FitApp
//
//  Created by Gorbovtsova Ksenya on 22/10/2018.
//  Copyright © 2018 Gorbovtsova Ksenya. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var menuShowing = false
    @IBOutlet weak var LeadingConstraint: NSLayoutConstraint!
    
    var textShowing = false
    var textShowingNutrition = false
    var textShowingMeasurement = false
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var barbellButton: UIButton!
    @IBOutlet weak var dietButton: UIButton!
    @IBOutlet weak var measureButton: UIButton!
    
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewNutrition: UITextView!
    @IBOutlet weak var textViewMesurement: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        //self.textView.isHidden = true
        self.textView.clipsToBounds = false
        self.textView.layer.shadowOpacity = 0.8
        self.textView.layer.cornerRadius = self.textView.frame.size.height/15
        self.textView.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.textView.layer.shadowRadius = 5.0
        self.textView.layer.shadowColor = UIColor.gray.cgColor
        
        
        self.menu.isHidden = true
        self.menu.clipsToBounds = false
        self.menu.layer.shadowOpacity = 0.8
        self.menu.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.menu.layer.shadowRadius = 5.0
        self.menu.layer.shadowColor = UIColor.gray.cgColor
        
        //self.textViewMesurement.isHidden = true
        self.textViewMesurement.clipsToBounds = false
        self.textViewMesurement.layer.shadowOpacity = 0.8
        self.textViewMesurement.layer.cornerRadius = self.textViewMesurement.frame.size.height/15
        self.textViewMesurement.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.textViewMesurement.layer.shadowRadius = 5.0
        self.textViewMesurement.layer.shadowColor = UIColor.gray.cgColor
        
        //self.textViewNutrition.isHidden = true
        self.textViewNutrition.clipsToBounds = false
        self.textViewNutrition.layer.shadowOpacity = 0.8
        self.textViewNutrition.layer.cornerRadius = self.textViewNutrition.frame.size.height/15
        self.textViewNutrition.layer.shadowOffset = CGSize(width: 3.0, height: 3.0)
        self.textViewNutrition.layer.shadowRadius = 5.0
        self.textViewNutrition.layer.shadowColor = UIColor.gray.cgColor
    }
    
    @IBAction func openMenu(_ sender: Any) {
        
        if (self.textShowing == true)
        {
            self.textShowing = false
            animateClosingTraining()
        }
        if (self.textShowingNutrition == true)
        {
            self.textShowingNutrition = false
            animateClosingNutrition()
        }
        if (self.textShowingMeasurement == true)
        {
            self.textShowingMeasurement = false
            animateClosingMeasurement()
        }
        
        self.menu.isHidden = false
        self.view.bringSubviewToFront(menu)
        if (menuShowing) {
            animateClosingMenu()
        } else {
           animateOpeningMenu()
        }
        menuShowing = !menuShowing
    }
    

    @IBAction func openTraining(_ sender: Any) {
        
        
        if (self.menuShowing == true)
        {
            self.menuShowing = false
            animateClosingMenu()
        }
        if (self.textShowingMeasurement == true)
        {
            self.textShowingMeasurement = false
            animateClosingMeasurement()
        }
        
        //self.textViewMesurement.isHidden = true
        if (self.textShowingNutrition == true)
        {
            self.textShowingNutrition = false
            animateClosingNutrition()
        }
        
        //self.textViewNutrition.isHidden = true
        //self.textView.isHidden = true
        if (textShowing) {
            animateClosingTraining()
            
            //self.textView.isHidden = true //спрятали
        }
        else{
            animateOpeningTraining()
            self.textView.isHidden = false //проявили
            
        }
        textShowing = !textShowing
    }
    

    @IBAction func openNutriton(_ sender: Any) {
        if (self.menuShowing == true)
        {
            self.menuShowing = false
            animateClosingMenu()
        }
        if (self.textShowing == true)
        {
            self.textShowing = false
            animateClosingTraining()
        }
        
        //self.textViewMesurement.isHidden = true
        if (self.textShowingMeasurement == true)
        {
            self.textShowingMeasurement = false
            animateClosingMeasurement()
        }
        //self.textView.isHidden = true
        //self.textView.isHidden = true
        if (textShowingNutrition) {
            //self.textViewNutrition.isHidden = true
            animateClosingNutrition()
            
        }
        else{
            animateOpeningNutrition()
            self.textViewNutrition.isHidden = false
            
        }
        textShowingNutrition = !textShowingNutrition
    }
    
    
    @IBAction func openMeasurement(_ sender: Any) {
        if (self.menuShowing == true)
        {
            self.menuShowing = false
            animateClosingMenu()
        }
        if (self.textShowingNutrition == true)
        {
            self.textShowingNutrition = false
            animateClosingNutrition()
        }
        if (self.textShowing == true)
        {
            self.textShowing = false
            animateClosingTraining()
        }
        //self.textViewNutrition.isHidden = true
        
        //self.textView.isHidden = true
        //self.textView.isHidden = true
        if (textShowingMeasurement) {
            //self.textViewMesurement.isHidden = true
            animateClosingMeasurement()
        }
        else{
            animateOpeningMeasurement()
           // self.textViewMesurement.isHidden = false
        }
        textShowingMeasurement = !textShowingMeasurement
    }
  
    func animateOpeningTraining(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textView.frame
            top.origin.y -= (top.size.height)+8
            self.textView.frame = top
        })
        self.barbellButton.backgroundColor = UIColor.white
        self.barbellButton.layer.cornerRadius = self.barbellButton.bounds.size.width / 2
        
        
    }
    func animateClosingTraining(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textView.frame
            top.origin.y += (top.size.height)+8
            self.textView.frame = top
        })
        self.barbellButton.backgroundColor = UIColor.clear
    }
    func animateOpeningNutrition(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textViewNutrition.frame
            top.origin.y -= (top.size.height)+8
            self.textViewNutrition.frame = top
        })
        self.dietButton.backgroundColor = UIColor.white
        self.dietButton.layer.cornerRadius = self.dietButton.bounds.size.width / 2
    }
    func animateClosingNutrition(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textViewNutrition.frame
            top.origin.y += (top.size.height)+8
            self.textViewNutrition.frame = top
        })
        self.dietButton.backgroundColor = UIColor.clear
    }
    func animateClosingMeasurement(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textViewMesurement.frame
            top.origin.y += (top.size.height)+8
            self.textViewMesurement.frame = top
        })
        self.measureButton.backgroundColor = UIColor.clear
    }
    func animateOpeningMeasurement(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var top = self.textViewMesurement.frame
            top.origin.y -= (top.size.height)+8
            self.textViewMesurement.frame = top
        })
        self.measureButton.backgroundColor = UIColor.white
        self.measureButton.layer.cornerRadius = self.measureButton.bounds.size.width / 2
    }
    func animateClosingMenu(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var side = self.menu.frame
            side.origin.x -= (side.size.width)
            self.menu.frame = side
        })
    }
    func animateOpeningMenu(){
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .curveEaseInOut, animations: {
            var side = self.menu.frame
            side.origin.x += (side.size.width)
            self.menu.frame = side
        })
    }
}


