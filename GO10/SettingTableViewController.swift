//
//  SettingTableViewController.swift
//  GO10
//
//  Created by Go10Application on 5/19/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData
import OneSignal

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImageButton: UIButton!
//    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarNameLbl: UILabel!
    @IBOutlet weak var logoutLbl: UILabel!
    @IBOutlet weak var editAvatarLbl: UILabel!
    
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqRoomManageInfo = NSFetchRequest(entityName: "Room_Manage_Info")
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var modelName: String!
    var objectStorageUrl = PropertyUtil.getPropertyFromPlist("data",key: "downloadObjectStorage")
    
    override func viewDidLoad() {
        super.viewDidLoad()
         modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            logoutLbl.font = FontUtil.ipadminiPainText
            editAvatarLbl.font = FontUtil.ipadminiPainText
            avatarNameLbl.font = FontUtil.ipadminiPainText
        }else{
            logoutLbl.font = FontUtil.iphonepainText
            editAvatarLbl.font = FontUtil.iphonepainText
            avatarNameLbl.font = FontUtil.iphonepainText
        }
        let singleTap = UITapGestureRecognizer(target: self, action:#selector(SettingTableViewController.tapDetected))
        singleTap.numberOfTapsRequired = 1
        avatarImageButton.userInteractionEnabled = true
        avatarImageButton.addGestureRecognizer(singleTap)
    }
    
    func tapDetected() {
        print("Single Tap on imageview gotoEditAvatarTable")
        self.performSegueWithIdentifier("gotoEditAvatar", sender:nil)
//        self.performSegueWithIdentifier("gotoSelectAvatar", sender:nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** SettingVC ViewDidAppear ***")
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String
            let userNameAvatar = result[0].valueForKey("avatarName") as! String
            
            let avatarImageCheck = UIImage(named: userPicAvatar)
            
            if(avatarImageCheck != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(userPicAvatar)")
//                self.avatarImage.image = UIImage(named: userPicAvatar)
                self.avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                self.avatarImageButton.setImage(avatarImageCheck, forState: .Normal)
            }else{
                print("\(NSDate().formattedISO8601) avatarImage : \(userPicAvatar)")
                let picUrl = self.objectStorageUrl + userPicAvatar
                let url = NSURL(string:picUrl)!
//                self.avatarImage.af_setImageWithURL(url)
                self.avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                self.avatarImageButton.af_setImageForState(.Normal, URL: url)
            }
            
            if(avatarNameLbl != nil){
                avatarNameLbl.text = userNameAvatar
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }

    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index Path : \(indexPath.row)")
            if indexPath.row == 2{
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginVC =  storyboard.instantiateViewControllerWithIdentifier("mainVCID")
//            self.presentViewController(loginVC, animated: true, completion: nil)
            OneSignal.setSubscription(false)
            logout()
        }
    }
    
    func logout(){
        do{
            let result = try context.executeFetchRequest(self.fetchReqUserInfo)
            result[0].setValue(false, forKey: "statusLogin")
            try context.save()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC =  storyboard.instantiateViewControllerWithIdentifier("mainVCID")
            self.presentViewController(loginVC, animated: true, completion: nil)
            print("\(NSDate().formattedISO8601) Save Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data")
        }
    }
    
    @IBAction func unwindToSetting(segue: UIStoryboardSegue) {
        print("\(NSDate().formattedISO8601) unwindToSetting")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoEditAvatar" {
            segue.destinationViewController as! EditAvatarTableViewController
        }
        
    }
}
