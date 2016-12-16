//
//  UserSetupExtensions.swift
//  Coign
//
//  Created by Maximilian Hoffman on 10/29/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation

//MARK: - User setup extensions
extension HomeMenuController: UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //TODO: make this a class function so that it can be called from the login page, remove the role of "new user" node
    /**
     This function is used to test for new users right now. Could be amended in the future to give users info based on when they last opened the app.
     */
    func checkLastLoginDate() {
        
        //if user is new, follow through with new user form
        if (UserDefaults.standard.object(forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue) as? String == FirTree.UserParameter.NewUser.rawValue) {
            
            //show user info form after a second delay
            if #available(iOS 10.0, *) {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false, block: { (timer) in
                    self.presentUserSetupPopover()
                    timer.invalidate()
                })
            } else {
                // Fallback on earlier versions
                Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(presentUserSetupPopover), userInfo: nil, repeats: false)
            }
        }
    }
    
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
        
        //disable pan
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
     Remove popover view after saving the data user has entered, re-enable reveal VC panning.
     */
    func dismissUserPopover() {
        
        //animate popover exit
        UIView.animate(withDuration: 0.4, animations: {
            self.userSetupPopover.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.userSetupPopover.alpha = 0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.blurView?.effect = nil
        }) { sucesss in
            
            //remove popover views and effects
            self.userSetupPopover.removeFromSuperview()
            self.blurView?.removeFromSuperview()
            self.enablePanGestureRecognizer()
        }
    }
    
    /**
     Helper function for saving the user setup info from the new user popover; FirTree.updateuser() does the main work.
     */
    func storeUserInfo() {

        //grab values from text fields
        let name = nameField.text!
        let phoneNumber = phoneField.text!
        let email = emailField.text!
        let charityPreference = charities?[charityPreferencePicker.selectedRow(inComponent: 0)-1] //displace default by 1 to get correct charity
        
        //prep data
        let settings = [FirTree.UserParameter.Name.rawValue: name,
                        FirTree.UserParameter.Phone.rawValue: phoneNumber,
                        FirTree.UserParameter.Email.rawValue: email,
                        FirTree.UserParameter.Charity.rawValue: charityPreference]
        
        //save data to firebase
        FirTree.updateUser(withNewSettings: settings)
        
        //save data to defaults
        UserDefaults.standard.set(charityPreference, forKey: FirTree.UserParameter.Charity.rawValue)
        UserDefaults.standard.set(name, forKey: FirTree.UserParameter.Name.rawValue)
        UserDefaults.standard.set(phoneNumber, forKey: FirTree.UserParameter.Phone.rawValue)
        UserDefaults.standard.set(email, forKey: FirTree.UserParameter.Email.rawValue)
        
        //complete new user login by setting most recent login time (trigger for popover showing)
        let loginTime = Date().shortDate
        FirTree.updateUser(withNewSettings:
            [FirTree.UserParameter.MostRecentLoginDate.rawValue: loginTime])
        UserDefaults.standard.set(loginTime, forKey: FirTree.UserParameter.MostRecentLoginDate.rawValue)

    }
    
    
    //MARK: - Textfield extensions
    func prepareTextFields() {
        nameField.returnKeyType = .next
        nameField.enablesReturnKeyAutomatically = true
        nameField.autocapitalizationType = .words
        nameField.text = UserDefaults.standard.string(forKey: FirTree.UserParameter.Name.rawValue)
        
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
    
    //MARK: - Manage pan gestures extension
    
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
        if let pan = revealViewController().panGestureRecognizer() {
            pan.isEnabled = false
        }
    }
    
    //MARK: - Picker view extensions
    
    var charities: [String]? {
        if let path = Bundle.main.path(forResource: "CharityList", ofType: "plist") {
            return NSArray(contentsOfFile: path) as? [String]
        } else {
            return nil
        }
    }
    
    //initialize picker view at the first real entry
    func preparePickerView() {
        charityPreferencePicker.selectRow(1, inComponent: 0, animated: false)
    }
    
    //only one section
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //data is in the Constants file
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if charities?.count != nil {
            return charities!.count + 1
        }
        else {
            return 0
        }
        
    }
    
    //fill the rows with charity data
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        if charities != nil {
            if row == 0 { //grey out the label
                return NSAttributedString(string: "default charity:", attributes: [NSFontAttributeName:UIFont(name: "Helvetica", size: 10.0)!,NSForegroundColorAttributeName: UIColor.lightGray])
            }
            else {
                return NSAttributedString(string: charities![row-1])
            }
        }
        else {
            return nil
        }
    }
    
    //prevent user from selecting the grey label
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 0 {
            charityPreferencePicker.selectRow(1, inComponent: 0, animated: true)
        }
    }
}
