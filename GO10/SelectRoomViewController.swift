	//
//  SelectRoomViewController.swift
//  GO10
//
//  Created by Go10Application on 5/10/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData
import MRProgress

class SelectRoomViewController: UIViewController,UITableViewDataSource ,UITableViewDelegate,UICollectionViewDataSource,UICollectionViewDelegate {
    
    @IBOutlet var selectroomView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var hotTopicLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqRoomManageInfo = NSFetchRequest(entityName: "Room_Manage_Info")
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var fetchReqApplication = NSFetchRequest(entityName: "Application")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var contexroot = PropertyUtil.getPropertyFromPlist("data",key: "contexroot")
    
    var getHotToppicUrl:String!
    var getRoomUrl:String!
    var downloadObjectStorageUrl: String!
//    var objectStorageUrl = PropertyUtil.getPropertyFromPlist("data",key: "downloadObjectStorage")
    var topicList = [NSDictionary]()
    var roomList = [NSDictionary]()
    var modelName: String!
    var empEmail: String!
    var postUser: NSMutableDictionary = NSMutableDictionary()
    var commentUser: NSMutableDictionary = NSMutableDictionary()
    var readUser: NSMutableDictionary = NSMutableDictionary()
    var refreshControl = UIRefreshControl()
    var startDate: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        refreshControl.addTarget(self, action: #selector(SelectRoomViewController.refreshPage), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refreshPage(){
        getTopicWebService()
        refreshControl.endRefreshing()
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.getValuefromUserInfo()
        self.getvaluefromApplicationCD()
        self.getHotToppicUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/gethottopiclist?"
        self.getRoomUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)room/get?empEmail=\(self.empEmail)"
        self.downloadObjectStorageUrl = "\(self.domainUrl)\(contexroot)DownloadServlet?imageName="
        modelName = UIDevice.currentDevice().modelName
        print("*** SelectRoomVC ViewDidAppear ***")
        MRProgressOverlayView.showOverlayAddedTo(self.selectroomView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        getTopicWebService()
        getRoomsWebService()
    }
    
    func refreshTableView() {
        dispatch_async(dispatch_get_main_queue()) {
            MRProgressOverlayView.dismissOverlayForView(self.selectroomView, animated: true)
            self.tableView.reloadData()
        }
    }
    
    func refreshCollectionView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.collectionView.reloadData()
        })
    }
    
    func getTopicWebService(){
        print("\(NSDate().formattedISO8601) getTopicWebService")
        let strUrl = "\(self.getHotToppicUrl)empEmail=\(self.empEmail)&startDate=\(self.startDate)"
        let strUrlEncode = strUrl.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
        let urlWs = NSURL(string: strUrlEncode!)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.topicList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) Hot Topic Size : \(self.topicList.count)")
                self.refreshTableView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
                MRProgressOverlayView.dismissOverlayForView(self.selectroomView, animated: true)
            }
        }
        requestSent.resume()
    }
    
    func getRoomsWebService(){
        print("\(NSDate().formattedISO8601) getRoomsWebService")
        let urlWs = NSURL(string: self.getRoomUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            do{
                self.roomList = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                
                for index in 0...self.roomList.count-1{
                    self.postUser.setValue(self.roomList[index].valueForKey("postUser") as! Array<String>, forKey: self.roomList[index].valueForKey("_id") as! String)
                    self.commentUser.setValue(self.roomList[index].valueForKey("commentUser") as! Array<String>, forKey: self.roomList[index].valueForKey("_id") as! String)
                    self.readUser.setValue(self.roomList[index].valueForKey("readUser") as! Array<String>, forKey: self.roomList[index].valueForKey("_id") as! String)
                }
                print("xxxxxxxxxxxxxxxxxxxxxxxxx")
                print("postUser : \(self.postUser)")
                print("commentUser : \(self.commentUser)")
                print("readUser : \(self.readUser)")
                print("xxxxxxxxxxxxxxxxxxxxxxxxx")
                self.addObjToCoreData(self.postUser, key: "postUser")
                self.addObjToCoreData(self.commentUser, key: "commentUser")
                self.addObjToCoreData(self.readUser, key: "readUser")
                print("\(NSDate().formattedISO8601) Rooms Size \(self.roomList.count)")
                self.refreshCollectionView()
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        requestSent.resume()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicList.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("topicCell", forIndexPath: indexPath)
        let topicImg = cell.viewWithTag(11) as! UIImageView
        let topicSubjectLbl = cell.viewWithTag(12) as! UILabel
        let countLikeLbl = cell.viewWithTag(13) as! UILabel
        let dateTime = cell.viewWithTag(14) as! UILabel
        let bean = topicList[indexPath.row]
//        print("\(NSDate().formattedISO8601) bean : \(bean)")
        
        if(modelName.rangeOfString("ipad Mini") != nil){
            hotTopicLbl.font = FontUtil.ipadminiTopicName
            topicSubjectLbl.font = FontUtil.ipadminiPainText
            countLikeLbl.font = FontUtil.ipadminiHotTopicNameAvatar
            dateTime.font = FontUtil.ipadminiDateTime
        }else{
            topicSubjectLbl.font = FontUtil.iphoneTopicName
            topicSubjectLbl.font = FontUtil.iphonepainText
            countLikeLbl.font = FontUtil.iphoneHotTopicNameAvatar
            dateTime.font = FontUtil.iphoneDateTime
        }

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
        
        topicSubjectLbl.text =  bean.valueForKey("subject") as? String
        if(bean.valueForKey("countLike") != nil){
            countLikeLbl.text = String(bean.valueForKey("countLike") as! Int)
        }else{
            countLikeLbl.text = "0"
        }
        
        let roomID = bean.valueForKey("roomId") as! String
        
        if(RoomModelUtil.roomImageName.valueForKey(roomID) != nil){
            topicImg.image = RoomModelUtil.roomImageName.valueForKey(roomID) as? UIImage
        }
        else{
            let picUrl = self.downloadObjectStorageUrl + roomID + ".png"
            let url = NSURL(string:picUrl)!
            print("URL Pic :  \(url)")
            //roomImg.af_setImageWithURL(url)
            topicImg.af_setImageRoomWithURL(url)
        }

        dateTime.text = bean.valueForKey("date") as? String
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return roomList.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let collection = collectionView.dequeueReusableCellWithReuseIdentifier("roomCollectCell", forIndexPath: indexPath)
        let roomImg = collection.viewWithTag(14) as! UIImageView
        let roomTitle = collection.viewWithTag(15) as! UILabel
        let badgeNumberLbl = collection.viewWithTag(16) as! UILabel
        
        let beanRoom = roomList[indexPath.row]
//        print("\(NSDate().formattedISO8601) beanRoom : \(beanRoom)")
        if(modelName.rangeOfString("ipad Mini") != nil){
            roomLbl.font = FontUtil.ipadminiTopicName
            roomTitle.font = FontUtil.ipadminiPainText
        }else{
            roomLbl.font = FontUtil.iphoneTopicName
            roomTitle.font = FontUtil.iphonepainText
        }
        let roomID = beanRoom.valueForKey("_id") as? String
        let badgeNumber = beanRoom.valueForKey("badgeNumber") as? Int
        if(badgeNumber<1){
            badgeNumberLbl.hidden = true
        }else if(badgeNumber>99){
            badgeNumberLbl.hidden = false
            badgeNumberLbl.text = "99+"
        }else{
            badgeNumberLbl.hidden = false
            badgeNumberLbl.text = "\(badgeNumber!)"
        }
        
        if(RoomModelUtil.roomImageName.valueForKey(roomID!) != nil){
            roomImg.image = RoomModelUtil.roomImageName.valueForKey(roomID!) as? UIImage
            roomTitle.text = beanRoom.valueForKey("name") as? String
        }
        else{
            let picUrl = self.downloadObjectStorageUrl + roomID! + ".png"
            let url = NSURL(string:picUrl)!
            //roomImg.af_setImageWithURL(url)
            roomImg.af_setImageRoomWithURL(url)
            roomTitle.text = beanRoom.valueForKey("name") as? String
        }
        
//        for item in RoomModelUtil.roomImageName {
//            if(item.key as? String == roomID){
//                roomImg.image = item.value as? UIImage
//                roomTitle.text = beanRoom.valueForKey("name") as? String
//            }else{
//                let picUrl = self.objectStorageUrl + roomID! + ".png"
//                let url = NSURL(string:picUrl)!
////                print("URL Pic :  \(url)")
////                roomImg.af_setImageWithURL(url)
//                roomImg.af_setImageRoomWithURL(url)
//                roomTitle.text = beanRoom.valueForKey("name") as? String
//            }
//        }
        return collection
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.performSegueWithIdentifier("openBoardContent", sender: topicList[indexPath.row])
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("openRoom", sender:roomList[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openRoom" {
            let destVC = segue.destinationViewController as! RoomViewController
            destVC.receiveRoomList = sender as! NSDictionary
        }else if segue.identifier == "openBoardContent" {
            let destVC = segue.destinationViewController as! BoardcontentViewController
            destVC.receiveBoardContentList = sender as! NSDictionary
            destVC.receiveFromPage = "SelectRoomPage"
        }
    }
    
    func addObjToCoreData(val:AnyObject,key:String){
        do{
            let result = try context.executeFetchRequest(self.fetchReqRoomManageInfo)
            if(result.count > 0){
                print("set Old User")
                result[0].setValue(val, forKey: key)
            }else{
                print("set New User")
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("Room_Manage_Info", inManagedObjectContext: context)
                newUser.setValue(val, forKey: key)
            }
            try context.save()
            print("\(NSDate().formattedISO8601) Save Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data")
        }
    }
    
    func getValuefromUserInfo(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            
             self.empEmail = result[0].valueForKey("empEmail") as! String
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
    
    /*func clearCoreData(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        let context: NSManagedObjectContext = appDel.managedObjectContext
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info")
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject]
            
            if result.count >= 0 {
                for data in result {
                    context.deleteObject(data)
                    try context.save()
                }
            }
            print("\(NSDate().formattedISO8601) clear data success")
        }catch{
            print("\(NSDate().formattedISO8601) Error clear Data")
        }
        
    }*/
    
    @IBAction func unwindToSelectRoomVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToSelectRoomVC")
    }
    
}






