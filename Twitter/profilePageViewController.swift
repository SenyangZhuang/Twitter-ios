//
//  profilePageViewController.swift
//  Twitter
//
//  Created by Senyang Zhuang on 2/23/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class profilePageViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var user: User?
    let current_user = User.currentUser
    var tweets = [Tweet]()
    
    @IBOutlet weak var bannerView: UIImageView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var followButton: UIButton!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var isVerifiedImage: UIImageView!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var contentTypeSegment: UISegmentedControl!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        let imagePath = user!.profileImageUrl!
        let url = NSURL(string: imagePath)
        self.profileImageView.setImageWithURL(url!)
        if let headerImagePath = user?.headerImageUrl{
            let headUrl = NSURL(string: headerImagePath)
            self.bannerView.setImageWithURL(headUrl!)
        }
        if let username = user?.name{
            self.userNameLabel.text = username
        }
        if let screenName = user?.screenname{
            self.screenNameLabel.text = screenName
        }
        if user?.isVerified == true{
            isVerifiedImage.image = UIImage(named: "verified")
        }
        if let followers = user?.followers{
            let followersCount = String(followers)
            self.followersCountLabel.text = followersCount
        }else{
            self.followersCountLabel.text = String(0)
        }
        if let following = user?.following{
            let followingCount = String(following)
            self.followingCountLabel.text = followingCount
        }else{
            self.followingCountLabel.text = String(0)
        }
        self.contentTypeSegment.addTarget(self, action: "contentTypeChanged", forControlEvents: .ValueChanged)
        
        
        var id = user?.id
        let sid = String(id!)

        let params = ["user_id": sid] as! NSDictionary
        TwitterClient.sharedInstance.userTimeLineWithParams(params, completion: { (tweets, error) -> () in
            if let tweets = tweets{
                self.tweets = tweets
            }
            self.tableView.reloadData()
        })
        
        // Do any additional setup after loading the view.
    }
    
    func contentTypeChanged(){
        let index = self.contentTypeSegment.selectedSegmentIndex
        if index == 2{
            var id = user?.id
            let sid = String(id!)
            let params = ["user_id": sid] as! NSDictionary
            TwitterClient.sharedInstance.getUserFavoriteStatus(params, completion: { (tweets, error) -> () in
                if error == nil{
                    if let tweets = tweets{
                        self.tweets = tweets
                    }
                    self.tableView.reloadData()
                
                }else{
                    print(error)
                }
            })
        
        }else if index == 0{
            var id = user?.id
            let sid = String(id!)
            let params = ["user_id": sid] as! NSDictionary
            TwitterClient.sharedInstance.userTimeLineWithParams(params, completion: { (tweets, error) -> () in
                if let tweets = tweets{
                    self.tweets = tweets
                }
                self.tableView.reloadData()
            })
            
        
        }
        
    
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = self.tableView.dequeueReusableCellWithIdentifier("userTweetCell") as! userTweetCell
        let tweet = tweets[indexPath.row]
        let imagePath = user?.profileImageUrl!
        let url = NSURL(string: imagePath!)
        cell.profileImageView.setImageWithURL(url!)
        let screenname = user?.screenname!
        cell.screenNameLabel.text = "@\(screenname!)"
        let username = user?.name!
        cell.userNameLabel.text = username!
        cell.contentLabel.text = tweet.text
        cell.retweetCountLabel.text! = String(tweet.retweetCount)
        cell.likeCountLabel.text! = String(tweet.favorriteCount)
        cell.replyButton.setImage(UIImage(named:"reply"), forState: UIControlState.Normal)
        if tweet.isLiked == true{
            cell.likeButton.setImage(UIImage(named:"like"),forState:UIControlState.Normal)
        }else{
            cell.likeButton.setImage(UIImage(named:"unliked"),forState:UIControlState.Normal)
        }
        if tweet.isRetweeted == true{
            cell.retweetButton.setImage(UIImage(named:"retweet"),forState:UIControlState.Normal)
        }else{
            cell.retweetButton.setImage(UIImage(named:"unretweeted"), forState: UIControlState.Normal)
        }
        let timestamp = NSDateFormatter.localizedStringFromDate(tweet.createdAt!, dateStyle: .ShortStyle, timeStyle: .NoStyle)
        cell.timeStampLabel.text = timestamp
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    

    @IBAction func backButtonOnClick(sender: AnyObject) {
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
