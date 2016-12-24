//
//  ProfileTableViewController.swift
//  Coign
//
//  Created by Maximilian Hoffman on 12/23/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - Properties
    let HEADER_CELL_IDENTIFIER = "header cell"
    let NETWORK_CELL_IDENTIFIER = "network cell"
    
    var networkOfImpact = [(charity: String, number: Int)]() {
        didSet {
            self.tableView.reloadData()
            print("should reload data")
        }
    }
    
    //MARK: - Refresh view methods
    @objc private func refreshView(_ refreshControl: UIRefreshControl) {
        configureNetworkOfImpact()
    }
    
    @objc private func endRefreshing() {
        if let refreshControl = self.refreshControl {
            if refreshControl.isRefreshing {
                refreshControl.endRefreshing()
            }
        }
    }
    
    //MARK: Config methods
    
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
    
    private func configureNetworkOfImpact() {
        if let userID = UserDefaults.standard.object(forKey: FirTree.UserParameter.UserUID.rawValue) as? String {
            FirTree.queryNetworkOfImpact(userID: userID) { [weak self] networkTuple in
                if networkTuple != nil {
                    self?.networkOfImpact = networkTuple!
                    _ = networkTuple?.sorted{ $1.1 > $0.1 }
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return networkOfImpact.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
                self.endRefreshing()
                timer.invalidate()
            }
        }
        if let networkCell = tableView.dequeueReusableCell(withIdentifier: NETWORK_CELL_IDENTIFIER, for: indexPath) as? NetworkCell {
            networkCell.title?.text = "\(networkOfImpact[indexPath.row].charity):"
            networkCell.number?.text = String(networkOfImpact[indexPath.row].number)
            return networkCell
        }
        else {
            return UITableViewCell()
        }
    }

    //MARK: - Superview methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        configureNetworkOfImpact()
        connectRevealVC()
        self.tableView.separatorStyle = .none
        
        // handle pull to refresh
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: #selector(refreshView(_:)), for: UIControlEvents.valueChanged)
        self.refreshControl?.backgroundColor = UIColor.lightGray
        self.refreshControl?.tintColor = UIColor.white
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profile_selected").withRenderingMode(.alwaysOriginal))
    }

}
