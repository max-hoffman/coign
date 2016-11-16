//
//  DonateController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit
import CoreLocation

class DonateController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, CLLocationManagerDelegate {

    //MARK: - Constants 
    var charities: [String]? {
        if let path = Bundle.main.path(forResource: "CharityList", ofType: "plist") {
            return NSArray(contentsOfFile: path) as? [String]
        } else {
            return nil
        }
    }
    var currentUserLocation:CLLocationCoordinate2D? = nil
    var locationManager: CLLocationManager? = nil
    
    //MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var defaultCharitySwitch: UISwitch!
    @IBOutlet weak var shareToFacebookSwitch: UISwitch!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    @IBOutlet weak var donateMessage: UITextView!
    @IBOutlet weak var donateFor: UITextField!
    @IBOutlet weak var charityPicker: UIPickerView!
    @IBOutlet weak var charityPickerView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    
    //MARK: - Post methods
    
    //TODO: This needs to go inside the plaid completion block
    private func createPost() {
        
        if let user = UserDefaults.standard.object(forKey: FirTree.UserParameter.Id.rawValue) as? String, let recipient = donateFor.text {

            var charity: String? = nil
            if defaultCharitySwitch.isOn {
                charity = UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as! String?
            }
            else {
                charity = charities?[charityPicker.selectedRow(inComponent: 0)]
            }
            
            //TODO: need a function to find if we can update the specified user, for now it's left to be nil
                
            let post : [String: Any] = [
                FirTree.UserParameter.Id.rawValue : user ,
                FirTree.PostParameter.Charity.rawValue : charity!,
                FirTree.PostParameter.Recipient.rawValue : recipient,
                FirTree.PostParameter.Message.rawValue : donateMessage.text,
                FirTree.PostParameter.DonationAmount.rawValue : 1,
                FirTree.PostParameter.TimeStamp.rawValue : Date.timeIntervalSinceReferenceDate,
                FirTree.PostParameter.SharedToFacebook.rawValue : shareToFacebookSwitch.isOn,
                FirTree.PostParameter.Anonymous.rawValue : anonymousSwitch.isOn,
                FirTree.PostParameter.Location.rawValue : String(describing: currentUserLocation)
            ]
            
            //complete the post by updating the FirTree
            FirTree.newPost(post: post, location: currentUserLocation, userID: user, recipientID: nil)
            
        }
    }
    
    //MARK: - Verfiy methods
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        presentVerifyPopover()
    }
    
    private func presentVerifyPopover() {
        //TODO: This is where the stripe/plaid verification needs to go
        
        //for now just have a donation alert
        let donationAlert = UIAlertController(title: "Post Coign", message: "Press continue to post this Coign", preferredStyle: UIAlertControllerStyle.alert)
        donationAlert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default , handler: {
            [weak weakSelf = self]
            (action: UIAlertAction) -> Void in
            
            weakSelf?.createPost()
        }))
        donationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(donationAlert, animated: true, completion: nil)
    }
    
    //MARK:- Switch methods
    
    @IBAction private func didSelectSwitch(_ sender: UISwitch) {
        if let id = sender.accessibilityIdentifier {
            switch id {
                case "default switch": defaultSwitchPressed(isOn: sender.isOn)
                case "anonymous switch": anonymousSwitchPressed(isOn: sender.isOn)
                default: print("Switch not identified")
            }
        }
    }
    
    private func defaultSwitchPressed(isOn: Bool) {
        UIView.animate(withDuration: 0.3, animations: {
            if isOn {
                //hide the picker view
                self.charityPickerView.isHidden = true
            }
            else {
                //show the picker view
                self.charityPickerView.isHidden = false
            }
        })
    }
    
    private func anonymousSwitchPressed(isOn: Bool) {
        if isOn {
            //turn the share switch off
            shareToFacebookSwitch.isOn = false
            shareToFacebookSwitch.isEnabled = false
        }
        else {
            //turn the share switch on
            shareToFacebookSwitch.isOn = true
            shareToFacebookSwitch.isEnabled = true
        }
    }
    
    //MARK:- Textview methods
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Insert message here. " {
            donateMessage.text = ""
            UIView.animate(withDuration: 0.3, animations: {self.verifyView.isHidden = false})
        }
    }
    
    /* Reformats the textview size so that it fits the text it contains; i.e. after a line break the text view will grow by one row */
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame;
    }

    
    private func textView(textView: UITextView, shouldChangeTextInRange range: Range<String.Index>, replacementText text: String) -> Bool {
        let newText = textView.text.replacingCharacters(in: range as Range<String.Index>, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < 200;
    }
    
    //MARK: - Pickerview methods

    //draw from array of charities for row titles
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: charities?[row] ?? "")
    }
    
    //only one section
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //data is in the Constants file
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return charities?.count ?? 0
    }

    //MARK: - Location methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = manager.location?.coordinate
        print("locations = \(currentUserLocation?.latitude) \(currentUserLocation?.longitude)")
        locationManager?.stopUpdatingLocation()
    }
    
    private func requestLocationUpdate() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager?.startUpdatingLocation()
        }
    }
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        donateMessage.delegate = self
        charityPicker.delegate = self

        // Create a location manager object
        locationManager = CLLocationManager()
        
        // Set the delegate
        locationManager?.delegate = self
        
        //get quick location update
        requestLocationUpdate()
        
        //nav bar for reveal view controller
        connectRevealVC()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //hide the picker view
        charityPickerView.isHidden = true
        donateMessage.layer.cornerRadius = 8
        verifyButton.layer.cornerRadius = 15
        verifyView.isHidden = true
        
        

        // Ask for Authorisation from the User.
        locationManager?.requestAlwaysAuthorization()
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
