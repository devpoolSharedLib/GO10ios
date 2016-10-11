//
//  RoomViewController.swift
//  GO10
//
//  Created by Go10Application on 10/5/2559 .
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import MRProgress

class RoomViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet var roomView: UIView!
    @IBOutlet weak var roomLbl: UILabel!
    @IBOutlet weak var lblRoom: UILabel!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var pathTopicService = PropertyUtil.getPropertyFromPlist("data",key: "pathTopicService")
    
    var getRoomByIdUrl: String!
    
    var roomList = [NSDictionary]();
    var roomId: String!
    var roomName: String!
    var receiveRoomList: NSDictionary!
    var modelName: String!
    
        override func viewDidLoad() {
            super.viewDidLoad()
            print("*** RoomVC viewDidLoad ***")
            
            self.getRoomByIdUrl = "\(self.domainUrl)\(self.pathTopicService)/gettopiclistbyroom?roomId="
            roomId = receiveRoomList.valueForKey("_id") as! String
            roomName = receiveRoomList.valueForKey("name") as! String
            lblRoom.text = roomName;
            
            for item in RoomModel.room { // loop through data items
                if(item.key as? String == roomId){
                    self.imgView.image = item.value as? UIImage
                }
            }
        }
    
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** RoomVC viewDidAppear ***")
        
        
        
        modelName = UIDevice.currentDevice().modelName
        print("\(NSDate().formattedISO8601) room id : \(roomId)")
        MRProgressOverlayView.showOverlayAddedTo(self.roomView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        getRoomByIdWebService(roomId)
    }

    
    func getRoomByIdWebService(roomId: String) {
        print("\(NSDate().formattedISO8601) getRoomByIdWebService")
        let urlWs = NSURL(string: self.getRoomByIdUrl + roomId)
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
        let roomImg = cell.viewWithTag(21) as! UIImageView;
        let roomSubjectLbl = cell.viewWithTag(22) as! UILabel;
//        let roomUserAvatarNameLbl = cell.viewWithTag(23) as! UILabel;
        let countLikeLbl = cell.viewWithTag(23) as! UILabel;
        let dateTime = cell.viewWithTag(24) as! UILabel;
        if(modelName.rangeOfString("ipad Mini") != nil){
            
            roomLbl.font = FontModel.ipadminiTopicName
            roomSubjectLbl.font = FontModel.ipadminiPainText
//            roomUserAvatarNameLbl.font = FontModel.ipadminiHotTopicNameAvatar
            countLikeLbl.font = FontModel.ipadminiHotTopicNameAvatar
            dateTime.font = FontModel.ipadminiDateTime
        }else{
            roomLbl.font = FontModel.iphoneTopicName
            roomSubjectLbl.font = FontModel.iphonepainText
            countLikeLbl.font = FontModel.iphoneHotTopicNameAvatar
            dateTime.font = FontModel.iphoneDateTime
        }
        
        let bean = roomList[indexPath.row]
        print("\(NSDate().formattedISO8601) bean : \(bean)")
        roomSubjectLbl.text = bean.valueForKey("subject") as? String
//        roomUserAvatarNameLbl.text = bean.valueForKey("avatarName") as? String
        countLikeLbl.text = String(bean.valueForKey("countLike") as! Int)
        dateTime.text = bean.valueForKey("date") as? String

        let picAvatar = bean.valueForKey("avatarPic") as? String
        roomImg.image = UIImage(named: picAvatar!)
//        let randnumbers =  arc4random_uniform(9)+1
//        roomImg.image = UIImage(named: "girl0\(randnumbers)")
        
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
            
        }else if segue.identifier == "openNewTopic" {
            let destVC = segue.destinationViewController as! NewTopicViewController
            destVC.receiveNewTopic = self.receiveRoomList  //send room model (room_id)
        }
    }
    
    @IBAction func unwindToRoomVC(segue: UIStoryboardSegue){
        print("\(NSDate().formattedISO8601) unwindToRoomVC")
    }
}
