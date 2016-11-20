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
    let MAX_POST_CHARACTERS: Int = 200
    let ANIMATION_DURATION: TimeInterval = 0.3
    let MESSAGE_PLACEHOLDER_TEXT: String = "Insert message here: "
    let DONATE_PLACEHOLDER_TEXT: String = "ex: Jane Doe"
    let VERIFY_BUTTON_DELAY: TimeInterval = 0.4
    let BACKGROUND_IMAGE_LINK: String = "coign_background_02"
    
    //MARK: - Outlets
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var defaultCharitySwitch: UISwitch!
    @IBOutlet weak var shareToFacebookSwitch: UISwitch!
    @IBOutlet weak var anonymousSwitch: UISwitch!
    @IBOutlet weak var donateMessage: UITextView!
    @IBOutlet weak var donateFor: UITextField!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var charityPicker: UIPickerView!
    @IBOutlet weak var charityPickerView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var dollarSlider: UISlider!
    
    @IBOutlet weak var backgroundView: UIImageView!
    @IBOutlet weak var vibrancyView: UIVisualEffectView!
    //MARK: - Post methods
    
    //TODO: This needs to go inside the plaid completion block
    private func createPost() {
        
        if let userUID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as? String, let recipient = donateFor.text, let name = UserDefaults.standard.object(forKey: FirTree.UserParameter.Name.rawValue) {

            var charity: String? = nil
            if defaultCharitySwitch.isOn {
                charity = UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as! String?
            }
            else {
                charity = charities?[charityPicker.selectedRow(inComponent: 0)]
            }
            
            //TODO: need a function to find if we can update the specified user, for now it's just whatever name is passed in
                
            let post : [String: Any] = [
                FirTree.PostParameter.DonorName.rawValue: name,
                FirTree.PostParameter.DonorUID.rawValue : userUID,
                FirTree.PostParameter.Charity.rawValue : charity!,
                FirTree.PostParameter.RecipientName.rawValue : recipient,
                FirTree.PostParameter.Message.rawValue : donateMessage.text,
                FirTree.PostParameter.DonationAmount.rawValue : dollarSlider.value,
                FirTree.PostParameter.TimeStamp.rawValue : Date.timeIntervalSinceReferenceDate,
                FirTree.PostParameter.SharedToFacebook.rawValue : shareToFacebookSwitch.isOn,
                FirTree.PostParameter.Anonymous.rawValue : anonymousSwitch.isOn
            ]
            
            //complete the post by updating the FirTree
            FirTree.newPost(post: post, location: currentUserLocation, userID: userUID, recipientID: nil)
        }
    }

    //button color returned to normal after the popover appears
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        verifyButton.backgroundColor = CustomColor.darkGreen.withAlphaComponent(0.5)
        presentVerifyPopover()
        let _ = Timer.scheduledTimer(withTimeInterval: VERIFY_BUTTON_DELAY, repeats: false) {timer in
            self.verifyButton.backgroundColor = CustomColor.darkGreen.withAlphaComponent(1.0)
            timer.invalidate()
        }
    }
    
    @IBAction func verifyButtonReleased(_ sender: UIButton) {
        verifyButton.backgroundColor = CustomColor.darkGreen.withAlphaComponent(1.0)
    }
    
    
    private func presentVerifyPopover() {
        //TODO: This is where the stripe/plaid verification needs to go
        
        //for now just have a donation alert
        let donationAlert = UIAlertController(title: "Post Coign", message: "Press continue to post this Coign", preferredStyle: UIAlertControllerStyle.alert)
        donationAlert.addAction(UIAlertAction(title: "Continue", style: UIAlertActionStyle.default , handler: {
            [weak weakSelf = self]
            (action: UIAlertAction) -> Void in
            
            weakSelf?.createPost()
            weakSelf?.resetPage()
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
        if textView.text == MESSAGE_PLACEHOLDER_TEXT {
            donateMessage.text = ""
            UIView.animate(withDuration: ANIMATION_DURATION, animations: {self.verifyView.isHidden = false})
        }
    }
    
    /* Reformats the textview size so that it fits the text it contains; i.e. after a line break the text view will grow by one row */
    func textViewDidChange(_ textView: UITextView) {
        let fixedWidth = textView.frame.size.width
        textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        let newSize = textView.sizeThatFits(CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude))
        var newFrame = textView.frame
        newFrame.size = CGSize(width: max(newSize.width, fixedWidth), height: newSize.height)
        textView.frame = newFrame
    }

    /* Limits the number of characters in a post */
    private func textView(textView: UITextView, shouldChangeTextInRange range: Range<String.Index>, replacementText text: String) -> Bool {
        let newText = textView.text.replacingCharacters(in: range as Range<String.Index>, with: text)
        let numberOfChars = newText.characters.count
        return numberOfChars < MAX_POST_CHARACTERS;
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

    
    //MARK: - Slider methods
    
    /* Handle slider event / limit to discrete values */
    @IBAction private func sliderValueChanged(_ sender: Any) {
        if let slider = sender as? UISlider {
            
            //discrete slider values
            switch slider.value {
                case 0..<0.13 : slider.value = 0.10
                case 0.13..<0.38 : slider.value = 0.25
                case 0.38..<0.63 : slider.value = 0.50
                case 0.63..<0.88 : slider.value = 0.75
                case 0.88..<1.13 : slider.value = 1.00
                case 1.13..<1.38 : slider.value = 1.25
                case 1.38...1.50 : slider.value = 1.50
                default: break
            }
            
            //update label to reflect the change
            dollarLabel.text = "$ \(slider.value)"
        }
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
    
    //MARK: - View did load preperation methods
    
    private func prepDonationSubviews() {
        //hide the picker view
        donateMessage.delegate = self
        charityPicker.delegate = self
        
        charityPickerView.isHidden = true
        donateMessage.layer.cornerRadius = 8
        verifyButton.layer.cornerRadius = 15
        verifyView.isHidden = true
        donateMessage.placeholderText = MESSAGE_PLACEHOLDER_TEXT
    }
    
    private func resetPage() {
        charityPickerView.isHidden = true
        verifyView.isHidden = true
        defaultCharitySwitch.isOn = true
        donateFor.text = nil
        donateMessage.text = MESSAGE_PLACEHOLDER_TEXT
        anonymousSwitch.isOn = false
        shareToFacebookSwitch.isOn = true
        shareToFacebookSwitch.isEnabled = true
        dollarSlider.value = 1.00
        dollarLabel.text = "$ 1.00"
    }
    
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide pickerview/verify subview/set delegates
        prepDonationSubviews()

        // Create a location manager object
        locationManager = CLLocationManager()
        
        // ask for location authorization
        locationManager?.requestAlwaysAuthorization()
        
        // Set the delegate
        locationManager?.delegate = self
        
        
        //get quick location update
        requestLocationUpdate()
        
        //nav bar for reveal view controller
        connectRevealVC()
        
        self.view.backgroundColor = UIColor(patternImage: UIImage(named: BACKGROUND_IMAGE_LINK)!)
    
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
