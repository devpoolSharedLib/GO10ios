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
    @IBOutlet weak var boardTableview: UITableView!
    @IBOutlet weak var commentBtnInCell: UIButton!
    @IBOutlet var boardContentView: UIView!

    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var getHotToppicByIdUrl: String!
    var checkIsLikeUrl: String!
    var updateLikeUrl: String!
    var updateDisLikeUrl: String!
    var newLikeUrl: String!
    var readTopicUrl: String!
    var isLike: Bool!
    var countLikeLbl: UILabel!
    var likeBtn: UIButton!
    var likeWithNoCommentBtn: UIButton!
    var BoardContentList = [NSDictionary]();
    var LikeModelList = [NSDictionary]();
    var topicId: String!
    var empEmail: String!
    var receiveBoardContentList: NSDictionary!
    var modelName: String!
    let cache = NSCache.init()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var _id: String!
    var _rev: String!
    var statusLike: Bool!
    var checkPushButton = false
    var postUserCD: NSMutableDictionary = NSMutableDictionary()
    var commentUserCD: NSMutableDictionary = NSMutableDictionary()
    var roomId: String!
    var commentUserArray: Array<String>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true
        print("*** BoardContentVC viewDidLoad ***")
        self.getHotToppicByIdUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/gettopicbyid?"
        self.checkIsLikeUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/checkLikeTopic?"
        self.updateLikeUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/updateLike"
        self.updateDisLikeUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/updateDisLike"
        self.newLikeUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/newLike"
        self.readTopicUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/newLike"
        self.modelName = UIDevice.currentDevice().modelName
        self.topicId = receiveBoardContentList.valueForKey("_id") as! String
        self.roomId = receiveBoardContentList.valueForKey("roomId") as! String
        
        //get Value From Core Data
        getValuefromUserInfo()
        getValuefromRoomManageInfo()
        
        self.commentUserArray = self.commentUserCD.valueForKey(roomId) as! Array<String>
        if(RoomAdminUtil.checkAccess(self.commentUserArray, empEmail: self.empEmail)){
            print("Find Comment User")
        }else{
            print("not Find Comment User")
            self.navigationItem.rightBarButtonItems?.removeAtIndex(1)
        }
        
//        checkCommentBtn(self.roomId)
//        readTopic()
//        getBoardContentWebService()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MRProgressOverlayView.showOverlayAddedTo(self.boardContentView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        print("*** BoardContentVC viewDidAppear ***")
        modelName = UIDevice.currentDevice().modelName
        topicId = receiveBoardContentList.valueForKey("_id") as! String
        print("\(NSDate().formattedISO8601) topic id : \(topicId)")
        
        // Auto Scale Height
        self.boardTableview.rowHeight = UITableViewAutomaticDimension
//       self.boardTableview.estimatedRowHeight = 100
        
        //fix bug auto scale
        self.boardContentView.setNeedsLayout()
        self.boardContentView.layoutIfNeeded()

//        getValuefromUserInfo()
        getBoardContentWebService()
        checkPushButton = false
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        print("\(NSDate().formattedISO8601) WILLDISAPPAER isLike = \(self.isLike )")
        if(self.statusLike != self.isLike && checkPushButton){
            if(self.LikeModelList.isEmpty){
                newLikeWS()
                print("DB NEW LIKE")
            }else if(self.isLike == false){
                updateDisLikeWS()
                print("BD UPDATE DisLIKE")
            }else if(self.isLike == true){
                updateLikeWS()
                print("BD UPDATE LIKE")
            }
        }else{
            print("Not Push Like Button or CountLike not Change")
        }
    }
    
    //refresh Table View
    func refreshTableView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.boardTableview.reloadData()
            MRProgressOverlayView.dismissOverlayForView(self.boardContentView, animated: true)
            print("\(NSDate().formattedISO8601)  REFRESHTABLE")
        })
    }
    
    func getValuefromUserInfo(){
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            self.empEmail = result[0].valueForKey("empEmail") as! String;
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Data");
        }
    }
  
    func getValuefromRoomManageInfo(){
        let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "Room_Manage_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            self.postUserCD = result[0].valueForKey("postUser") as! NSMutableDictionary
            self.commentUserCD = result[0].valueForKey("commentUser") as! NSMutableDictionary
//            print("Post User From Core Data : \(self.postUserCD)");
//            print("Comment User From Core Data : \(self.commentUserCD)");
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
    }
    
    
    func getBoardContentWebService(){
        print("\(NSDate().formattedISO8601) getBoardContentWebService")
        let urlWs = NSURL(string: "\(self.getHotToppicByIdUrl)topicId=\(self.topicId)&empEmail=\(self.empEmail)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.BoardContentList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                self.checkIsLikeWebservice()
                self.refreshTableView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601)  error : \(error.localizedDescription)")
            }
        }
        requestSent.resume()
    }
    
    
    func checkIsLikeWebservice(){
        print("\(NSDate().formattedISO8601) checkIsLikeWS")
        let urlcheckIsLikeWs = NSURL(string: "\(self.checkIsLikeUrl)topicId=\(self.topicId)&empEmail=\(self.empEmail)")
        print("\(NSDate().formattedISO8601) URL : \(urlcheckIsLikeWs)")
        let request = NSMutableURLRequest(URL: urlcheckIsLikeWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.LikeModelList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
//                print("\(NSDate().formattedISO8601) LikeModel \(self.LikeModelList)")
                  dispatch_async(dispatch_get_main_queue(), {
                if(self.LikeModelList.isEmpty){
                    self.isLike = false
                    print("LIKEMODEL IS NULL")
                }else{
                    self._id = self.LikeModelList[0].valueForKey("_id") as! String
                    self._rev = self.LikeModelList[0].valueForKey("_rev") as! String
                    self.statusLike = self.LikeModelList[0].valueForKey("statusLike") as! Bool
                    if(self.statusLike == true){
                        self.likeBtn.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), forState: .Normal)
                        self.isLike = true
                        print("LIKEMODEL IS TRUE")
                    }else{
                        self.likeBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Normal)
                        self.isLike = false
                        print("LIKEMODEL IS FALSE")
                    }
                }
                })
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601)  error : \(error.localizedDescription)")
            }
        }
        requestSent.resume()
    }

    func readTopic(){
            print("\(NSDate().formattedISO8601) readTopicWs")
            let urlreadTopicWs = NSURL(string: "\(self.readTopicUrl)topicId=\(self.topicId)&empEmail=\(self.empEmail)")
            print("\(NSDate().formattedISO8601) URL : \(urlreadTopicWs)")
            let request = NSMutableURLRequest(URL: urlreadTopicWs!)
            request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
            let urlsession = NSURLSession.sharedSession()
            let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
                do{
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
        let boardContentBean = self.BoardContentList[indexPath.row]
        print(boardContentBean)
        let cell: UITableViewCell
        if boardContentBean.valueForKey("type") as! String == "host" {
            cell = tableView.dequeueReusableCellWithIdentifier("hostCell", forIndexPath: indexPath)
            let hostSubjectLbl = cell.viewWithTag(31) as! UILabel;
            let hostContentLbl = cell.viewWithTag(32) as! ActiveLabel;
            let hostImg = cell.viewWithTag(33) as! UIImageView;
            let hostNameLbl = cell.viewWithTag(34) as! UILabel;
            let hostTimeLbl = cell.viewWithTag(35) as! UILabel;
            self.countLikeLbl = cell.viewWithTag(40) as! UILabel;
            self.likeBtn = cell.viewWithTag(41) as! UIButton;
            self.commentBtnInCell = cell.viewWithTag(42) as! UIButton;
            
            //disabled comment Button if Ineligible
            if(RoomAdminUtil.checkAccess(self.commentUserArray, empEmail: self.empEmail)){
                self.likeBtn = cell.viewWithTag(44) as! UIButton;
                self.likeBtn.hidden = true
                self.likeBtn = cell.viewWithTag(41) as! UIButton;
                print("Find Comment User")
            }else{
                
                print("not Find Comment User")
                self.commentBtnInCell.removeFromSuperview()
                self.likeBtn.removeFromSuperview()
                self.likeBtn = cell.viewWithTag(44) as! UIButton;

            }
            
            if(modelName.rangeOfString("ipad Mini") != nil){
                hostSubjectLbl.font = FontUtil.ipadminiTopicName
//                hostContentLbl.font = FontUtil.ipadminiPainText
                hostNameLbl.font = FontUtil.ipadminiDateTime
                hostTimeLbl.font = FontUtil.ipadminiDateTime
                self.countLikeLbl.font = FontUtil.ipadminiDateTime
            }
            
            hostSubjectLbl.text =  boardContentBean.valueForKey("subject") as? String
            let htmlData = boardContentBean.valueForKey("content") as? String
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
//                var myAttribute = [ NSFontAttributeName: FontModel.iphonepainText! ]
//                
//                if(modelName.rangeOfString("ipad Mini") != nil){
//                    myAttribute = [ NSFontAttributeName: FontModel.ipadminiPainText! ]
//                }
            
                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
                                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                
//                let strMU =  try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
//                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
//                
//                let strMU = NSMutableAttributedString(attributedString:strNS)
//
//                strMU.addAttributes(myAttribute,range:NSMakeRange(0, strMU.length))
                
//                strNS = NSAttributedString(attributedString: strMU)
                
//                hostContentLbl.font = FontModel.iphonepainText
                hostContentLbl.numberOfLines = 0
                hostContentLbl.lineSpacing = 20
                hostContentLbl.attributedText = strNS
                openLink(hostContentLbl)
            }catch let error as NSError{
                print("error : \(error.localizedDescription)")
            }
            
            let picAvatar = boardContentBean.valueForKey("avatarPic") as? String
            hostImg.image = UIImage(named: picAvatar!)
            hostNameLbl.text =  boardContentBean.valueForKey("avatarName") as? String
            hostTimeLbl.text =  boardContentBean.valueForKey("date") as? String
            if(boardContentBean.valueForKey("countLike") != nil){
                self.countLikeLbl.text = String(boardContentBean.valueForKey("countLike") as! Int)
            }else{
                self.countLikeLbl.text = "0"
            }
//            self.countLikeLbl.text = String(boardContentBean.valueForKey("countLike") as! Int)
            
            if(boardContentBean.valueForKey("countRead") != nil){
                print(">>>>> count read >>>> \(boardContentBean.valueForKey("countRead"))")
            }else{
                print(">>>>> count read >>>> 0)")
            }
            
        }else if boardContentBean.valueForKey("type") as! String == "comment" {
            cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
            let commentContentLbl = cell.viewWithTag(36) as! ActiveLabel;
            let commentImg = cell.viewWithTag(37) as! UIImageView;
            let commentNameLbl = cell.viewWithTag(38) as! UILabel;
            let commentTimeLbl = cell.viewWithTag(39) as! UILabel;
            if(modelName.rangeOfString("ipad Mini") != nil){
//                commentContentLbl.font = FontModel.ipadminiPainText
                commentNameLbl.font = FontUtil.ipadminiDateTime
                commentTimeLbl.font = FontUtil.ipadminiDateTime
            }else{
                commentNameLbl.font = FontUtil.iphoneDateTime
                commentTimeLbl.font = FontUtil.iphoneDateTime
            }
            let htmlData = boardContentBean.valueForKey("content") as? String
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
//                var myAttribute = [ NSFontAttributeName: FontModel.iphonepainText! ]
//                if(modelName.rangeOfString("ipad Mini") != nil){
//                    myAttribute = [ NSFontAttributeName: FontModel.ipadminiPainText! ]
//                }
                
                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                
//                let strMU = try NSMutableAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
//                strMU.addAttributes(myAttribute,range:NSMakeRange(0, strMU.length))
//                strMU.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, strMU.length))
                
                commentContentLbl.lineSpacing = 20
                commentContentLbl.numberOfLines = 0
                commentContentLbl.attributedText = strNS
                openLink(commentContentLbl)
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
            let picAvatar = boardContentBean.valueForKey("avatarPic") as? String
            commentImg.image = UIImage(named: picAvatar!)
            commentNameLbl.text =  boardContentBean.valueForKey("avatarName") as? String
            commentTimeLbl.text =  boardContentBean.valueForKey("date") as? String
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
                label.font = FontUtil.ipadminiPainText
            }else{
                label.font = FontUtil.iphonepainText
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
    
    func newLikeWS(){
        print("\(NSDate().formattedISO8601) newLikeWS")
        let urlWs = NSURL(string: self.newLikeUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        let jsonObj = "{\"topicId\":\"\(self.topicId)\",\"empEmail\":\"\(self.empEmail)\",\"statusLike\":\(self.isLike),\"type\":\"like\"}"
        
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        
        
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
        //        requestPost.timeoutInterval = 30
        requestPost.HTTPMethod = "POST"
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithRequest(requestPost) { (data, response, error) in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }
            
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("\(NSDate().formattedISO8601) responseString = \(responseString)")
        }
        request.resume()
        
    }
    
    func updateLikeWS() {
        print("\(NSDate().formattedISO8601) updateLikeWS")
        let urlWs = NSURL(string: self.updateLikeUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        
        let jsonObj = "{\"_id\":\"\(self._id)\",\"_rev\":\"\(self._rev)\",\"topicId\":\"\(self.topicId)\",\"empEmail\":\"\(self.empEmail)\",\"statusLike\":\"\(self.isLike)\",\"type\":\"like\"}"
        
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
        requestPost.HTTPMethod = "PUT"
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithRequest(requestPost) { (data, response, error) in
        guard error == nil && data != nil else {
            print("error=\(error)")
            return
        }
        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
            print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
            print("\(NSDate().formattedISO8601) response = \(response)")
        }
        
        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
        print("\(NSDate().formattedISO8601) responseString = \(responseString)")
        }
        request.resume()
    }
    
    func updateDisLikeWS() {
        print("\(NSDate().formattedISO8601) updateDisLikeWS")
        let urlWs = NSURL(string: self.updateDisLikeUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        let jsonObj = "{\"_id\":\"\(self._id)\",\"_rev\":\"\(self._rev)\",\"topicId\":\"\(self.topicId)\",\"empEmail\":\"\(self.empEmail)\",\"statusLike\":\"\(self.isLike)\",\"type\":\"like\"}"
        
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
        requestPost.HTTPMethod = "PUT"
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithRequest(requestPost) { (data, response, error) in
            guard error == nil && data != nil else {
                print("error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("\(NSDate().formattedISO8601) responseString = \(responseString)")
        }
        request.resume()
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        checkPushButton = true
        if(self.isLike == false){
            self.countLikeLbl.text = String(Int(self.countLikeLbl.text!)! + 1)
//            self.likeBtn.backgroundColor = UIColor.blueColor()
            self.likeBtn.setTitleColor(UIColor(red: 0, green: 128/255, blue: 1, alpha: 1), forState: .Normal)
            self.isLike = true
        }else if(self.isLike == true){
            self.countLikeLbl.text = String(Int(self.countLikeLbl.text!)! - 1)
//            self.likeBtn.backgroundColor = UIColor.whiteColor()
            self.likeBtn.setTitleColor(UIColor.blackColor().colorWithAlphaComponent(0.5), forState: .Normal)
            self.isLike = false
        }
    }
    
    @IBAction func showComment(sender: AnyObject) {
        self.performSegueWithIdentifier("openComment", sender:nil)
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
