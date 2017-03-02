//
//  RoomViewController.swift
//  GO10
//
//  Created by Go10Application on 10/5/2559 .
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import MRProgress
import CoreData

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var roomView: UIView!
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqRoomManageInfo = NSFetchRequest(entityName: "Room_Manage_Info")
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var fetchReqApplication = NSFetchRequest(entityName: "Application")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var objectStorageUrl = PropertyUtil.getPropertyFromPlist("data",key: "downloadObjectStorage")
    var getRoomByIdUrl: String!
    var roomList = [NSDictionary]()
    var roomId: String!
    var roomName: String!
    var receiveRoomList: NSDictionary!
    var modelName: String!
    var postUserCD: NSMutableDictionary = NSMutableDictionary()
    var commentUserCD: NSMutableDictionary = NSMutableDictionary()
    var readUserCD: NSMutableDictionary = NSMutableDictionary()
    var postTopicBtn: UIBarButtonItem!
    var empEmail: String!
    var refreshControl = UIRefreshControl()
    var startDate: String!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            print("*** RoomVC viewDidLoad ***")
            self.getRoomByIdUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/gettopiclistbyroom?"
            self.roomId = receiveRoomList.valueForKey("_id") as! String
            self.roomName = receiveRoomList.valueForKey("name") as! String
            lblRoom.text = roomName
            
            if(RoomModelUtil.roomImageName.valueForKey(roomId!) != nil){
                self.imgView.image = RoomModelUtil.roomImageName.valueForKey(roomId!) as? UIImage
            }
            else{
                let picUrl = self.objectStorageUrl + roomId! + ".png"
                let url = NSURL(string:picUrl)!
                print("URL Pic :  \(url)")
                //roomImg.af_setImageWithURL(url)
                self.imgView.af_setImageRoomWithURL(url)
            }
            
//            for item in  RoomModelUtil.roomImageName { // loop through data items
//                if(item.key as? String == roomId){
//                    self.imgView.image = item.value as? UIImage
//                }else{
//                    let picUrl = self.objectStorageUrl + self.roomId! + ".png"
//                    let url = NSURL(string:picUrl)!
////                    self.imgView.af_setImageWithURL(url)
//                    self.imgView.af_setImageRoomWithURL(url)
//                }
//            }
            
            //get Value From Core Data
            self.getValuefromRoomManageInfo()
            self.getValuefromUserInfo()
            self.getvaluefromApplicationCD()
            
            let postUserArray = self.postUserCD.valueForKey(roomId) as! Array<String>
            if(RoomAdminUtil.checkAccess(postUserArray, empEmail: self.empEmail)){
                print("Find Post User")
            }else{
                print("not Find Post User")
                self.navigationItem.rightBarButtonItems?.removeAtIndex(1)
            }
            
            refreshControl.addTarget(self, action: #selector(SelectRoomViewController.refreshPage), forControlEvents: .ValueChanged)
            tableView.addSubview(refreshControl)
        }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** RoomVC viewDidAppear ***")
        modelName = UIDevice.currentDevice().modelName
        print("\(NSDate().formattedISO8601) room id : \(self.roomId)")
        MRProgressOverlayView.showOverlayAddedTo(self.roomView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        getRoomByIdWebService()
    }
    
    func refreshPage(){
        getRoomByIdWebService()
        refeshTableView()
        refreshControl.endRefreshing()
    }
    
    func getRoomByIdWebService(){
        print("\(NSDate().formattedISO8601) getRoomByIdWebService")
        let strUrl = "\(self.getRoomByIdUrl)roomId=\(self.roomId)&empEmail=\(self.empEmail)&startDate=\(self.startDate)"
        let strUrlEncode = strUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
        let urlWs = NSURL(string: strUrlEncode!)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.roomList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) Room Size : \(self.roomList.count)")
                self.refeshTableView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        requestSent.resume()
    }
    
    //Refresh Table
    func refeshTableView(){
        dispatch_async(dispatch_get_main_queue(), {
            MRProgressOverlayView.dismissOverlayForView(self.roomView, animated: true)
            self.tableView.reloadData()
        })
    }
    
    //Count List of Table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return roomList.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("roomCell", forIndexPath: indexPath)
        let roomImg = cell.viewWithTag(21) as! UIImageView
        let roomSubjectLbl = cell.viewWithTag(22) as! UILabel
        let countLikeLbl = cell.viewWithTag(23) as! UILabel
        let dateTime = cell.viewWithTag(24) as! UILabel
        if(modelName.rangeOfString("ipad Mini") != nil){
            roomLbl.font = FontUtil.ipadminiTopicName
            roomSubjectLbl.font = FontUtil.ipadminiPainText
            countLikeLbl.font = FontUtil.ipadminiHotTopicNameAvatar
            dateTime.font = FontUtil.ipadminiDateTime
        }else{
            roomLbl.font = FontUtil.iphoneTopicName
            roomSubjectLbl.font = FontUtil.iphonepainText
            countLikeLbl.font = FontUtil.iphoneHotTopicNameAvatar
            dateTime.font = FontUtil.iphoneDateTime
        }
        let bean = roomList[indexPath.row]
      
        let statusRead: Bool!
        if (bean.valueForKey("statusRead") != nil){
            statusRead = bean.valueForKey("statusRead") as! Bool
        }else{
            statusRead = true
        }
        
        if (statusRead == false){
            cell.backgroundColor = ColorUtil.unreadTopicColor
        }else{
            cell.backgroundColor = ColorUtil.normalTopicColor
        }
        
//        print("\(NSDate().formattedISO8601) bean : \(bean)")
        roomSubjectLbl.text = bean.valueForKey("subject") as? String
        if(bean.valueForKey("countLike") != nil){
            countLikeLbl.text = String(bean.valueForKey("countLike") as! Int)
        }else{
            countLikeLbl.text = "0"
        }
        dateTime.text = bean.valueForKey("date") as? String
        let picAvatar = bean.valueForKey("avatarPic") as? String
        let avatarImageCheck = UIImage(named: picAvatar!)
        if(avatarImageCheck != nil){
             roomImg.image = UIImage(named: picAvatar!)
        }else{
            let picUrl = self.objectStorageUrl + picAvatar!
            let url = NSURL(string:picUrl)!
            roomImg.af_setImageWithURL(url)
        }
//        roomImg.image = UIImage(named: picAvatar!)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openBoardContent", sender: roomList[indexPath.row])
    }
    
    @IBAction func showNewTopicPage(sender: UIBarButtonItem) {
        self.performSegueWithIdentifier("openNewTopic", sender: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openBoardContent" {
            let destVC = segue.destinationViewController as! BoardcontentViewController
            destVC.receiveBoardContentList = sender as! NSDictionary // send room model by topicList (topic_id)
            destVC.receiveRoomList = self.receiveRoomList
            destVC.receiveFromPage = "RoomPage"
        }else if segue.identifier == "openNewTopic" {
            let destVC = segue.destinationViewController as! NewTopicViewController
            destVC.receiveNewTopic = self.receiveRoomList  //send room model (room_id)
        }
    }
    
    @IBAction func unwindToRoomVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToRoomVC")
    }
    
    func getValuefromRoomManageInfo(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqRoomManageInfo) as! [NSManagedObject]
            self.postUserCD = result[0].valueForKey("postUser") as! NSMutableDictionary
            self.commentUserCD = result[0].valueForKey("commentUser") as! NSMutableDictionary
            self.readUserCD = result[0].valueForKey("readUser") as! NSMutableDictionary
//            print("Post User From Core Data : \(self.postUserCD)")
//            print("Comment User From Core Data : \(self.commentUserCD)")
//            print("Read User From Core Data : \(self.readUserCD)")
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    func getValuefromUserInfo(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            self.empEmail = result[0].valueForKey("empEmail") as! String
            print("empEmail : \(self.empEmail)")
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    func getvaluefromApplicationCD(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqApplication) as! [NSManagedObject]
            
            self.startDate = result[0].valueForKey("startDate") as! String
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }

    
//    func checkPostBtn(roomId:String){
//        let postUserArray = self.postUserCD.valueForKey(roomId) as! Array<String>
//        if postUserArray.contains("all") {
//            print("Find All Post User")
//        }else if postUserArray.contains(self.empEmail) {
//            print("Find Post User")
//        }else{
//            print("not Find Post User")
////            postTopicBtn =  self.navigationItem.rightBarButtonItems![1]
////            self.navigationItem.rightBarButtonItems?.removeAtIndex(0)
//            self.navigationItem.rightBarButtonItems?.removeAtIndex(1)
//        }
//    }

}
