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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureHeader()
        configureNetworkOfImpact()
        connectRevealVC()
        self.tableView.separatorStyle = .none
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return networkOfImpact.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let networkCell = tableView.dequeueReusableCell(withIdentifier: NETWORK_CELL_IDENTIFIER, for: indexPath) as? NetworkCell {
            networkCell.title?.text = "\(networkOfImpact[indexPath.row].charity):"
            networkCell.number?.text = String(networkOfImpact[indexPath.row].number)
            return networkCell
        }
        else {
            return UITableViewCell()
        }
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
