//
//  User.swift
//  Twitter
//
//  Created by Senyang Zhuang on 2/17/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

var _currentUser: User?
let currentUserKey = "kCurrentUserKey"
let userDidLoginNotification = "userDidLoginNotification"
let userDidLogoutNotification = "userDidLogoutNotification"

class User: NSObject {
    var name: String?
    var screenname: String?
    var profileImageUrl: String?
    var headerImageUrl: String?
    var tagline: String?
    var dictionary: NSDictionary
    var followers: Int?
    var following: Int?
    var status_count: Int?
    var isVerified: Bool
    var id: Int?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        screenname = dictionary["screen_name"] as? String
        profileImageUrl = dictionary["profile_image_url"] as? String
        tagline = dictionary["description"] as? String
        headerImageUrl = dictionary["profile_banner_url"] as? String
        followers = dictionary["followers_count"] as? Int
        following = dictionary["friends_count"] as? Int
        status_count = dictionary["statuses_count"] as? Int
        isVerified = dictionary["verified"] as! Bool
        id = dictionary["id"] as! Int
    }
    
    func logout(){
        User.currentUser = nil
        TwitterClient.sharedInstance.requestSerializer.removeAccessToken()
        NSNotificationCenter.defaultCenter().postNotificationName(userDidLogoutNotification, object: nil)
    
    
    }
    
    class var currentUser: User?{
        get{
            if _currentUser == nil{
                var data = NSUserDefaults.standardUserDefaults().objectForKey(currentUserKey) as? NSData
                if data != nil{
                    do{
                        var dictionary = try NSJSONSerialization.JSONObjectWithData(data!, options: []) as! NSDictionary
                        _currentUser = User(dictionary: dictionary)}
                    catch{
                    }
        
                }
            }
            return _currentUser
        }set(user){
            _currentUser = user
            
            if _currentUser != nil{
                do{
                    var data = try NSJSONSerialization.dataWithJSONObject(user!.dictionary, options: [])
                    NSUserDefaults.standardUserDefaults().setObject(data, forKey: currentUserKey)
                    
                }
                catch{
                
                }
            }else{
                
            NSUserDefaults.standardUserDefaults().setObject(nil, forKey: currentUserKey)
            
            }
            NSUserDefaults.standardUserDefaults().synchronize()
        
        }
    }
    
    
    
}
