//
//  HomeMenuController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/16/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit
import CoreLocation

class HomeMenuController: UITableViewController, CLLocationManagerDelegate {

    //MARK: - Properties
    
    //Constants
    let POST_CELL_IDENTIFIER = "post cell"
    let HEADER_CELL_IDENTIFIER = "header cell"
    let FOOTER_CELL_IDENTIFIER = "footer cell"
    
    //Menu properties
    var segmentedControl: UISegmentedControl? = nil
    var recentPosts: [Post]? {
        didSet {
            if segmentedControl?.selectedSegmentIndex == 0 {
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }
    var localPosts: [Post]? {
        didSet {
            if segmentedControl?.selectedSegmentIndex == 1 {
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }
    var friendsPosts: [Post]? {
        didSet {
            if segmentedControl?.selectedSegmentIndex == 2 {
                DispatchQueue.main.async{
                    self.tableView.reloadData()
                }
            }
        }
    }
    //TODO: could change the didset to selectedposts
    var selectedPosts: [Post]?
    
    //Location properties
    var locationManager: CLLocationManager? = nil
    var currentUserLocation:CLLocationCoordinate2D? = nil
    
    //User setup properties and outlets
    
    var blurView: UIVisualEffectView? = nil
    var blurEffect: UIVisualEffect? = nil
    
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
    
    //MARK: - Superview methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create a location manager object
        locationManager = CLLocationManager()
        
        // ask for location authorization
        locationManager?.requestAlwaysAuthorization()
        
        // Set the location delegate
        locationManager?.delegate = self
        
        //get quick location update
        requestLocationUpdate()
        
        //nav bar for reveal view controller
        connectRevealVC()
        
        //load recent posts
        //MARK: can this fail?
        loadSelectedPostView()
        
        //MARK - handle pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(self.loadSelectedPostView(refreshControl:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.darkGray
        self.refreshControl?.tintColor = UIColor.blue
        
        //set the tableview delegate
        tableView.delegate = self
        
        
        //set background image
        tableView.backgroundView = UIImageView(image: UIImage(named: "coign_background_02"))
        
        // User setup delegation
        emailField.delegate = self
        phoneField.delegate = self
        nameField.delegate = self
        charityPreferencePicker.delegate = self
        charityPreferencePicker.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        //home page loading logic, automatically calls user setup popover if the last date was set to "new user"
        checkLastLoginDate()
        
        //load recent posts (table refreshed itself when array is updated
//        FirTree.queryRecentPosts() { postData in
//            self.recentPosts = postData
//        }
    }

    
    //MARK: Segmented control methods
    
    /*
     If the segment selection changes, call the proper loadPost method to reflect that change.
     The flow of events is:
     -event triggered
     -load post called
     -post array updated
     -post array didSet calls a table refresh
     */
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if sender == segmentedControl {
            loadSelectedPostView()
        }
    }
    
    /**
     When the view appears, we want to refresh the table to show whichever segment is selected.
     */
    private func loadSelectedPostView() {
        if let index = segmentedControl?.selectedSegmentIndex {
            switch index {
            case 0:
                loadRecentPosts()
            case 1:
                loadLocalPosts()
            case 2:
                loadFriendsPosts()
            default:
                loadRecentPosts()
            }
        }
        else {
            loadRecentPosts()
        }
    }
    
    @objc private func loadSelectedPostView(refreshControl: UIRefreshControl) {
        self.loadSelectedPostView()
            }
    
    //TODO: - setup the load recent posts function
    private func loadRecentPosts() {
        
        //refresh the recentPosts array of Posts
        FirTree.queryRecentPosts() { postData in
            self.recentPosts = postData
            self.selectedPosts = self.recentPosts
            self.endRefreshing()
        }
        
    }
    
    private func loadLocalPosts() {
        
        if localPosts != nil {
            selectedPosts = localPosts
            endRefreshing()
        }
        else {
            endRefreshing()
        }
    }
    
    private func loadFriendsPosts() {
        
        if friendsPosts != nil {
            selectedPosts = friendsPosts
            endRefreshing()
        }
        else {
            endRefreshing()
        }
    }
    
    private func endRefreshing() {
        if let refreshControl = self.refreshControl {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: - Location methods
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //update users location
        currentUserLocation = manager.location?.coordinate
        
        //local query, temporary to see if it works
//        if currentUserLocation != nil {
//            Geohash.queryLocalPosts(
//                center: CLLocation(latitude: currentUserLocation!.latitude, longitude: currentUserLocation!.longitude),
//                completionHandler: { keys in
//                    print(keys ?? "keys array is nil")
//            })
//        }
        
        //turn off location updates, this app doesn't need an accurate location
        locationManager?.stopUpdatingLocation()
    }
    
    private func requestLocationUpdate() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager?.startUpdatingLocation()
        }
    }

    
    // MARK: - Table view data source

    /*
    The table is setup so that each post is in its own section -> made it easier to control the padding around each cell
     
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        if recentPosts != nil {
                return selectedPosts!.count
            }
            else {return 1}
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: POST_CELL_IDENTIFIER, for: indexPath) as? PostCell,
            let post = selectedPosts?[indexPath.section] {
            
            if let donor = post.donor, let charity = post.charity {
                cell.header.text = "\(donor) → \(charity)"
            }
            
            if let time = post.timeStamp {
            cell.timeStamp.text = Double(time).formatMillisecondsToCoherentTime
            }
            
            //if let message = post.message {
                cell.postBody.text = post.message
            //}
            
            if let recipient = post.recipient?.lowercased().removeWhitespace() {
                if recipient != "" {
                    cell.recipientLabel.text = "@ \(recipient):"
                    cell.recipientLabel.textColor = UIColor.blue
                }
                else {
                    cell.recipientLabel.isHidden = true
                }
            }
            
            if let userID = post.donorUID {
                FirTree.returnImage(userID: userID, completionHandler: { (image) in
                    cell.picture?.image = image
                })
            }

            return cell
        }
        else {
            return UITableViewCell()
        }
        

    }
    
    /* Make the cell height dynamic based on the amount of "answer" text. It was also necessary to relax the vertical compression of the dynamic cell in the storyboard. */
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK: - Header methods
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0, let  headerCell = tableView.dequeueReusableCell(withIdentifier: HEADER_CELL_IDENTIFIER) as? HeaderCell {
                segmentedControl = headerCell.segmentedControl
                return headerCell
        }
        else { return tableView.dequeueReusableCell(withIdentifier: FOOTER_CELL_IDENTIFIER) as? FooterCell}
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 60
        }
        else { return 15 }
    }
}
