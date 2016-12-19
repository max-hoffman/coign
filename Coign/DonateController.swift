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

    //MARK: - Constants (or vars that are set once)
    var charities: [String]? {
        if let path = Bundle.main.path(forResource: "CharityList", ofType: "plist") {
            return NSArray(contentsOfFile: path) as? [String]
        } else {
            return nil
        }
    }

    var friendsDictionary: [String:String] = [:]
    var communityDictionary: [String:String] = [:]
    var proxyArray: [String] = []
    var selectedProxyIndex: Int?
    var currentUserLocation:CLLocationCoordinate2D? = nil
    var locationManager: CLLocationManager? = nil
    let MAX_POST_CHARACTERS: Int = 200
    let ANIMATION_DURATION: TimeInterval = 0.3
    let MESSAGE_PLACEHOLDER_TEXT: String = "Insert message here: "
    let DONATE_PLACEHOLDER_TEXT: String = "ex: Jane Doe"
    let VERIFY_BUTTON_DELAY: TimeInterval = 0.4
    let BACKGROUND_IMAGE_LINK: String = "coign_background_02"
    
    //MARK: - Outlets
    //@IBOutlet weak var menuButton: UIBarButtonItem!

    @IBOutlet weak var anonymousSwitch: UISwitch!
    @IBOutlet weak var donateMessage: UITextView!

    @IBOutlet weak var donateForView: UIView!
    
    @IBOutlet weak var donateFor: AutoCompleteTextField!
    
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
    @IBOutlet weak var primaryDonorSwitch: UISwitch!
    
    @IBOutlet var headlines: [UILabel]!
    
    
    //MARK: - Posting methods
    
    //TODO: This needs to go inside the plaid completion block
    fileprivate func createPost() {
        
        if let userUID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as? String, let recipient = donateFor.text, let name = UserDefaults.standard.object(forKey: FirTree.UserParameter.Name.rawValue) {

            var charity: String {
                if !customCharityView.isHidden {
                    return customCharityTextField.text!
                }
                else {
                    return (charities?[charityPicker.selectedRow(inComponent: 0)])!
                }
            }
            
            let (proxyUID, proxyIsAFriend) = extractProxyUID(name: donateFor.text)
                
            let post : [String: Any] = [
                FirTree.PostParameter.DonorName.rawValue: name,
                FirTree.PostParameter.DonorUID.rawValue : userUID,
                FirTree.PostParameter.Charity.rawValue : charity,
                FirTree.PostParameter.RecipientName.rawValue : recipient,
                FirTree.PostParameter.RecipientUID.rawValue : proxyUID,
                FirTree.PostParameter.Message.rawValue : donateMessage.text,
                FirTree.PostParameter.DonationAmount.rawValue : 1,
                FirTree.PostParameter.TimeStamp.rawValue : Date.timeIntervalSinceReferenceDate,
                FirTree.PostParameter.Anonymous.rawValue : anonymousSwitch.isOn,
                FirTree.PostParameter.Proxy.rawValue : primaryDonorSwitch.isOn
            ]
            
            //complete the post by updating the FirTree and reloading autofill array
            FirTree.newPost(post, location: currentUserLocation, userID: userUID, proxyUID: proxyUID, proxyIsAFriend: proxyIsAFriend)
            loadAutofillProxies()
        }
    }
    
    private func extractProxyUID(name: String?) -> (uid: String, friend: Bool) {
        if name == nil {
            return ("", false)
        }
        else {
            if let friendUID = friendsDictionary[name!] {
                return (uid: friendUID, friend: true)
            } else if let communityID = communityDictionary[name!] {
                return (uid: communityID, friend: false)
            } else {
                return (uid: FirTree.newCommunityProxy(name: name!), friend: false)
            }
        }
    }

    //button color returns to normal after the popover appears
    @IBAction func verifyButtonPressed(_ sender: UIButton) {
        verifyButton.backgroundColor = CustomColor.brandGreen.withAlphaComponent(0.5)
        presentVerifyPopover()
        let _ = Timer.scheduledTimer(withTimeInterval: VERIFY_BUTTON_DELAY, repeats: false) {timer in
            self.verifyButton.backgroundColor = CustomColor.brandGreen.withAlphaComponent(1.0)
            timer.invalidate()
        }
    }
    
    @IBAction func verifyButtonReleased(_ sender: UIButton) {
        verifyButton.backgroundColor = CustomColor.brandGreen.withAlphaComponent(1.0)
    }
    
    fileprivate func presentVerifyPopover() {
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
    
    fileprivate func presentSharePopover() {
        if(SLComposeViewController.isAvailable(forServiceType: SLServiceTypeFacebook)) {
            print("available")
            if let socialController = SLComposeViewController(forServiceType: SLServiceTypeFacebook) {
                socialController.setInitialText("Hello World!")
                socialController.add(URL(fileURLWithPath: "coign.co"))
                self.present(socialController, animated: true, completion: nil)
            }
            
        }
    }
    
    fileprivate func resetPage() {
        customCharityView.isHidden = true
        charityPickerView.isHidden = true
        verifyView.isHidden = true
        donateFor.text = nil
        donateMessage.text = MESSAGE_PLACEHOLDER_TEXT
        anonymousSwitch.isOn = false
    }
    
    //MARK: - View manipulation methods
    
    @objc fileprivate func toggleCharityView(_: UITapGestureRecognizer) {
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
    
    //MARK: - Autocomplete methods
    
    private func configureTextField() {
        donateFor.autoCompleteTextColor = UIColor(red: 128.0/255.0, green: 128.0/255.0, blue: 128.0/255.0, alpha: 1.0)
        donateFor.autoCompleteTextFont = UIFont(name: "HelveticaNeue-Light", size: 12.0)!
        donateFor.autoCompleteCellHeight = 35.0
        donateFor.maximumAutoCompleteCount = 20
        donateFor.hidesWhenSelected = true
        donateFor.hidesWhenEmpty = true
        donateFor.enableAttributedText = true
        var attributes = [String:AnyObject]()
        attributes[NSForegroundColorAttributeName] = UIColor.black
        attributes[NSFontAttributeName] = UIFont(name: "HelveticaNeue-Bold", size: 12.0)
        donateFor.autoCompleteAttributes = attributes
    }
    
    private func handleTextFieldInterfaces() {
        donateFor.onTextChange = {[weak self] text in
            if !text.isEmpty {
                self?.donateFor.autoCompleteStrings = self?.proxyArray.filter{$0.range(of: text) != nil }
            }
        }
        
        donateFor.onSelect = {[weak self] text,indexPath in
            self?.selectedProxyIndex = indexPath.row
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
    private func textView(_ textView: UITextView, shouldChangeTextInRange range: Range<String.Index>, replacementText text: String) -> Bool {
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

    //MARK: - Location methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentUserLocation = manager.location?.coordinate
        print("locations = \(currentUserLocation?.latitude) \(currentUserLocation?.longitude)")
        locationManager?.stopUpdatingLocation()
    }
    
    func requestLocationUpdate() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager?.startUpdatingLocation()
        }
    }
    
    //MARK: - View did load preperation methods
    
    func prepDonationSubviews() {
        
        //hide/shape views
        customCharityView.isHidden = true
        customCharityView.alpha = 0
        donateMessage.layer.cornerRadius = 8
        verifyButton.layer.cornerRadius = 15
        verifyView.isHidden = true
        donateMessage.placeholderText = MESSAGE_PLACEHOLDER_TEXT
        
        //select custom tap recognizer
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCharityView(_:)))
        tap.delegate = self
        selectCustomView.addGestureRecognizer(tap)
    

    }
    
    func loadAutofillProxies() {
        
        let dispatchThread = DispatchGroup()
        
        dispatchThread.enter()
        FirTree.queryFriends { [weak self]
            array, dictionary in
            
            if array != nil {
                self?.proxyArray += array!
                dictionary?.forEach { self?.friendsDictionary[$0] = $1 }
                dispatchThread.leave()
            }
        }
        
        dispatchThread.notify(queue: DispatchQueue.main) {
            FirTree.queryCommunityProxies { [weak self]
                array, dictionary in
                
                if array != nil {
                    self?.proxyArray += array!
                    dictionary?.forEach { self?.communityDictionary[$1] = $0 }
                }
            }
        }
        
        
    }
    
    func underlineHeadlines() {
        let attributes : [String : Any] = [
            NSFontAttributeName : UIFont.systemFont(ofSize: 20.0),
            NSForegroundColorAttributeName : UIColor.black,
            NSUnderlineStyleAttributeName : 1]
        
        headlines.forEach({ $0.attributedText = NSAttributedString(string: $0.text!, attributes: attributes) })
    }
    
    func selectDefault() {
        //set the picker view selection to the default
        if let defaultCharity = UserDefaults.standard.object(forKey: FirTree.UserParameter.Charity.rawValue) as? String, let defaultIndex = charities?.index(of: defaultCharity) {
            
            charityPicker.selectRow(defaultIndex, inComponent: 0, animated: false)
        }
    }
    
    //MARK: - Superclass methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //hide pickerview/verify subview/set delegates
        prepDonationSubviews()
        underlineHeadlines()
        selectDefault()

        // Create a location manager object
        locationManager = CLLocationManager()
        
        // ask for location authorization
        locationManager?.requestAlwaysAuthorization()
        
        // set delegates
        locationManager?.delegate = self
        donateMessage.delegate = self
        charityPicker.delegate = self
        
        //get quick location update
        requestLocationUpdate()
        
        //friends autocomplete config
        loadAutofillProxies()
        handleTextFieldInterfaces()
        configureTextField()
        
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
