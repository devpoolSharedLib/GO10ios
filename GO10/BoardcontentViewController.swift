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

    @IBOutlet weak var goPollBtn: UIButton!
    
    
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqRoomManageInfo = NSFetchRequest(entityName: "Room_Manage_Info")
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var contexroot = PropertyUtil.getPropertyFromPlist("data",key: "contexroot")
//    var objectStorageUrl = PropertyUtil.getPropertyFromPlist("data",key: "downloadObjectStorage")
    var getHotToppicByIdUrl: String!
    var checkIsLikeUrl: String!
    var updateLikeUrl: String!
    var updateDisLikeUrl: String!
    var newLikeUrl: String!
    var readTopicUrl: String!
    var deletObjUrl: String!
    var downloadObjectStorageUrl : String!
    var topicId: String!
    var empEmail: String!
    var receiveFromPage: String!
    var modelName: String!
    var _id: String!
    var _rev: String!
    var roomId: String!
    var roomName: String!
    var isLike: Bool!
    var statusLike: Bool!
    var checkPushButton = false
    
    var countLikeLbl: UILabel!
    var likeBtn: UIButton!
    var likeWithNoCommentBtn: UIButton!
    var hostDeleteBtn : UIButton!
    var commentDeleteBtn: UIButton!
    var countAcceptPollImg: UIImageView!
    var countAcceptPollLbl: UILabel!
    
    var BoardContentList = [NSDictionary]()
    var pollModel: AnyObject!
    var LikeModelList = [NSDictionary]()
    var getTopicById = [NSDictionary]()
    var receiveBoardContentList: NSDictionary!
    var receiveRoomList: NSDictionary!
    var postUserCD: NSMutableDictionary = NSMutableDictionary()
    var commentUserCD: NSMutableDictionary = NSMutableDictionary()
    var commentUserArray: Array<String>!
    
    var countAcceptPoll: AnyObject!
    var donePoll: Bool!
    let cache = NSCache.init()
   
    var refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftItemsSupplementBackButton = true
        print("*** BoardContentVC viewDidLoad ***")
        self.getHotToppicByIdUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/gettopicbyid?"
        self.checkIsLikeUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/checkLikeTopic?"
        self.updateLikeUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/updateLike"
        self.updateDisLikeUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/updateDisLike"
        self.newLikeUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/newLike"
        self.deletObjUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/deleteObj"
        self.readTopicUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/readtopic?"
        self.downloadObjectStorageUrl = "\(self.domainUrl)\(contexroot)DownloadServlet?imageName="
        self.modelName = UIDevice.currentDevice().modelName
        self.topicId = receiveBoardContentList.valueForKey("_id") as! String
        self.roomId = receiveBoardContentList.valueForKey("roomId") as! String
        
        
//        let image = UIImage(named: "poll") as UIImage?
//        self.goPollBtn.setImage(nil, forState: UIControlState.Normal)
        self.goPollBtn.hidden = true
        self.goPollBtn.enabled = true
        
        self.boardContentView.bringSubviewToFront(self.goPollBtn)
        //get Value From Core Data
        getValuefromUserInfo()
        getValuefromRoomManageInfo()
        self.readTopicWebservice(self.empEmail, topicId: self.topicId)
        self.commentUserArray = self.commentUserCD.valueForKey(roomId) as! Array<String>
        if(RoomAdminUtil.checkAccess(self.commentUserArray, empEmail: self.empEmail)){
            print("User Can Comment")
        }else{
            print("User Can't Comment")
            self.navigationItem.rightBarButtonItems?.removeAtIndex(1)
        }
        
        
        refreshControl.addTarget(self, action: #selector(SelectRoomViewController.refreshPage), forControlEvents: .ValueChanged)
        boardTableview.addSubview(refreshControl)
    }
    
    func refreshPage(){
        getBoardContentWebService()
        refreshControl.endRefreshing()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
                MRProgressOverlayView.showOverlayAddedTo(self.boardContentView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        print("*** BoardContentVC viewDidAppear ***")
        self.modelName = UIDevice.currentDevice().modelName
        self.topicId = receiveBoardContentList.valueForKey("_id") as! String
        self.roomId = receiveBoardContentList.valueForKey("roomId") as! String
        // Auto Scale Height
        self.boardTableview.rowHeight = UITableViewAutomaticDimension
//       self.boardTableview.estimatedRowHeight = 100
        
        //fix bug auto scale
        self.boardContentView.setNeedsLayout()
        self.boardContentView.layoutIfNeeded()

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
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            self.empEmail = result[0].valueForKey("empEmail") as! String
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Data")
        }
    }
  
    func getValuefromRoomManageInfo(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqRoomManageInfo) as! [NSManagedObject]
            self.postUserCD = result[0].valueForKey("postUser") as! NSMutableDictionary
            self.commentUserCD = result[0].valueForKey("commentUser") as! NSMutableDictionary
//            print("Post User From Core Data : \(self.postUserCD)")
//            print("Comment User From Core Data : \(self.commentUserCD)")
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
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
//                self.BoardContentList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                
                self.getTopicById = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                
                self.BoardContentList = self.getTopicById[0].valueForKey("boardContentList") as! [NSDictionary];()
                if (self.getTopicById[0].valueForKey("pollModel")  == nil){
                    self.pollModel = nil
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                      self.goPollBtn.hidden = true
                    }
                    
                }else{
                    self.pollModel = self.getTopicById[0].valueForKey("pollModel") as! [NSDictionary];()
                    print("ppppppppppppp")
                    self.donePoll = self.getTopicById[0].valueForKey("donePoll") as! Bool
                    print("DONE POLL : \(self.donePoll)")
                    
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        if((self.donePoll) == true){
                            let image = UIImage(named: "donePoll") as UIImage?
                            self.goPollBtn.setImage(image, forState: UIControlState.Normal)
                            self.goPollBtn.enabled = false
                        }else{
                            let image = UIImage(named: "poll") as UIImage?
                            self.goPollBtn.setImage(image, forState: UIControlState.Normal)
                            self.goPollBtn.enabled = true
                        }
                        self.goPollBtn.hidden = false
                    }
//                   print("POLL MODEL xx : \(self.pollModel)")
//                    print("XXX : \(self.pollModel.valueForKey("empEmailPoll") as! Array<String>)")
//                    let empEmailPoll = self.pollModel.valueForKey("empEmailPoll") as! Array<String>
//                    if(RoomAdminUtil.checkAccess(empEmailPoll, empEmail: self.empEmail)){
//                        print("User has poll")
//                         self.goPollBtn.hidden = false
//                    }else{
//                        print("User hasn't poll")
//                    }

                }
                
                if(self.getTopicById[0].valueForKey("countAcceptPoll") == nil){
                    self.countAcceptPoll = nil
                    
                }else{
                    self.countAcceptPoll = self.getTopicById[0].valueForKey("countAcceptPoll") as! Int
                   
                }
                
                print("BOARD CONTENT LIST : \(self.BoardContentList)")
                 print("POLL MODEL : \(self.pollModel)")
                 print("COUNT ACCEPT POLL : \(self.countAcceptPoll)")
                
               
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
                        self.likeBtn.setTitleColor(ColorUtil.pressLikeBtnColor, forState: .Normal)
                        self.isLike = true
                        print("LIKEMODEL IS TRUE")
                    }else{
                        self.likeBtn.setTitleColor(ColorUtil.normalLikeBtnColor, forState: .Normal)
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

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BoardContentList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let boardContentBean = self.BoardContentList[indexPath.row]
//        print(boardContentBean)
        let cell: UITableViewCell
        if boardContentBean.valueForKey("type") as! String == "host" {
            cell = tableView.dequeueReusableCellWithIdentifier("hostCell", forIndexPath: indexPath)
            let hostSubjectLbl = cell.viewWithTag(31) as! UILabel
            let hostContentLbl = cell.viewWithTag(32) as! ActiveLabel
            let hostImg = cell.viewWithTag(33) as! UIImageView
            let hostNameLbl = cell.viewWithTag(34) as! UILabel
            let hostTimeLbl = cell.viewWithTag(35) as! UILabel
            
            self.countLikeLbl = cell.viewWithTag(40) as! UILabel
            self.likeBtn = cell.viewWithTag(41) as! UIButton
            self.commentBtnInCell = cell.viewWithTag(42) as! UIButton
            
            self.hostDeleteBtn = cell.viewWithTag(46) as! UIButton
            self.countAcceptPollImg = cell.viewWithTag(47) as! UIImageView
            self.countAcceptPollLbl = cell.viewWithTag(48) as! UILabel
            
            
            if(self.pollModel == nil){
                self.countAcceptPollImg.hidden = true
                self.countAcceptPollLbl.hidden = true
            }else{
                self.countAcceptPollImg.hidden = false
                self.countAcceptPollLbl.hidden = false
                
                self.countAcceptPollLbl.text = String(self.countAcceptPoll as! NSNumber)
                
            }

            
            
            
            if(boardContentBean.valueForKey("empEmail") as! String == self.empEmail){
                print("This user is post topic")
                 self.hostDeleteBtn.hidden = false
            }else{
                print("This user isn't post topic")
               self.hostDeleteBtn.hidden = true
            }
            
            //disabled comment Button if Ineligible
            if(RoomAdminUtil.checkAccess(self.commentUserArray, empEmail: self.empEmail)){
                self.likeBtn = cell.viewWithTag(44) as! UIButton
                self.likeBtn.hidden = true
                self.likeBtn = cell.viewWithTag(41) as! UIButton
                print("Find Comment User")
            }else{
                print("not Find Comment User")
                self.commentBtnInCell.removeFromSuperview()
                self.likeBtn.removeFromSuperview()
                self.likeBtn = cell.viewWithTag(44) as! UIButton
            }
            
            if(modelName.rangeOfString("ipad Mini") != nil){
                hostSubjectLbl.font = FontUtil.ipadminiTopicName
                hostNameLbl.font = FontUtil.ipadminiDateTime
                hostTimeLbl.font = FontUtil.ipadminiDateTime
                self.countLikeLbl.font = FontUtil.ipadminiDateTime
            }
            
            hostSubjectLbl.text =  boardContentBean.valueForKey("subject") as? String
            let htmlData = boardContentBean.valueForKey("content") as? String
            let htmlReplace = htmlData!.stringByReplacingOccurrencesOfString("\\\"", withString: "\"")
            print("\(NSDate().formattedISO8601) htmlReplace : \(htmlReplace)")
            do{
                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
                                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                hostContentLbl.numberOfLines = 0
                hostContentLbl.lineSpacing = 20
                hostContentLbl.attributedText = strNS
                openLink(hostContentLbl)
            }catch let error as NSError{
                print("error : \(error.localizedDescription)")
            }
            
            let picAvatar = boardContentBean.valueForKey("avatarPic") as? String
//            hostImg.image = UIImage(named: picAvatar!)
            
            let avatarImageCheck = UIImage(named: picAvatar!)
            if(avatarImageCheck != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(picAvatar!)")
                hostImg.image = UIImage(named: picAvatar!)
            }else{
                print("\(NSDate().formattedISO8601) avatarImage : \(picAvatar!)")
                let picUrl = self.downloadObjectStorageUrl + picAvatar!
                let url = NSURL(string:picUrl)!
                hostImg.af_setImageWithURL(url)
            }

            hostNameLbl.text =  boardContentBean.valueForKey("avatarName") as? String
            hostTimeLbl.text =  boardContentBean.valueForKey("date") as? String
            
            if(boardContentBean.valueForKey("countLike") != nil){
                self.countLikeLbl.text = String(boardContentBean.valueForKey("countLike") as! Int)
            }else{
                self.countLikeLbl.text = "0"
            }
            
            if(boardContentBean.valueForKey("countRead") != nil){
                print(">>>>> count read this topic>>>> \(boardContentBean.valueForKey("countRead"))")
            }else{
                print(">>>>> count read this topic >>>> 0)")
            }
        }else if boardContentBean.valueForKey("type") as! String == "comment" {
            cell = tableView.dequeueReusableCellWithIdentifier("commentCell", forIndexPath: indexPath)
            let commentContentLbl = cell.viewWithTag(36) as! ActiveLabel
            let commentImg = cell.viewWithTag(37) as! UIImageView
            let commentNameLbl = cell.viewWithTag(38) as! UILabel
            let commentTimeLbl = cell.viewWithTag(39) as! UILabel
             self.commentDeleteBtn = cell.viewWithTag(45) as! UIButton

            if(boardContentBean.valueForKey("empEmail") as! String == self.empEmail){
                print("This user is comment topic")
                 self.commentDeleteBtn.hidden = false
            }else{
                print("This user isn't comment topic")
                self.commentDeleteBtn.hidden = true
            }
            
            if(modelName.rangeOfString("ipad Mini") != nil){
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
                let strNS = try NSAttributedString(data: htmlReplace.dataUsingEncoding(NSUnicodeStringEncoding, allowLossyConversion: true)!, options: [
                    NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType], documentAttributes: nil)
                commentContentLbl.lineSpacing = 20
                commentContentLbl.numberOfLines = 0
                commentContentLbl.attributedText = strNS
                openLink(commentContentLbl)
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
            let picAvatar = boardContentBean.valueForKey("avatarPic") as? String
            
//            commentImg.image = UIImage(named: picAvatar!)
            let avatarImageCheck = UIImage(named: picAvatar!)
            if(avatarImageCheck != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(picAvatar!)")
                commentImg.image = UIImage(named: picAvatar!)
            }else{
                print("\(NSDate().formattedISO8601) avatarImage : \(picAvatar!)")
                let picUrl = self.downloadObjectStorageUrl + picAvatar!
                let url = NSURL(string:picUrl)!
                commentImg.af_setImageWithURL(url)
            }
            
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
//            label.hashtagColor = UIColor(red: 85.0/255, green: 172.0/255, blue: 238.0/255, alpha: 1)
//            label.mentionColor = UIColor(red: 238.0/255, green: 85.0/255, blue: 96.0/255, alpha: 1)
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
    

    @IBAction func hostSelectButton(sender: AnyObject) {
        if let superview = sender.superview, let cell = superview!.superview as? UITableViewCell {
            if let indexPath = boardTableview.indexPathForCell(cell) {
                selectTypeManageTopic(indexPath.row,btn: self.hostDeleteBtn)
            }
        }
    }
    
    @IBAction func commentSelectButton(sender: AnyObject) {
        if let superview = sender.superview, let cell = superview!.superview as? UITableViewCell {
            if let indexPath = boardTableview.indexPathForCell(cell) {
                selectTypeManageTopic(indexPath.row,btn:self.commentDeleteBtn)
            }
        }
    }
    
    func selectTypeManageTopic(indexPath: Int,btn: UIButton){
        print("Called buttonDeletePressed")
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
            // ...
        }
        
        let deletePost = UIAlertAction(title: "Delete", style: .Default) { action in
            print("Press Delete Post")
            self.getDeleteWS(self.BoardContentList[indexPath])
        }
        alertController.addAction(deletePost)
        alertController.addAction(cancelAction)
        //        self.presentViewController(alertController, animated: true, completion: nil)
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Pad )
        {
            if let currentPopoverpresentioncontroller = alertController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = btn
                currentPopoverpresentioncontroller.sourceRect = btn.bounds;
                currentPopoverpresentioncontroller.permittedArrowDirections = UIPopoverArrowDirection.Right;
                self.presentViewController(alertController, animated: true, completion: nil)
            }
        }else{
            self.presentViewController(alertController, animated: true, completion: nil)
        }
        
    }
    
    func getDeleteWS(boardContentBean: NSDictionary){
         let MRProgressAF = MRProgressOverlayView.showOverlayAddedTo(self.boardContentView, animated: true)
        print("\(NSDate().formattedISO8601) getDeleteWS")
        let urlWs = NSURL(string: self.deletObjUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        let _id = boardContentBean.valueForKey("_id") as! String
        let _rev = boardContentBean.valueForKey("_rev") as! String
        
        let empEmail = boardContentBean.valueForKey("empEmail") as! String
        let avatarName = boardContentBean.valueForKey("avatarName") as! String
        let avatarPic = boardContentBean.valueForKey("avatarPic") as! String
        let content = boardContentBean.valueForKey("content") as! String
       
        let date = boardContentBean.valueForKey("date") as! String
        let type = boardContentBean.valueForKey("type") as! String
        let roomId = boardContentBean.valueForKey("roomId") as! String
        var subject: String!
        var topicId: String!
        
        if(type == "host"){
            subject = boardContentBean.valueForKey("subject") as! String
            topicId = ""
        }else{
            subject = ""
            topicId = boardContentBean.valueForKey("topicId") as! String
        }

        let jsonObj = "{\"_id\":\"\(_id)\",\"_rev\":\"\(_rev)\",\"topicId\":\"\(topicId)\",\"empEmail\":\"\(empEmail)\",\"avatarName\":\"\(avatarName)\",\"avatarPic\":\"\(avatarPic)\",\"content\":\"\(content)\",\"subject\":\"\(subject)\",\"date\":\"\(date)\",\"type\":\"\(type)\",\"roomId\":\"\(roomId)\"}"
     
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
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
            
            if(type == "host"){
                if(self.receiveFromPage == "SelectRoomPage"){
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("unwindToSelectRoomVCID", sender:nil)
                    })
                }else{
                    dispatch_async(dispatch_get_main_queue(), {
                        self.performSegueWithIdentifier("unwindToRoomVCID", sender:nil)
                    })
                }
            }else{
               self.getBoardContentWebService()
            }
           
//            MRProgressOverlayView.dismissOverlayForView(self.boardContentView, animated: true)
        }
        request.resume()
        MRProgressAF.setModeAndProgressWithStateOfTask(request)
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

    func readTopicWebservice(empEmail: String,topicId: String){
        print("\(NSDate().formattedISO8601) readTopic")
        
        let urlWs = NSURL(string: "\(self.readTopicUrl)empEmail=\(empEmail)&topicId=\(topicId)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil && data != nil else {
                print("\(NSDate().formattedISO8601) error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 201 {
                print("\(NSDate().formattedISO8601) statusCode should be 201, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }else{
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
            }
        }
        requestSent.resume()
    }
    
    @IBAction func likeButton(sender: AnyObject) {
        checkPushButton = true
        if(self.isLike == false){
            self.countLikeLbl.text = String(Int(self.countLikeLbl.text!)! + 1)
            self.likeBtn.setTitleColor(ColorUtil.pressLikeBtnColor, forState: .Normal)
            self.isLike = true
        }else if(self.isLike == true){
            self.countLikeLbl.text = String(Int(self.countLikeLbl.text!)! - 1)
            self.likeBtn.setTitleColor(ColorUtil.normalLikeBtnColor, forState: .Normal)
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
        }else if segue.identifier == "unwindToRoomVCID" {
            let destVC = segue.destinationViewController as! RoomViewController
            destVC.receiveRoomList = self.receiveRoomList  //send room Model (room_id , room_name)
        }else if segue.identifier == "unwindToSelectRoomVCID" {
            segue.destinationViewController as! SelectRoomViewController
        }else if segue.identifier == "gotoPoll" {
            let destVC = segue.destinationViewController as! PollViewController
            destVC.receivePollModel = self.pollModel as! [NSDictionary]
        }

        
    }
    
    
    
    @IBAction func gotoPoll(sender: AnyObject) {
        print("GOGOGO")
        self.performSegueWithIdentifier("gotoPoll", sender:nil)
    }
    
    
    @IBAction func unwindToBoardVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToBoardVC")
    }
    
 
}
