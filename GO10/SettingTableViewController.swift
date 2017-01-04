//
//  SettingTableViewController.swift
//  GO10
//
//  Created by Go10Application on 5/19/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData

class SettingTableViewController: UITableViewController {
    
    @IBOutlet weak var avatarImage: UIImageView!
    @IBOutlet weak var avatarNameLbl: UILabel!
    @IBOutlet weak var logoutLbl: UILabel!
    @IBOutlet weak var editAvatarLbl: UILabel!
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var modelName: String!
    
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
        avatarImage.userInteractionEnabled = true
        avatarImage.addGestureRecognizer(singleTap)
    }
    
    func tapDetected() {
        print("Single Tap on imageview gotoSelectAvatar")
        self.performSegueWithIdentifier("gotoSelectAvatar", sender:nil)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** SettingVC ViewDidAppear ***")
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String;
            let userNameAvatar = result[0].valueForKey("avatarName") as! String;
            if(avatarImage != nil){
                print("\(NSDate().formattedISO8601) avatarPicImage : \(userPicAvatar)")
                avatarImage.image = UIImage(named: userPicAvatar)
            }
            if(avatarNameLbl != nil){
                avatarNameLbl.text = userNameAvatar
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        print("index Path : \(indexPath.row)")
            if indexPath.row == 2{
//            if (FBSDKAccessToken.currentAccessToken() != nil){
//                print("\(NSDate().formattedISO8601) Facebook is logon")
//                FBSDKLoginManager().logOut()
//            } else if(GIDSignIn.sharedInstance().hasAuthInKeychain()){
//                print("\(NSDate().formattedISO8601) Google is logon")
//                GIDSignIn.sharedInstance().signOut()
//            }
//            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//            let loginVC =  storyboard.instantiateViewControllerWithIdentifier("mainVCID")
//            self.presentViewController(loginVC, animated: true, completion: nil)
            logout()
        }
    }
    
    func logout(){
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq);
            result[0].setValue(false, forKey: "statusLogin");
            try context.save();
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC =  storyboard.instantiateViewControllerWithIdentifier("mainVCID")
            self.presentViewController(loginVC, animated: true, completion: nil)
            print("\(NSDate().formattedISO8601) Save Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data");
        }
    }
    
    @IBAction func unwindToSetting(segue: UIStoryboardSegue) {
        print("\(NSDate().formattedISO8601) unwindToSetting")
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoSelectAvatar" {
            let destVC = segue.destinationViewController as! SelectAvatarViewController
            destVC.recieveFromPage = "SettingAvatar"
            
        }
    }
}
