//
//  DetailViewController.swift
//  Twitter
//
//  Created by Senyang Zhuang on 2/22/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!

    @IBOutlet weak var screenNameLabel: UILabel!
    
    @IBOutlet weak var contentLabel: UILabel!
    
    @IBOutlet weak var timeStampLabel: UILabel!
    
    @IBOutlet weak var retweetCountLabel: UILabel!
    
    @IBOutlet weak var favoriteLabel: UILabel!
    
    @IBOutlet weak var retweetButton: UIButton!

    @IBOutlet weak var replyButton: UIButton!
    
    @IBOutlet weak var likeButton: UIButton!
    
    var tweet: Tweet?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let tweet = tweet{
            let user = tweet.user
            let imagePath = user?.profileImageUrl!
            let url = NSURL(string: imagePath!)
            profileImageView.setImageWithURL(url!)
            let screenname = (user?.screenname)!
            screenNameLabel.text = "@\(screenname)"
            let username = (user?.name)!
            userNameLabel.text = username
            contentLabel.text = tweet.text
            retweetCountLabel.text! = String(tweet.retweetCount)
            favoriteLabel.text! = String(tweet.favorriteCount)
            let timestamp = NSDateFormatter.localizedStringFromDate(tweet.createdAt!, dateStyle: .ShortStyle, timeStyle: .ShortStyle)
            timeStampLabel.text = timestamp
        }
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func homeButtonOnClick(sender: AnyObject) {
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
