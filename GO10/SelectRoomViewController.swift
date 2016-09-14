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
    
    var getHotToppicUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/topic/gethottopiclist"
    var getRoomUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/room/get"
    var topicList = [NSDictionary]();
    var roomList = [NSDictionary]();
    var modelName: String!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        modelName = UIDevice.currentDevice().modelName
        print("*** SelectRoomVC ViewDidAppear ***")
        MRProgressOverlayView.showOverlayAddedTo(self.selectroomView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        getTopicWebService()
        getRoomsWebService()
        //readData()
        //clearCoreData()
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
        let topicUserAvatarNameLbl = cell.viewWithTag(13) as! UILabel;
        let dateTime = cell.viewWithTag(14) as! UILabel;
        let bean = topicList[indexPath.row]
        print("\(NSDate().formattedISO8601) bean : \(bean)")
        if(modelName.rangeOfString("ipad Mini") != nil){
            hotTopicLbl.font = FontModel.ipadminiTopicName
            topicSubjectLbl.font = FontModel.ipadminiPainText
            topicUserAvatarNameLbl.font = FontModel.ipadminiHotTopicNameAvatar
            dateTime.font = FontModel.ipadminiDateTime
        }
        
        topicSubjectLbl.text =  bean.valueForKey("subject") as? String
        topicUserAvatarNameLbl.text =  bean.valueForKey("avatarName") as? String
        let roomID = bean.valueForKey("roomId") as? String
        for item in RoomModel.room { // loop through data items
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
        print("\(NSDate().formattedISO8601) beanRoom : \(beanRoom)")
        if(modelName.rangeOfString("ipad Mini") != nil){
            roomLbl.font = FontModel.ipadminiTopicName
            roomTitle.font = FontModel.ipadminiPainText
        }
        
        let roomID = beanRoom.valueForKey("_id") as? String
        
        for item in RoomModel.room { // loop through data items
            if(item.key as? String == roomID){
                roomImg.image = item.value as? UIImage
                roomTitle.text = beanRoom.valueForKey("name") as? String
            }
        }
        return collection
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {        self.performSegueWithIdentifier("openBoardContent", sender: topicList[indexPath.row])
        
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
    
    func readData(){
        print("\(NSDate().formattedISO8601) Reading Data ..")
        
        let appDel: AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate;
        let context: NSManagedObjectContext = appDel.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let userId = result[0].valueForKey("accountId") as! String;
            let userName = result[0].valueForKey("empName") as! String;
            let userEmail = result[0].valueForKey("empEmail") as! String;
            print("\(NSDate().formattedISO8601) USER_ID: \(userId), USER_NAME: \(userName), E-MAIL: \(userEmail)");
            
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
    }
    
    func clearCoreData(){
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
        
    }
    
    
}






