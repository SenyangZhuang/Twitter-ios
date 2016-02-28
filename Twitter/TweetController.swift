//
//  TweetController.swift
//  Twitter
//
//  Created by Senyang Zhuang on 2/20/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking


class TweetController: UIViewController,UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate, UIScrollViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var headerImageView: UIImageView!
    
    @IBOutlet weak var userProfileImageVIew: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var tweetCountLabel: UILabel!
    
    @IBOutlet weak var followingCountLabel: UILabel!
    
    @IBOutlet weak var followerCountLabel: UILabel!

    
    var current_user = User.currentUser
    var tweets = [Tweet]()
    var isMoreDataLoading = false
    var loadingMoreView:InfiniteScrollActivityView?
    var sinceId = 0
    let count = 20
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "handleRefresh:", forControlEvents: UIControlEvents.ValueChanged)
        return refreshControl
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
//        imageTap.addTarget(self, action: "iamgeViewOnClicked")
//        cellTap.addTarget(self, action: "cellOnClicked")
//        
        //set the header view
        let imagePath = current_user!.profileImageUrl!
        let url = NSURL(string: imagePath)
        self.userProfileImageVIew.setImageWithURL(url!)
        if let headerImagePath = current_user?.headerImageUrl{
        let headUrl = NSURL(string: headerImagePath)
            self.headerImageView.setImageWithURL(headUrl!)
        }
        self.userNameLabel.text = current_user?.name!
        self.screenNameLabel.text = current_user?.screenname!
        if let followers = current_user?.followers{
            let followersCount = String(followers)
            self.followerCountLabel.text = followersCount
        }else{
            self.followerCountLabel.text = String(0)
        }
        
        if let following = current_user?.following{
            let followingCount = String(following)
            self.followingCountLabel.text = followingCount
        }else{
            self.followingCountLabel.text = String(0)
        }
 
        if let statusCount = current_user?.status_count{
            let tweets = String(statusCount)
            self.tweetCountLabel.text = tweets
        }else{
            self.tweetCountLabel.text = String(0)
        }
        
        self.tableView.addSubview(self.refreshControl)
        let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
        loadingMoreView = InfiniteScrollActivityView(frame: frame)
        loadingMoreView!.hidden = true
        tableView.addSubview(loadingMoreView!)
        
        var insets = tableView.contentInset;
        insets.bottom += InfiniteScrollActivityView.defaultHeight;
        tableView.contentInset = insets
        
        let composeBtn = UIButton()
        composeBtn.setImage(UIImage(named: "composetweet"), forState: .Normal)
        composeBtn.frame = CGRectMake(0, 0, 30, 30)
        composeBtn.addTarget(self, action: Selector("compose:"), forControlEvents: .TouchDown)
        let leftBarButton = UIBarButtonItem()
        leftBarButton.customView = composeBtn
        self.navigationItem.leftBarButtonItem = leftBarButton
        NSNotificationCenter.defaultCenter().addObserverForName("userDidPostNewTweet", object: nil, queue: NSOperationQueue.mainQueue()) { (NSNotification) -> Void in
            self.fetchData()
        }
        self.fetchData()
        // Do any additional setup after loading the view.
    }
    
    func handleRefresh(refreshControl: UIRefreshControl) {
        self.fetchData()
        refreshControl.endRefreshing()
    }
    
    func fetchData(sinceId: Int){
        isMoreDataLoading = false
        var params = ["sinceId": sinceId, "count": count]
        TwitterClient.sharedInstance.homeTimeLineWithParams(params, completion:{(tweets, error) -> () in
            if error == nil{
                for tweet in tweets!{
                    self.tweets.append(tweet)
                    self.sinceId = tweet.id
                }
            }
            self.loadingMoreView!.stopAnimating()
            self.tableView.reloadData()
        })
    
    }
    
    func fetchData(){
        TwitterClient.sharedInstance.homeTimeLineWithParams(nil, completion:{(tweets, error) -> () in
            if error == nil{
                self.tweets.removeAll()
                for tweet in tweets!{
                    self.tweets.append(tweet)
                    self.sinceId = tweet.id
                }
            }
            
            self.tableView.reloadData()
        })
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        // Handle scroll behavior here
        if (!isMoreDataLoading) {
            // Calculate the position of one screen length before the bottom of the results
            let scrollViewContentHeight = tableView.contentSize.height
            let scrollOffsetThreshold = scrollViewContentHeight - tableView.bounds.size.height
            // When the user has scrolled past the threshold, start requesting
            if(scrollView.contentOffset.y > scrollOffsetThreshold && tableView.dragging) {
                isMoreDataLoading = true
                let frame = CGRectMake(0, tableView.contentSize.height, tableView.bounds.size.width, InfiniteScrollActivityView.defaultHeight)
                loadingMoreView?.frame = frame
                loadingMoreView!.startAnimating()
                fetchData(self.sinceId)
                
            }
        }
    }
    
    
    func compose(sender: AnyObject){
        self.performSegueWithIdentifier("ComposeSegue", sender: self)
    }
    

    @IBAction func likeButtonOnClick(sender: AnyObject) {
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? TweetCell {
                    let indexPath = self.tableView.indexPathForCell(cell)
                    let tweet = tweets[indexPath!.row]
                    if tweet.isLiked == false{
                        TwitterClient.sharedInstance.postHasNotBeenLiked(tweet.id, completion:{(error) -> () in
                            if error == nil{
                                tweet.favorriteCount += 1
                                button.setImage(UIImage(named:"like"),forState:UIControlState.Normal)
                                tweet.isLiked = true
                            }
                            self.tableView.reloadData()
                        })
                    }else{
                        TwitterClient.sharedInstance.postHasBeenLiked(tweet.id, completion:{(error) -> () in
                            if error == nil{
                                tweet.favorriteCount -= 1
                                button.setImage(UIImage(named:"unliked"),forState:UIControlState.Normal)
                                tweet.isLiked = false
                            }
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
        
    }

    
    func hoursFrom(date:NSDate) -> Int{
        return NSCalendar.currentCalendar().components(.Hour, fromDate: date, toDate: NSDate(), options: []).hour
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func retweetOnClick(sender: AnyObject) {
        if let button = sender as? UIButton {
            if let superview = button.superview {
                if let cell = superview.superview as? TweetCell {
                    let indexPath = self.tableView.indexPathForCell(cell)
                    let tweet = tweets[indexPath!.row]
                    if tweet.isRetweeted == false{
                        TwitterClient.sharedInstance.postHasNotBeenRetweeted(tweet.id, completion:{(error) -> () in
                        if error == nil{
                                tweet.retweetCount += 1
                            button.setImage(UIImage(named:"retweet"),forState:UIControlState.Normal)
                            tweet.isRetweeted = true
                        }
                        self.tableView.reloadData()
                    })
                    }else{
                        TwitterClient.sharedInstance.postHasBeenRetweeted(tweet.id, completion:{(error) -> () in
                            if error ==
                                nil{
                                tweet.retweetCount -= 1
                                button.setImage(UIImage(named:"unretweeted"),forState:UIControlState.Normal)
                                tweet.isRetweeted = false
                            }
                            self.tableView.reloadData()
                        })
                    }
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets.count
    }
    

    func handleTap(sender: AnyObject){
        let point = sender.locationInView(self.tableView)
        let indexPath: NSIndexPath = self.tableView.indexPathForRowAtPoint(point)!
        let cell = self.tableView(self.tableView, cellForRowAtIndexPath: indexPath) as! TweetCell
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("profilePageViewSegue", sender: cell)
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("TweetCell", forIndexPath: indexPath) as! TweetCell
        let tweet = tweets[indexPath.row]
        let user = tweet.user
        cell.tweet = tweet
        let imagePath = user?.profileImageUrl!
        let url = NSURL(string: imagePath!)
        cell.profileImageView.setImageWithURL(url!)
        if cell.profileImageView.userInteractionEnabled == false{
            let onTapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("handleTap:"))
            cell.profileImageView.addGestureRecognizer(onTapGesture)
            cell.profileImageView.userInteractionEnabled = true
        }
        let screenname = user?.screenname!
        cell.screennameLabel.text = "@\(screenname!)"
        let username = user?.name!
        cell.usernameLabel.text = username!
        cell.contentLabel.text = tweet.text
        cell.retweetCountLabel.text! = String(tweet.retweetCount)
        cell.favorCountLabel.text! = String(tweet.favorriteCount)
        let hourInterval = self.hoursFrom(tweets[indexPath.row].createdAt!)
        cell.timeStampLabel.text = "\(hourInterval)h"
        //print(self.hoursFrom(tweets[indexPath.row].createdAt!))
        return cell
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        print("EEEE")
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    @IBAction func logoutButtonClicked(sender: AnyObject) {
        current_user!.logout()
        self.performSegueWithIdentifier("loginViewSegue", sender: self)
    }
    
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if segue.identifier == "loginViewSegue"{
            return
        }
        
        if segue.identifier == "DetailTweetSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let detailViewController = navigationController.topViewController as! DetailViewController
            let cell = sender as! TweetCell
            detailViewController.tweet = cell.tweet
            
        }else if segue.identifier == "profilePageViewSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let ProfilePageViewController = navigationController.topViewController as! profilePageViewController
            let cell = sender as! TweetCell
            ProfilePageViewController.user = cell.tweet?.user
        }else if segue.identifier == "ComposeSegue"{
            let navigationController = segue.destinationViewController as! UINavigationController
            let composeTweetViewController = navigationController.topViewController as! ComposeTweetViewController
            
        }
        
    }
    

}
