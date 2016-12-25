//
//  PostManager.swift
//  Coign
//
//  Created by Maximilian Hoffman on 11/22/16.
//  Copyright © 2016 Exlent Studios. All rights reserved.
//

import Foundation
import CoreLocation

class PostManager {

    var recentPostUIDs: [String] = []
    var localPostUIDs: [String] = []
    var friendPostUIDs: [String] = []
    
    var recentPosts: [Post] = []
    var localPosts: [Post] = []
    var friendPosts: [Post] = []
    
    var currentUserLocation:CLLocationCoordinate2D?
    var postManagerIsFetchingData: Bool
    var currentUIDs: [String] {
        get {
            switch currentType {
            case .recent :
                return recentPostUIDs
            case .local :
                return localPostUIDs
            case .friends :
                return friendPostUIDs
            }
        }
    }
    var currentPosts: [Post] {
        
        get{
            switch currentType {
            case .recent :
                return recentPosts
            case .local :
                return localPosts
            case .friends :
                return friendPosts
            }
        }
    }
    
    var viewController: HomeMenuController?
    
    var noCurrentUIDsLoaded: Bool {
        return currentUIDs.count == 0
    }
    
    enum ViewablePostType {
        case recent
        case local
        case friends
    }

    var currentType: ViewablePostType = .recent {
        didSet{
            
            if noCurrentUIDsLoaded { //we don't know what posts to pull yet
                loadPostUIDs()
            }
            
            else { //we already know what posts should be in this table segment
                viewController?.tableView.reloadData()
            }
        }
    }

    init (viewController: HomeMenuController, initialType: ViewablePostType) {
        self.viewController = viewController
        self.currentType = initialType
        self.postManagerIsFetchingData = true
    }
    
    func loadPostUIDs() {
        switch currentType {
        case .recent :
            recentPosts.removeAll()
            loadRecentPostUIDs()
        case .local :
            loadLocalPostUIDs()
            localPosts.removeAll()
        case .friends :
            break
        }
        
        postManagerIsFetchingData = true
    }
    
    fileprivate func loadRecentPostUIDs() {
        
        //refresh the recentPosts array of Posts
        FirTree.queryRecentPosts(100) { postUIDs in
            if postUIDs != nil {
                self.recentPostUIDs = postUIDs!
                self.updatePostArray()
            }
            else {
                //no recent posts
                print("no recent posts")
            }
        }
        
    }
    
    fileprivate func loadLocalPostUIDs() {
        
        if currentUserLocation != nil {
            Geohash.queryLocalPosts(CLLocation(
                latitude: currentUserLocation!.latitude,
                longitude: currentUserLocation!.longitude),
                completionHandler: {
                    (keys) in
                    
                    if keys != nil {
                        self.localPostUIDs = keys!
                        self.updatePostArray()
                    }
                    else {
                        //no local posts
                        print("no local posts")
                        self.localPostUIDs = []
                        self.viewController?.tableView.reloadData()
                    }
            })
        }
    }
    
    func updatePostArray() {
        
        let uidCount = currentUIDs.count
        let postCount = currentPosts.count
        let updateNumber = min(uidCount - postCount, 10)
        
        if updateNumber != 0 {
            let postsToLoad: [String] = Array(currentUIDs[postCount...postCount+updateNumber-1])
            
            FirTree.returnPostsFromUIDs(postsToLoad) {
                newPosts in

                self.updateCurrentPosts(withNewPosts: newPosts)
                self.viewController?.tableView.reloadData()
                self.postManagerIsFetchingData = false
            }
        }
    }
    
    func updateCurrentPosts(withNewPosts newPosts: [Post]) {
        switch currentType {
        case .recent :
            recentPosts.append(contentsOf: newPosts)
        case .local :
            return localPosts.append(contentsOf: newPosts)
        case .friends :
            return friendPosts.append(contentsOf: newPosts)
        }
    }
}
