//
//  MainMenuController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class MainMenuController: DataController {

    //TODO: - Should move the popover outlets into a separate view controller, and then change the present popover segue accordingly
    
    //MARK: - Properties and outlets
    var blurView: UIVisualEffectView?
    var blurEffect: UIVisualEffect?
    
    //UI outlets and actions
    @IBOutlet weak var userSetupPopover: UIView!
    @IBAction func dismissPopover(_ sender: UIButton) {
        storeUserInfo()
        dismissUserPopover()
    }
    @IBOutlet weak var phoneField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var charityPreferencePicker: UIPickerView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    //MARK: - Superview and load functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do view setup here.
        emailField.delegate = self
        phoneField.delegate = self
        nameField.delegate = self
        charityPreferencePicker.delegate = self
        charityPreferencePicker.dataSource = self
        
        //temporary
        presentUserSetupPopover()
        
        print(self.revealViewController())
        //nav bar for reveal view controller
        connectRevealVC()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//MARK: - User setup extensions
extension MainMenuController {
    
    /**
     Shows the user setup popover window. First time users add their phone number and email address to complete user sign-up.
     
     Detailed description: creates a nil blur view, shows a popover window, and then animates the showing of the window and blur view, while hiding the navigation bar.
     */
    func presentUserSetupPopover() {
        
        //create blur view with nil effect, add to view
        blurView = UIVisualEffectView()
        blurView?.frame = view.frame
        self.view.addSubview(self.blurView!)
        
        //prepare text fields and picker view
        prepareTextFields()
        preparePickerView()
        
        //show popover
        self.view.addSubview(userSetupPopover)
        userSetupPopover.layer.cornerRadius = 10 //rounded corners
        userSetupPopover.center = self.view.center
        
        //remove reveal view controller access
        disablePanGestureRecognizer()
        
        //make popover transparent and expanded (temporarily)
        userSetupPopover.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
        userSetupPopover.alpha = 0
        
        //animate default popover presentation
        UIView.animate(withDuration: 0.4) {
            
            //apply blur
            self.blurView?.effect = UIBlurEffect(style: .light)
            
            //restore popover defaults
            self.userSetupPopover.alpha = 1
            self.userSetupPopover.transform = CGAffineTransform.identity
            
            //hide navigation bar
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    
    /**
     Remove popover view, save the data user has entered, re-enable reveal VC.
     */
    func dismissUserPopover() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.userSetupPopover.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.userSetupPopover.alpha = 0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.blurView?.effect = nil
        }) { sucesss in

            self.userSetupPopover.removeFromSuperview()
            self.blurView?.removeFromSuperview()
            self.enablePanGestureRecognizer()
        }
    }
    
    /**
     Save the user setup info from the new user popover.
    */
    func storeUserInfo() {
        
        if let facebookID = UserDefaults.standard.string(forKey: "facebookID") {
            let name = nameField.text!
            let phoneNumber = phoneField.text!
            let email = emailField.text!
            let charityPreference = Charities.list[charityPreferencePicker.selectedRow(inComponent: 0)]
            
            //load data
            let settings = ["name": name,
                        "phone number": phoneNumber,
                        "email": email,
                        "charity preference": charityPreference]
        
            //save data
            self.rootRef?.child("users").child(facebookID).updateChildValues(settings)
        }
    }
}

//MARK: - Textfield extensions
extension MainMenuController: UITextFieldDelegate {
    
    func prepareTextFields() {
        nameField.returnKeyType = .next
        nameField.enablesReturnKeyAutomatically = true
        nameField.autocapitalizationType = .words
        nameField.text = UserDefaults.standard.string(forKey: "name")

            
        phoneField.keyboardType = .numberPad
        phoneField.returnKeyType = .next
        phoneField.enablesReturnKeyAutomatically = true
        
        emailField.returnKeyType = .done
        emailField.enablesReturnKeyAutomatically = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        if textField == nameField {
            nameField.resignFirstResponder()
            phoneField.becomeFirstResponder()
        } else if textField == phoneField {
            nameField.resignFirstResponder()
            phoneField.becomeFirstResponder()
        } else if textField == emailField {
            textField.resignFirstResponder()
        }
        return true
    }
    
 }

//MARK: - manage pan gestures
private extension MainMenuController {
    
    /**
     Re-enable the pan gesture recognizer (when popover dismisses)
     */
    func enablePanGestureRecognizer() {
        if let pan = self.revealViewController().panGestureRecognizer() {
            pan.isEnabled = true
        }
    }
    
    /**
     Disable the pan gesture recognizer (when popover shows)
     */
    func disablePanGestureRecognizer() {
        if let pan = self.revealViewController().panGestureRecognizer() {
            pan.isEnabled = false
        }
    }
}

//MARK: - Picker view extensions
extension MainMenuController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func preparePickerView() {
        charityPreferencePicker.selectRow(1, inComponent: 0, animated: false)
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Charities.list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = Charities.list[row]
        if row == 0 {
            return NSAttributedString(string: titleData, attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!,NSForegroundColorAttributeName: UIColor.lightGray])
        }
        return NSAttributedString(string: titleData)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            charityPreferencePicker.selectRow(1, inComponent: 0, animated: true)
        }
    }
}
