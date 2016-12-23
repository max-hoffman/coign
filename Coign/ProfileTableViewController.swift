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
    
    var networkOfImpact = [(charity: String, number: String)]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        configureNetworkOfImpact()
        connectRevealVC()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        // Initialize Tab Bar Item
        tabBarItem = UITabBarItem(title: "Profile", image: #imageLiteral(resourceName: "profile"), selectedImage: #imageLiteral(resourceName: "profile_selected").withRenderingMode(.alwaysOriginal))
    }
    
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
                }
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return networkOfImpact.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let networkCell = tableView.dequeueReusableCell(withIdentifier: NETWORK_CELL_IDENTIFIER, for: indexPath)
        networkCell.textLabel?.text = "\(networkOfImpact[indexPath.row].charity):"
        networkCell.detailTextLabel?.text = networkOfImpact[indexPath.row].number
        
        
        return networkCell
    }
 

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
