//
//  DonateController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit

class DonateController: UIViewController, UITextViewDelegate, UIPickerViewDelegate {

    //MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    @IBOutlet weak var defaultCharitySwitch: UISwitch!
    @IBOutlet weak var shareToFacebookSwitch: UISwitch!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    
    @IBOutlet weak var charityPicker: UIPickerView!
    @IBOutlet weak var donateMessage: UITextView!

    
    @IBAction func didSelectSwitch(_ sender: UISwitch) {
        if let id = sender.accessibilityIdentifier {
            switch id {
                case "default switch": defaultSwitchPressed(isOn: sender.isOn)
                case "anonymous switch": anonymousSwitchPressed(isOn: sender.isOn)
                case "share switch": shareSwitchPressed(isOn: sender.isOn)
                default: print("Switch not identified")
            }
        }
    }
    
    func defaultSwitchPressed(isOn: Bool) {
        if isOn {
            //hide the picker view
        }
        else {
            //show the picker view
        }
    }
    
    func anonymousSwitchPressed(isOn: Bool) {
        if isOn {
            //turn the share switch off
        }
        else {
            //turn the share switch on
        }
    }
    
    func shareSwitchPressed(isOn: Bool) {
        if isOn {
            //hide the picker view
        }
        else {
            //show the picker view
        }
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        donateMessage.text = ""
        donateMessage.textColor = UIColor.black
    }
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        donateMessage.delegate = self
        charityPicker.delegate = self

        //nav bar for reveal view controller
        connectRevealVC()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
