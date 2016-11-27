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
    var postManager: PostManager!
    
    //Location properties
    var locationManager: CLLocationManager? = nil
    
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
        
        //instantiate post manager, call first posts to screen
        postManager = PostManager(viewController: self, initialType: .Recent)
        postManager.loadPostUIDs()
        
        //MARK - handle pull to refresh
        self.refreshControl?.addTarget(self, action: #selector(self.refreshView(refreshControl:)), for: UIControlEvents.valueChanged)
        
        self.refreshControl?.backgroundColor = UIColor.darkGray
        self.refreshControl?.tintColor = UIColor.blue
        
        //set the tableview delegate
        tableView.delegate = self
        
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: HEADER_CELL_IDENTIFIER) as? HeaderCell {
            segmentedControl = headerCell.segmentedControl
            
            tableView.tableHeaderView = headerCell
        }
        
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
        
    }

    
    //MARK: - Segmented control methods
    
    /*
     If the segment selection changes, we signal to the postManager that the view was changed. The didSet triggers an update of the 
     */
    @IBAction func indexChanged(sender: UISegmentedControl) {
        if sender == segmentedControl {
            switch sender.selectedSegmentIndex {
            case 0: postManager.currentType = .Recent
            case 1: postManager.currentType = .Local
            case 2: postManager.currentType = .Friends
            default: break
            }
        }
    }
    
    @objc private func refreshView(refreshControl: UIRefreshControl) {
        postManager.loadPostUIDs()
    }
    
    func endRefreshing() {
        if let refreshControl = self.refreshControl {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: - Location manager methods
    
    private func requestLocationUpdate() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager?.delegate = self
            locationManager?.desiredAccuracy = kCLLocationAccuracyThreeKilometers
            locationManager?.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        //update users location
        postManager.currentUserLocation = manager.location?.coordinate
        
        //discontinue location update
        locationManager?.stopUpdatingLocation()
    }
    
    // MARK: - Table view data source

    /*
    The table is setup so that each post is in its own section -> made it easier to control the padding around each cell
     
     */
    override func numberOfSections(in tableView: UITableView) -> Int {
        return postManager.currentPosts.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    /**
     Fill cell with appropriate data. It's done per section, because that was the best way I could figure out to add padding between cells (in section footer).
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        /* Discontinue refresher if we've started loading posts into table */
        if indexPath.section == 0 {
            self.endRefreshing()
        }
        
        if let cell = tableView.dequeueReusableCell(
            withIdentifier: POST_CELL_IDENTIFIER, for: indexPath) as? PostCell{

            return formattedPostCell(cell: cell, withPost: postManager.currentPosts[indexPath.section])
        }
        else {
            return UITableViewCell()
        }
    }
    
    /**
     Does the work of formatting and returnign a post cell. 
     */
    private func formattedPostCell(cell: PostCell, withPost post: Post) -> PostCell {
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
    
    /* Make the cell height dynamic based on the amount of "answer" text. It was also necessary to relax the vertical compression of the dynamic cell in the storyboard. */
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    //MARK: - Footer methods

    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return tableView.dequeueReusableCell(withIdentifier: FOOTER_CELL_IDENTIFIER) as? FooterCell
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
         return 15
    }

    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let contentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
        
        if !postManager.postManagerIsFetchingData && (maximumOffset - contentOffset <= 50) {
            postManager.postManagerIsFetchingData = true
            // Get more data - API call
            postManager.updatePostArray()
            
            // Update UI
            
        }
    }
    
}
