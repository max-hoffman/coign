//
//  MainMenuController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class MainMenuController: UIViewController {

    //properties
    var blurView: UIVisualEffectView?
    var blurEffect: UIVisualEffect?
    
    //UI outlets and actions
    @IBOutlet weak var userSetupPopover: UIView!
    @IBAction func dismissPopover(_ sender: UIButton) {
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
        
        presentUserSetupPopover()
        
        //MARK: this should be standardized so we're not duplicating code
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
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
    public func presentUserSetupPopover() {
        
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
     Remove popover view, save the data user has entered.
     */
    public func dismissUserPopover() {
        
        UIView.animate(withDuration: 0.4, animations: {
            self.userSetupPopover.transform = CGAffineTransform.init(scaleX: 1.5, y: 1.5)
            self.userSetupPopover.alpha = 0
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            self.blurView?.effect = nil
        }) { sucesss in
            self.userSetupPopover.removeFromSuperview()
            self.blurView?.removeFromSuperview()
        }
    }
}

//MARK: - Textfield extensions
extension MainMenuController: UITextFieldDelegate {
    
    func prepareTextFields() {
        nameField.returnKeyType = .next
        nameField.enablesReturnKeyAutomatically = true
        nameField.autocapitalizationType = .words
        
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



//MARK: - Textfield extensions
extension MainMenuController: UIPickerViewDelegate {
    
    func preparePickerView() {
        
    }
}
