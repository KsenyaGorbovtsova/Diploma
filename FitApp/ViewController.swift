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
    
    @IBOutlet weak var menu: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewNutrition: UITextView!
    @IBOutlet weak var textViewMesurement: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.textView.isHidden = true
        self.menu.isHidden = true
        self.textViewMesurement.isHidden = true
        self.textViewNutrition.isHidden = true
    }

    @IBAction func openMenu(_ sender: Any) {
        self.textView.isHidden = true
        self.textShowing = false
        self.textShowingNutrition = false
        self.textViewNutrition.isHidden  = true
        self.textShowingMeasurement = false
        self.textViewMesurement.isHidden = true
        self.menu.isHidden = false
        self.view.bringSubviewToFront(menu)
        if (menuShowing) {
            self.menu.isHidden = true
            
            //LeadingConstraint.constant = -150
            /*UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            })*/
        } else {
            self.menu.isHidden = false
            /*LeadingConstraint.constant = 0
            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            
            })*/
        }
        menuShowing = !menuShowing
    }
    
    @IBAction func openTraining(_ sender: Any) {
        self.menu.isHidden = true
        self.menuShowing = false
        self.textShowingMeasurement = false
        self.textViewMesurement.isHidden = true
        self.textShowingNutrition = false
        self.textViewNutrition.isHidden = true
        //self.textView.isHidden = true
        if (textShowing) {
            self.textView.isHidden = true
        }
        else{
            self.textView.isHidden = false
        }
        textShowing = !textShowing
    }
    
    @IBAction func openNutriton(_ sender: Any) {
        self.menu.isHidden = true
        self.menuShowing = false
        self.textShowingMeasurement = false
        self.textViewMesurement.isHidden = true
        self.textShowing = false
        self.textView.isHidden = true
        //self.textView.isHidden = true
        if (textShowingNutrition) {
            self.textViewNutrition.isHidden = true
        }
        else{
            self.textViewNutrition.isHidden = false
        }
        textShowingNutrition = !textShowingNutrition
    }
    
    @IBAction func openMeasurement(_ sender: Any) {
        self.menu.isHidden = true
        self.menuShowing = false
        self.textShowingNutrition = false
        self.textViewNutrition.isHidden = true
        self.textShowing = false
        self.textView.isHidden = true
        //self.textView.isHidden = true
        if (textShowingMeasurement) {
            self.textViewMesurement.isHidden = true
        }
        else{
            self.textViewMesurement.isHidden = false
        }
        textShowingMeasurement = !textShowingMeasurement
    }
    
}

