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
    var currentUIDs: [String] {
        
        get {
            switch currentType {
            case .Recent :
                return recentPostUIDs
            case .Local :
                return localPostUIDs
            case .Friends :
                return friendPostUIDs
            }
        }
    }
    var currentPosts: [Post] {
        
        get{
            switch currentType {
            case .Recent :
                return recentPosts
            case .Local :
                return localPosts
            case .Friends :
                return friendPosts
            }
        }
    }
    
    var viewController: HomeMenuController?
    
    var noCurrentUIDsLoaded: Bool {
        return currentUIDs.count == 0
    }
    
    enum ViewablePostType {
        case Recent
        case Local
        case Friends
    }

    var currentType: ViewablePostType = .Recent {
        didSet{
            if noCurrentUIDsLoaded {
                loadPostUIDs()
            }
        }
    }

    init (location: CLLocationCoordinate2D?, viewController: HomeMenuController, initialType: ViewablePostType) {
        self.currentUserLocation = location
        self.viewController = viewController
        self.currentType = initialType
    }
    
    func loadPostUIDs() {
        switch currentType {
        case .Recent :
            loadRecentPostUIDs()
        case .Local :
            loadLocalPostUIDs()
        case .Friends :
            break
        }
    }
    
    private func loadRecentPostUIDs() {
        
        //refresh the recentPosts array of Posts
        FirTree.queryRecentPosts(number: 100) { postUIDs in
            if postUIDs != nil {
                self.recentPostUIDs = postUIDs!
                self.updatePostArray()
            }
        }
        
    }
    
    private func loadLocalPostUIDs() {
        
        if currentUserLocation != nil {
            Geohash.queryLocalPosts(center: CLLocation(
                latitude: currentUserLocation!.latitude,
                longitude: currentUserLocation!.longitude),
                completionHandler: {
                    (keys) in
                    
                    self.localPostUIDs = keys!
                    self.updatePostArray()
            })
        }
    }
    
    
    func updateCurrentPosts(withNewPosts newPosts: [Post], completionHandler: @escaping (_ success: Bool) -> Void) {
        switch currentType {
        case .Recent :
            recentPosts.append(contentsOf: newPosts)
        case .Local :
            return localPosts.append(contentsOf: newPosts)
        case .Friends :
            return friendPosts.append(contentsOf: newPosts)
        }
        
        completionHandler(true)
    }
    
    func updatePostArray() {
        
        let uidCount = currentUIDs.count
        let postCount = currentPosts.count
        let updateNumber = min(uidCount - postCount, 10)
        
        if updateNumber != 0{
            let postsToLoad: [String] = Array(currentUIDs[postCount...postCount+updateNumber-1])
            
            FirTree.returnPostsFromUIDs(postUIDs: postsToLoad) {
                
                newPosts in

                self.updateCurrentPosts(withNewPosts: newPosts) { success in
                    if success {
                        self.viewController?.tableView.reloadData()
                    }
                }
            }
        }
    }
}
