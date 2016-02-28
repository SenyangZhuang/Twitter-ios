//
//  ComposeTweetViewController.swift
//  Twitter
//
//  Created by Senyang Zhuang on 2/27/16.
//  Copyright © 2016 codepath. All rights reserved.
//

import UIKit
import AFNetworking

class ComposeTweetViewController: UIViewController, UITextViewDelegate{


    
    @IBOutlet weak var profileImgaeView: UIImageView!
    
    @IBOutlet weak var userNameLabel: UILabel!
    
    @IBOutlet weak var screenNameLabel: UILabel!

    @IBOutlet weak var contentTextView: UITextView!
    
    @IBOutlet weak var countDownLabel: UILabel!

    var placeholderLabel : UILabel!
    
    let user = User.currentUser
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentTextView.delegate = self
        let imagePath = user!.profileImageUrl!
        let url = NSURL(string: imagePath)
        self.profileImgaeView.setImageWithURL(url!)
        let screenname = user?.screenname!
        self.screenNameLabel.text = "@\(screenname!)"
        let username = user?.name!
        self.userNameLabel.text = username!

        
        let navigationBar = navigationController!.navigationBar
        navigationBar.tintColor = UIColor.blueColor()
        
        let leftButton =  UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelButtonOnClick")
        let rightButton = UIBarButtonItem(title: "Send", style: UIBarButtonItemStyle.Plain, target: self, action: "sendButtonOnClick")
        
        navigationItem.leftBarButtonItem = leftButton
        navigationItem.rightBarButtonItem = rightButton
        
        
        
        placeholderLabel = UILabel()
        placeholderLabel.text = "What's happening"
        placeholderLabel.font = UIFont.italicSystemFontOfSize(contentTextView.font!.pointSize)
        placeholderLabel.sizeToFit()
        contentTextView.addSubview(placeholderLabel)
        placeholderLabel.frame.origin = CGPointMake(5, contentTextView.font!.pointSize / 2)
        placeholderLabel.textColor = UIColor(white: 0, alpha: 0.3)
        placeholderLabel.hidden = !contentTextView.text.isEmpty
        self.contentTextView.becomeFirstResponder()
        
        // Do any additional setup after loading the view.
    }
    


    
    func textViewDidChange(textView: UITextView) {
        placeholderLabel.hidden = !textView.text.isEmpty
        if !textView.text.isEmpty{
            let textLength = textView.text.characters.count as! Int
            let leftChar = String(140 - textLength)
            self.countDownLabel.text = leftChar
        }
        
        
        
        
    }
    
    
    func sendButtonOnClick(){
        let status = self.contentTextView.text!
        let params = ["status": status] as! NSDictionary
        TwitterClient.sharedInstance.composeNewTweet(params, completion: {(error) -> () in
            self.dismissViewControllerAnimated(true, completion: { () -> Void in
                NSNotificationCenter.defaultCenter().postNotificationName("userDidPostNewTweet", object: nil)
            })
        })
        
    
    }
    
    func cancelButtonOnClick(){
        self.dismissViewControllerAnimated(true) { () -> Void in
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
