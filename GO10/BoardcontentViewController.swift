//
//  BoardcontentViewController.swift
//  GO10
//
//  Created by Go10Application on 5/11/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import ActiveLabel
import MRProgress
import CoreData

class BoardcontentViewController: UIViewController,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var goCommentBtn: UIButton!
    
    
    
    var BoardContentList = [NSDictionary]();
    var topicId: String!
    var receiveBoardContentList: NSDictionary!
    var modelName: String!
    let cache = NSCache.init()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

    @IBOutlet var boardContentView: UIView!
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** BoardContentVC viewDidAppear ***")
        modelName = UIDevice.currentDevice().modelName
        topicId = receiveBoardContentList.valueForKey("_id") as! String
        print("\(NSDate().formattedISO8601) topic id : \(topicId)")
        // Auto Scale Height
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        //fix bug auto scale
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
         MRProgressOverlayView.showOverlayAddedTo(self.boardContentView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        getBoardContentWebService()
    }
    
    //refresh Table View
    func refreshTableView(){
        dispatch_async(dispatch_get_main_queue(), {
            MRProgressOverlayView.dismissOverlayForView(self.boardContentView, animated: true)
            self.tableView.reloadData()
            print("\(NSDate().formattedISO8601)  REFRESHTABLE)")
        })
    }
    
    func getBoardContentWebService(){
        
        print("\(NSDate().formattedISO8601) getBoardContentWebService")
        let urlWs = NSURL(string: "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/topic/gettopicbyid?topicId=\(topicId)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithURL(urlWs!) { (data, response, error) in
            do{
                self.BoardContentList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
//                self.cache.setValue(self.BoardContentList , forKey: "boardCache")
                self.cache.setObject(self.BoardContentList, forKey: "boardCache")
//                let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
//                do{
//                    let fetchReq = NSFetchRequest(entityName: "User_Info");
//                    let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
//                    result[0].setValue(self.BoardContentList, forKey: "boardContent")
//                    
//                }catch{
//                    print("\(NSDate().formattedISO8601) Error Reading Data");
//                }

                
                print("\(NSDate().formattedISO8601) boardcontent size : \(self.BoardContentList.count)")
                
                self.refreshTableView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601)  error : \(error.localizedDescription)")
            }
        }
        request.resume()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BoardContentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx")
        let boradContentBean = self.BoardContentList[indexPath.row]
//        let boradContentBean = self.cache.objectForKey("boardCache")!
        
        print(boradContentBean)
//        print("\(NSDate().formattedISO8601) bean : \(boradContentBean)")
        let cell: UITableViewCell
        
        if boradContentBean.valueForKey("type") as! String == "host" {
            cell = tableView.dequeueReusableCellWithIdentifier("hostCell", forIndexPath: indexPath)
            
            let hostSubjectLbl = cell.viewWithTag(31) as! UILabel;
            let hostContentLbl = cell.viewWithTag(32) as! ActiveLabel;
            let hostImg = cell.viewWithTag(33) as! UIImageView;
            let hostNameLbl = cell.viewWithTag(34) as! UILabel;
            let hostTimeLbl = cell.viewWithTag(35) as! UILabel;
            
            if(modelName.rangeOfString("ipad Mini") != nil){
                hostSubjectLbl.font = FontModel.ipadminiTopicName
//                hostContentLbl.font = UIFont(name:"Helvetica Neue", size:16)
                hostNameLbl.font = FontModel.ipadminiDateTime
                hostTimeLbl.font = FontModel.ipadminiDateTime
            }
            hostSubjectLbl.text =  boradContentBean.valueForKey("subject") as? String
                        
            let htmlData = boradContentBean.valueForKey("content") as? String
            
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{

                let str = try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                
                //set line space
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 20
                
                str.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, str.length))
                
                hostContentLbl.attributedText = str
                openLink(hostContentLbl)
            }catch let error as NSError{
                print("error : \(error.localizedDescription)")
            }

//            let url = NSURL(string: "http://go10webservice.au-syd.mybluemix.net/GO10WebService/images/Avatar/avatar_ronaldo.png")
//            let data = NSData(contentsOfURL: url!)
//            hostImg.image = UIImage(data: data!)
            let picAvatar = boradContentBean.valueForKey("avatarPic") as? String
            hostImg.image = UIImage(named: picAvatar!)
            hostNameLbl.text =  boradContentBean.valueForKey("avatarName") as? String
            hostTimeLbl.text =  boradContentBean.valueForKey("date") as? String
            
            
        }else if boradContentBean.valueForKey("type") as! String == "comment" {
            cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
            let commentContentLbl = cell.viewWithTag(36) as! ActiveLabel;
            let commentImg = cell.viewWithTag(37) as! UIImageView;
            let commentNameLbl = cell.viewWithTag(38) as! UILabel;
            let commentTimeLbl = cell.viewWithTag(39) as! UILabel;
            
            if(modelName.rangeOfString("ipad Mini") != nil){
//                commentContentLbl.font = UIFont(name:"Helvetica Neue", size:16)
                commentNameLbl.font = FontModel.ipadminiDateTime
                commentTimeLbl.font = FontModel.ipadminiDateTime
            }
            
            let htmlData = boradContentBean.valueForKey("content") as? String
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
                let str = try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: NSUTF8StringEncoding], documentAttributes: nil)
                
                //set line space
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.lineSpacing = 20
                
                str.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, str.length))
                commentContentLbl.attributedText = str
                openLink(commentContentLbl)
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
            
//            let randnumbers =  arc4random_uniform(9)+1
//            commentImg.image = UIImage(named: "man0\(randnumbers)")
            let picAvatar = boradContentBean.valueForKey("avatarPic") as? String
            commentImg.image = UIImage(named: picAvatar!)
            commentNameLbl.text =  boradContentBean.valueForKey("avatarName") as? String
            commentTimeLbl.text =  boradContentBean.valueForKey("date") as? String
            
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("noCell", forIndexPath: indexPath)
        }
            return cell
        
        
    }
    
    func openLink(activeLabel: ActiveLabel){
        activeLabel.customize { label in
            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
            //                label.URLColor = UIColor(red: 85.0/255, green: 238.0/255, blue: 151.0/255, alpha: 1)
            label.hashtagColor = UIColor.blueColor()
            label.mentionColor = UIColor.blueColor()
            label.URLColor = UIColor.blueColor()
            if(self.modelName.rangeOfString("ipad Mini") != nil){
                label.font = FontModel.ipadminiPainText
            }
            
            label.handleURLTap({ (url) in
                
                let strUrl: String!
                let openUrl: NSURL!
                if(url.absoluteString.rangeOfString("http://") == nil && url.absoluteString.rangeOfString("https://") == nil){
                    strUrl = "http://\(url)"
                     openUrl = NSURL(string: strUrl)!
                }else{
                    openUrl = url
                }
                
                print("\(NSDate().formattedISO8601) OpenUrl: \(openUrl)")
                
                UIApplication.sharedApplication().openURL(openUrl)
            })
        }

    }
    
    @IBAction func showCommentPage(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("openComment", sender:nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openComment" {
            let destVC = segue.destinationViewController as! CommentViewController
            destVC.receiveComment = receiveBoardContentList

        }
    }
    
    @IBAction func unwindToBoardVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToBoardVC")
    }
}
