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
    
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** BoardContentVC viewDidLoad ***")
        modelName = UIDevice.currentDevice().modelName
        topicId = receiveBoardContentList.valueForKey("_id") as! String
        getBoardContentWebService()
    }

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
           
            self.tableView.reloadData()
             MRProgressOverlayView.dismissOverlayForView(self.boardContentView, animated: true)
            print("\(NSDate().formattedISO8601)  REFRESHTABLE")
        })
    }
    
    
    func getBoardContentWebService(){
        
        print("\(NSDate().formattedISO8601) getBoardContentWebService")
        let urlWs = NSURL(string: "https://go10webservice.au-syd.mybluemix.net/GO10WebService/api/topic/gettopicbyid?topicId=\(topicId)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.BoardContentList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]

//                self.cache.setObject(self.BoardContentList, forKey: "boardCache")
//                print("\(NSDate().formattedISO8601) boardcontent size : \(self.BoardContentList.count)")
                
                self.refreshTableView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601)  error : \(error.localizedDescription)")
            }
        }
        requestSent.resume()
        
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BoardContentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let boradContentBean = self.BoardContentList[indexPath.row]
        print(boradContentBean)
        let cell: UITableViewCell
        
        if boradContentBean.valueForKey("type") as! String == "host" {
            cell = tableView.dequeueReusableCellWithIdentifier("hostCell", forIndexPath: indexPath)
            
            let hostSubjectLbl = cell.viewWithTag(31) as! UILabel;
            let hostContentLbl = cell.viewWithTag(32) as! ActiveLabel;
            let hostImg = cell.viewWithTag(33) as! UIImageView;
            let hostNameLbl = cell.viewWithTag(34) as! UILabel;
            let hostTimeLbl = cell.viewWithTag(35) as! UILabel;
            let countLikeLbl = cell.viewWithTag(40) as! UILabel;
            
            
            if(modelName.rangeOfString("ipad Mini") != nil){
                hostSubjectLbl.font = FontModel.ipadminiTopicName
                hostContentLbl.font = FontModel.ipadminiPainText
                hostNameLbl.font = FontModel.ipadminiDateTime
                hostTimeLbl.font = FontModel.ipadminiDateTime
                countLikeLbl.font = FontModel.ipadminiDateTime
            }
            
            hostSubjectLbl.text =  boradContentBean.valueForKey("subject") as? String
                        
            let htmlData = boradContentBean.valueForKey("content") as? String
            
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
                
                
                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)

                
//                let strMU = try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
//                
//                //set line space
//                let paragraphStyle = NSMutableParagraphStyle()
//                paragraphStyle.lineSpacing = 10
//                
//                strMU.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, strMU.length))
                
                
                hostContentLbl.lineSpacing = 10
                hostContentLbl.attributedText = strNS
                openLink(hostContentLbl)
                
            }catch let error as NSError{
                print("error : \(error.localizedDescription)")
            }
            
            let picAvatar = boradContentBean.valueForKey("avatarPic") as? String
            hostImg.image = UIImage(named: picAvatar!)
            hostNameLbl.text =  boradContentBean.valueForKey("avatarName") as? String
            hostTimeLbl.text =  boradContentBean.valueForKey("date") as? String
            countLikeLbl.text = "12345"
            
        }else if boradContentBean.valueForKey("type") as! String == "comment" {
            cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
            let commentContentLbl = cell.viewWithTag(36) as! ActiveLabel;
            let commentImg = cell.viewWithTag(37) as! UIImageView;
            let commentNameLbl = cell.viewWithTag(38) as! UILabel;
            let commentTimeLbl = cell.viewWithTag(39) as! UILabel;
            
            if(modelName.rangeOfString("ipad Mini") != nil){
                commentContentLbl.font = FontModel.ipadminiPainText
                commentNameLbl.font = FontModel.ipadminiDateTime
                commentTimeLbl.font = FontModel.ipadminiDateTime
            }
            
            let htmlData = boradContentBean.valueForKey("content") as? String
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
                

                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                
                //set line space
//                let paragraphStyle = NSMutableParagraphStyle()
//                paragraphStyle.lineSpacing = 10
//                let strMU = try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
//                
//                strMU.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, strMU.length))

                commentContentLbl.lineSpacing = 10
                commentContentLbl.attributedText = strNS
                openLink(commentContentLbl)
                
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
            

            let picAvatar = boradContentBean.valueForKey("avatarPic") as? String
            commentImg.image = UIImage(named: picAvatar!)
            commentNameLbl.text =  boradContentBean.valueForKey("avatarName") as? String
            commentTimeLbl.text =  boradContentBean.valueForKey("date") as? String
            
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("noCell", forIndexPath: indexPath)
        }
        
            return cell
        
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
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
