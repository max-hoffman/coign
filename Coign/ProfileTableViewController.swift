//
//  ProfileTableViewController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 12/23/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

/**
 Shows the user's picture and name at top, and "network of impact" below. The network of impact is just a table combining the total to/from charities and donations. If there are no to/from donations, then the table is just empty.
 */
class ProfileTableViewController: UITableViewController {

    // MARK: - Properties
    
    let HEADER_CELL_IDENTIFIER = "header cell"
    let NETWORK_CELL_IDENTIFIER = "network cell"
    let NO_DONATION_CELL_IDENTIFIER = "no donations cell"
    var networkOfImpact = [(charity: String, number: Int)]() {
        didSet {
            self.tableView.reloadData()
            print("should reload data")
        }
    }
    
    //MARK: - Config methods
    
    /**
     Puts the image/name in the table header.
     */
    private func configureHeader() {
        if let headerCell = tableView.dequeueReusableCell(withIdentifier: HEADER_CELL_IDENTIFIER) as? ProfileHeaderCell {
            
            //set image
            FirTree.returnCurrentUserImage { (image) in
                headerCell.profileImage.image = image
            }
            
            //set name
            headerCell.name.text = UserDefaults.standard.object(forKey: FirTree.UserParameter.Name.rawValue) as? String ?? "name error"
            
            tableView.tableHeaderView = headerCell
        }
    }
    
    /**
     Loads in the "network of impact" data as an array of tuples.
     */
    private func configureNetworkOfImpact() {
        if let userID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as? String {
            FirTree.queryNetworkOfImpact(userID: userID) { [weak self] networkTuple in
                if networkTuple != nil {
                    self?.networkOfImpact = networkTuple!.sorted{ $0.1 > $1.1 }
                }
            }
        }
    }

    /**
     Adds the refresh control to the table view. Matches that in the home page.
     */
    private func configureRefreshControl() {
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshView(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.lightGray
        self.refreshControl?.tintColor = UIColor.white
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // zero-coalescing operator
        return networkOfImpact.count > 0 ? networkOfImpact.count : 1
    }

    /**
     Loads the network cells or the "no donations to show" cell. The first cell load triggers ending the page refreshing animation.
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        //end refreshing on first pass
        if indexPath.row == 0 {
            endRefreshing()
        }
        
        //either show the "no donations" text, or fill the cells
        if networkOfImpact.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: NO_DONATION_CELL_IDENTIFIER)!
        }
        else {
            return formattedNetworkCell(indexPath: indexPath)
        }
    }
    
    /**
     Convenience method to fill network impact cells; draw from the array of tuples depending on the row index.
     */
    private func formattedNetworkCell(indexPath: IndexPath) -> NetworkCell {
        if let networkCell = tableView.dequeueReusableCell(withIdentifier: NETWORK_CELL_IDENTIFIER, for: indexPath) as? NetworkCell {
            networkCell.title?.text = "\(networkOfImpact[indexPath.row].charity):"
            networkCell.number?.text = String(networkOfImpact[indexPath.row].number)
            return networkCell
        }
        else {
            return NetworkCell()
        }
    }
    
    // MARK: - Refresh view methods
    
    /**
     This is kind of an unnecessary method, but the naming is convenient for the action.
     */
    @objc private func refreshView(_ refreshControl: UIRefreshControl) {
        configureNetworkOfImpact()
    }
    
    /**
     End the refreshing animation after a comfortable one-second pause.
     */
    @objc private func endRefreshing() {
        if let refreshControl = self.refreshControl {
            if refreshControl.isRefreshing {
                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                    refreshControl.endRefreshing()
                    timer.invalidate()
                }
            }
        }
    }
    
    // MARK: - Superview methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configure
        configureHeader()
        configureNetworkOfImpact()
        configureRefreshControl()
        
        // side-bar
        connectRevealVC()
        
        //remove separator lines
        self.tableView.separatorStyle = .none
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profile_selected").withRenderingMode(.alwaysOriginal))
    }
}
