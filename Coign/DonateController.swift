//
//  DonateController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 9/11/16.
//  Copyright © 2016 The Maxes. All rights reserved.
//

import UIKit
import CoreLocation
import Social
import SkyFloatingLabelTextField

class DonateController: UIViewController, UITextViewDelegate, UIPickerViewDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate {

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


    @IBOutlet weak var anonymousSwitch: UISwitch!
    @IBOutlet weak var donateMessage: UITextView!
    @IBOutlet weak var donateFor: UITextField!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var charityPicker: UIPickerView!
    @IBOutlet weak var charityPickerView: UIView!
    @IBOutlet weak var verifyView: UIView!
    @IBOutlet weak var verifyButton: UIButton!
    @IBOutlet weak var dollarLabel: UILabel!
    @IBOutlet weak var selectCustomArrow: UILabel!
    @IBOutlet weak var customCharityView: UIView!
    @IBOutlet weak var selectCustomView: UIView!
    @IBOutlet weak var customCharityTextField: SkyFloatingLabelTextField!
    
    @IBOutlet var headlines: [UILabel]!
    
    //TODO: This needs to go inside the plaid completion block
    private func createPost() {
        
        if let userUID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as? String, let recipient = donateFor.text, let name = UserDefaults.standard.object(forKey: FirTree.UserParameter.Name.rawValue) {

            var charity: String? = nil
            if !customCharityView.isHidden {
                charity = customCharityTextField.text
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
                FirTree.PostParameter.DonationAmount.rawValue : 1,
                FirTree.PostParameter.TimeStamp.rawValue : Date.timeIntervalSinceReferenceDate,
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
            
            weakSelf?.presentSharePopover()
            
            weakSelf?.resetPage()
            
        }))
        donationAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (action: UIAlertAction) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        present(donationAlert, animated: true, completion: nil)
    }
    
    
    private func presentSharePopover() {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
            print("available")
            if let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                socialController.setInitialText("Hello World!")
                socialController.add(URL(fileURLWithPath: "coign.co"))
                self.present(socialController, animated: true, completion: nil)
            }
            
        }
    }
    
    //MARK: - View manipulation methods
    
    @objc private func toggleCharityView(_: UITapGestureRecognizer) {
        if self.charityPickerView.isHidden {
            UIView.animate(withDuration: 0.3, animations: {
                //hide custom text
                self.customCharityView.isHidden = true
                self.customCharityView.alpha = 0
                self.selectCustomArrow.text = "→"
                _ = self.customCharityTextField.resignFirstResponder()
                
                //show the picker view
                self.charityPickerView.isHidden = false
                self.charityPickerView.alpha = 1
            })
        }
        else {
            UIView.animate(withDuration: 0.3, animations: {
                //hide the picker view, show custom text
                self.charityPickerView.isHidden = true
                self.charityPickerView.alpha = 0
                self.customCharityView.isHidden = false
                self.customCharityView.alpha = 1
                self.selectCustomArrow.text = "⇣"
            })
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
        //det delegates
        donateMessage.delegate = self
        charityPicker.delegate = self
        
        //hide/shape views
        customCharityView.isHidden = true
        customCharityView.alpha = 0
        donateMessage.layer.cornerRadius = 8
        verifyButton.layer.cornerRadius = 15
        verifyView.isHidden = true
        donateMessage.placeholderText = MESSAGE_PLACEHOLDER_TEXT
        
        //select sustom tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCharityView(_:)))
        tap.delegate = self
        selectCustomView.addGestureRecognizer(tap)
        
        //underline headlines
        
        let attributes : [String : Any] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 20.0),
            NSForegroundColorAttributeName : UIColor.black,
            NSUnderlineStyleAttributeName : 1]
        
        headlines.forEach({ $0.attributedText = NSAttributedString(string: $0.text!, attributes: attributes) })
        
        //set the picker view selection to the default
        if let defaultCharity = UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as? String, let defaultIndex = charities?.index(of: defaultCharity) {
            
            charityPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        }
    }
    
    private func resetPage() {
        customCharityView.isHidden = true
        charityPickerView.isHidden = true
        verifyView.isHidden = true
        donateFor.text = nil
        donateMessage.text = MESSAGE_PLACEHOLDER_TEXT
        anonymousSwitch.isOn = false
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Give", image: #imageLiteral(resourceName: "co"), selectedImage: #imageLiteral(resourceName: "co_selected").withRenderingMode(.alwaysOriginal))
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
