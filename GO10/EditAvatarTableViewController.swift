//
//  EditAvatarViewController.swift
//  GO10
//
//  Created by Go10Application on 5/18/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData
import MRProgress

class EditAvatarTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageButton: UIButton!
    @IBOutlet weak var avartarNameLbl: UILabel!
    @IBOutlet weak var editAvatarLbl: UILabel!
    @IBOutlet weak var cameraImg: UIImageView!
    @IBOutlet var editavatarTableView: UITableView!
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var getUserByTokenUrl: String!
    var updateUserUrl: String!
    var recieveformverify: String!
    var recieveStatusLogin: String!
    var backbtn: UIBarButtonItem!
    var submitBtn: UIBarButtonItem!
    var modelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserByTokenUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)user/getUserByToken?token="
        self.updateUserUrl = "\\(self.domainUrl)GO10WebService/api/\(self.versionServer)user/updateUser"
        modelName = UIDevice.currentDevice().modelName
        print("*** EditAvatarTableVC ViewDidLoad")
        if(modelName.rangeOfString("ipad Mini") != nil){
            avartarNameLbl.font = FontUtil.ipadminiPainText
            editAvatarLbl.font = FontUtil.ipadminiHotTopicNameAvatar
        }else{
            avartarNameLbl.font = FontUtil.iphonepainText
            editAvatarLbl.font = FontUtil.iphoneHotTopicNameAvatar
        }
        if(recieveStatusLogin == nil){
            recieveStatusLogin = "not First Login"
        }
            if(recieveStatusLogin == "First Login" && recieveStatusLogin != nil){
                print("First Login")
                    do{
                        let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
                        result[0].setValue(false, forKey: "statusLogin")
                        try self.context.save()
                        }catch{
                            print("\(NSDate().formattedISO8601) Error Reading Data")
                        }
                self.navigationItem.setHidesBackButton(true, animated:true)
            }else{
                print("not First Login")
                submitBtn =  self.navigationItem.rightBarButtonItems![0]
                self.navigationItem.rightBarButtonItems?.removeAtIndex(0)
            }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** EditAvatarTableVC ViewDidAppear ***")
        MRProgressOverlayView.showOverlayAddedTo(self.editavatarTableView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String
            let userNameAvatar = result[0].valueForKey("avatarName") as! String
            print("\(NSDate().formattedISO8601) Data_Info :\(result)")
            let avatarImage = UIImage(named: userPicAvatar)
            if(avatarImage != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(userPicAvatar)")
                avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                avatarImageButton.setImage(avatarImage, forState: .Normal)
                cameraImg.image = UIImage(named: "camera")
            }
            editAvatarLbl.text = userNameAvatar
            MRProgressOverlayView.dismissOverlayForView(self.editavatarTableView, animated: true)
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }

    @IBAction func submitAvatar(sender: AnyObject) {
        print("SUBMIT AVATAR")
        if(recieveStatusLogin == "First Login" && recieveStatusLogin != nil){
            print("First Login")
            do{
                let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
                result[0].setValue(false, forKey: "statusLogin")
                try self.context.save()
            }catch{
                print("\(NSDate().formattedISO8601) Error Reading Data")
            }
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String
            let userNameAvatar = result[0].valueForKey("avatarName") as! String
            if(userNameAvatar=="Avatar Name" || userPicAvatar == "default_avatar"){
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let alert = UIAlertController(title: "Alert", message: "Please Set Your Avatar Picture and Avatar Name.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                updateData()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("gotoHomePage", sender:nil)
                }
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    func updateData(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let _id = result[0].valueForKey("id_") as! String
            let _rev = result[0].valueForKey("rev_") as! String
            let empName = result[0].valueForKey("empName") as! String
            let empEmail = result[0].valueForKey("empEmail") as! String
            let avatarName = result[0].valueForKey("avatarName") as! String
            let avatarPic = result[0].valueForKey("avatarPic") as! String
            let activate = result[0].valueForKey("activate") as! Bool
            let type = result[0].valueForKey("type") as! String
            let birthday = result[0].valueForKey("birthday") as! String
            result[0].setValue(true, forKey: "activate")
            print("\(NSDate().formattedISO8601) putUpdateWebservice")
            let urlWs = NSURL(string: self.updateUserUrl )
            print("\(NSDate().formattedISO8601) URL : \(urlWs)")
            let requestPost = NSMutableURLRequest(URL: urlWs!)
            let jsonObj = "{\"_id\":\"\(_id)\",\"_rev\":\"\(_rev)\",\"empName\":\"\(empName)\",\"empEmail\":\"\(empEmail)\",\"avatarName\":\"\(avatarName)\",\"avatarPic\":\"\(avatarPic)\",\"birthday\":\"\(birthday)\",\"activate\":\"\(activate)\",\"type\":\"\(type)\"}"
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
                result[0].setValue(responseString, forKey: "rev_")
            }
            request.resume()
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading and Saving Data")
        }
    }
    
    @IBAction func unwindToEditAvatar(segue: UIStoryboardSegue) {
        print("\(NSDate().formattedISO8601) unwindToEditAvatar")
    }
    
}
