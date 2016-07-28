//
//  PostDetailViewController.swift
//  PikaChat
//
//  Created by Praveen Gowda I V on 7/26/16.
//  Copyright © 2016 Gowda I V, Praveen. All rights reserved.
//

import UIKit
import FirebaseAuth
import MBProgressHUD
import DZNEmptyDataSet
import FirebaseDatabase
import IQKeyboardManagerSwift

class PostDetailViewController: UIViewController {

    var postKey: String!
    var post: [String: String]!
    
    var comments = [[String: String]]() {
        didSet {
            commentsTable.reloadData()
        }
    }
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var commentBoxHeight: NSLayoutConstraint!
    @IBOutlet weak var commentSubmitBtnHeight: NSLayoutConstraint!
    @IBOutlet weak var commentTextViewHeight: NSLayoutConstraint!
    
    @IBOutlet weak var commentsTable: UITableView!
    
    var commentTextView: UITextView!
    var commentSubmitBtn: UILabel!
    
    
    override func viewDidLoad() {
        usernameLabel.text = post["username"]
        postTextLabel.text = post["text"]
        locationLabel.text = post["location"]
        
        if let commentFieldUsername = view.viewWithTag(10) as? UILabel {
            commentFieldUsername.text = FIRAuth.auth()?.currentUser?.displayName
        }
        
        collapseCommentBox()
        
        if let commentTextView = view.viewWithTag(11) as? UITextView {
            self.commentTextView = commentTextView
            commentTextView.delegate = self
            commentTextView.keyboardDistanceFromTextField = 41
            commentTextView.inputAccessoryView = UIView()
        }
        
        if let commentSubmitBtn = view.viewWithTag(12) as? UILabel {
            self.commentSubmitBtn = commentSubmitBtn
            commentSubmitBtn.userInteractionEnabled = true
            commentSubmitBtn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(submitComment)))
        }
        
        commentsTable.delegate = self
        commentsTable.dataSource = self
        commentsTable.rowHeight = UITableViewAutomaticDimension
        commentsTable.emptyDataSetSource = self
        
        Utils.databaseRef.child("post-comments/\(postKey)").queryOrderedByKey().observeEventType(.Value, withBlock: { (snapshot) in
            var comments = [[String: String]]()
            for child in snapshot.children {
                if let child = child as? FIRDataSnapshot {
                    if let comment = child.value as? [String: String] {
                            comments.append(comment)
                        }
                    }
                }
            self.comments = comments
        })
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    @IBAction func dismissViewController() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    func expandCommentBox() {
        UIView.transitionWithView(view, duration: 0.5, options: .TransitionNone, animations: {
            self.commentBoxHeight.constant = 132
            self.commentSubmitBtnHeight.constant = 17
            self.commentTextViewHeight.constant = 61
            }, completion: { (finish) in
                self.commentTextView.becomeFirstResponder()
                IQKeyboardManager.sharedManager().reloadLayoutIfNeeded()
        })
    }
    
    func collapseCommentBox() {
        UIView.transitionWithView(view, duration: 0.5, options: .TransitionNone, animations: {
            self.commentBoxHeight.constant = 72
            self.commentSubmitBtnHeight.constant = 0
            self.commentTextViewHeight.constant = 27
            }, completion: nil)
    }
    
    func submitComment() {
        commentTextView.resignFirstResponder()
        if commentTextView.text.isEmpty {
            return
        }
        let loadingIndicator = MBProgressHUD.showHUDAddedTo(view, animated: true)
        loadingIndicator.label.text = "Posting Comment"
        let key = Utils.databaseRef.child("post-comments/\(postKey)").childByAutoId().key
        let post = [
            "commentText": commentTextView.text,
            "username": FIRAuth.auth()?.currentUser?.displayName!
        ]
        let childUpdates = [
            "post-comments/\(postKey)/\(key)": post
        ]
        Utils.databaseRef.updateChildValues(childUpdates) { (error, reference) in
            loadingIndicator.hideAnimated(true)
            if error != nil {
                
            } else {
                self.commentTextView.text = ""
            }
        }
    }
}

extension PostDetailViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(textView: UITextView) {
        expandCommentBox()
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        collapseCommentBox()
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            submitComment()
            return false
        }
        return true
    }
    
}

extension PostDetailViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 66
    }
}

extension PostDetailViewController: UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("commentsCell", forIndexPath: indexPath) as! CommentsTableViewCell
        let comment = comments[indexPath.row]
        cell.usernameLabel.text = comment["username"]
        cell.commentTextLabel.text = comment["commentText"]!
        return cell
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
}

extension PostDetailViewController: DZNEmptyDataSetSource {
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let attributes = [
            NSFontAttributeName: UIFont(name: "OpenSans", size: 16)!,
            NSForegroundColorAttributeName: UIColor(red:0.80, green:0.80, blue:0.80, alpha:1.00)
        ]
        return NSAttributedString(string: "No replies yet.", attributes: attributes)
    }
    
}