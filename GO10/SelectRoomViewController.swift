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
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
//    var pathTopicService = PropertyUtil.getPropertyFromPlist("data",key: "pathTopicService")
//    var pathRoomService = PropertyUtil.getPropertyFromPlist("data",key: "pathRoomService")
//    var pathTopicServiceV2 = PropertyUtil.getPropertyFromPlist("data",key: "pathTopicServiceV2")
//    var pathRoomServiceV1 = PropertyUtil.getPropertyFromPlist("data",key: "pathRoomServiceV1")
    
    var getHotToppicUrl:String!
    var getRoomUrl:String!
    var topicList = [NSDictionary]();
    var roomList = [NSDictionary]();
    var modelName: String!
    var empEmail: String!
    var postUser: NSMutableDictionary = NSMutableDictionary()
    var commentUser: NSMutableDictionary = NSMutableDictionary()
    var readUser: NSMutableDictionary = NSMutableDictionary()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
 
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        getValuefromUserInfo()
        self.getHotToppicUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/gethottopiclist?empEmail=\(self.empEmail)"
        self.getRoomUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)room/get?empEmail=\(self.empEmail)"
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
        print("\(NSDate().formattedISO8601) getTopicWebService");
        let urlWs = NSURL(string: getHotToppicUrl)
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
        let topicImg = cell.viewWithTag(11) as! UIImageView;
        let topicSubjectLbl = cell.viewWithTag(12) as! UILabel;
//        let topicUserAvatarNameLbl = cell.viewWithTag(13) as! UILabel;
        let countLikeLbl = cell.viewWithTag(13) as! UILabel;
        let dateTime = cell.viewWithTag(14) as! UILabel;
        let bean = topicList[indexPath.row]
//        print("\(NSDate().formattedISO8601) bean : \(bean)")
        
        if(modelName.rangeOfString("ipad Mini") != nil){
            hotTopicLbl.font = FontUtil.ipadminiTopicName
            topicSubjectLbl.font = FontUtil.ipadminiPainText
//            topicUserAvatarNameLbl.font = FontUtil.ipadminiHotTopicNameAvatar
            countLikeLbl.font = FontUtil.ipadminiHotTopicNameAvatar
            dateTime.font = FontUtil.ipadminiDateTime
        }else{
            topicSubjectLbl.font = FontUtil.iphoneTopicName
            topicSubjectLbl.font = FontUtil.iphonepainText
            countLikeLbl.font = FontUtil.iphoneHotTopicNameAvatar
            dateTime.font = FontUtil.iphoneDateTime
        }
        topicSubjectLbl.text =  bean.valueForKey("subject") as? String
//        topicUserAvatarNameLbl.text =  bean.valueForKey("avatarName") as? String
        countLikeLbl.text = String(bean.valueForKey("countLike") as! Int)
        let roomID = bean.valueForKey("roomId") as! String
        for item in RoomModelUtil.room { // loop through data items
            if(item.key as? String == roomID){
            topicImg.image = item.value as? UIImage
            }
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
        for item in RoomModelUtil.room { // loop through data items
            if(item.key as? String == roomID){
                roomImg.image = item.value as? UIImage
                roomTitle.text = beanRoom.valueForKey("name") as? String
            }
        }
        return collection
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        self.performSegueWithIdentifier("openBoardContent", sender: topicList[indexPath.row])
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {        self.performSegueWithIdentifier("openRoom", sender:roomList[indexPath.row])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "openRoom" {
            let destVC = segue.destinationViewController as! RoomViewController
            destVC.receiveRoomList = sender as! NSDictionary
        }else if segue.identifier == "openBoardContent" {
            let destVC = segue.destinationViewController as! BoardcontentViewController
            destVC.receiveBoardContentList = sender as! NSDictionary
        }
    }
    
    func addObjToCoreData(val:AnyObject,key:String){
        let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "Room_Manage_Info");
            let result = try context.executeFetchRequest(fetchReq);
            if(result.count > 0){
                print("set Old User")
                result[0].setValue(val, forKey: key)
            }else{
                print("set New User")
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("Room_Manage_Info", inManagedObjectContext: context);
                newUser.setValue(val, forKey: key)
            }
            try context.save();
            print("\(NSDate().formattedISO8601) Save Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data");
        }
    }
    
    func getValuefromUserInfo(){
        let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
             self.empEmail = result[0].valueForKey("empEmail") as! String;
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
    }
    
    /*
    func getValuefromRoomManageInfo(){
        let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "Room_Manage_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let postUserCD = result[0].valueForKey("postUser") as! NSMutableDictionary
            let commentUserCD = result[0].valueForKey("commentUser") as! NSMutableDictionary
            print("Post User From Core Data : \(postUserCD)");
            print("Comment User From Core Data : \(commentUserCD)");
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
    }*/
    
    
    /*func clearCoreData(){
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context: NSManagedObjectContext = appDel.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            if result.count >= 0 {
                for data in result {
                    context.deleteObject(data)
                    try context.save()
                }
            }
            print("\(NSDate().formattedISO8601) clear data success")
        }catch{
            print("\(NSDate().formattedISO8601) Error clear Data");
        }
        
    }*/
    
    @IBAction func unwindToSelectRoomVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToSelectRoomVC")
    }
    
}






