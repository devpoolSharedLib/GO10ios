//
//  GoogleLoginViewController.swift
//  DemoFBLogin
//
//  Created by devpool on 5/11/2559 BE.
//  Copyright © 2559 devpool. All rights reserved.
//

import UIKit
import CoreData

class LoginFBViewController: UIViewController, GIDSignInUIDelegate ,GIDSignInDelegate{
    
    @IBOutlet weak var btnLoginFacebook: UIButton!
    @IBOutlet weak var btnSigninGoogle: UIButton!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var modelName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** LoginVC ViewDidLoad ***")
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            btnLoginFacebook.titleLabel?.font = FontUtil.ipadminiTopicName
            btnSigninGoogle.titleLabel?.font = FontUtil.ipadminiTopicName
        }
    }

    //Login Facebook Button
    @IBAction func btnFBLoginPressed(sender: AnyObject) {
        appDelegate.signInType = "Facebook"
        let fbLoginManager : FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager .logInWithReadPermissions(["public_profile", "email"], fromViewController: self, handler: { (result, error) -> Void in
            if (error == nil){
                self.getFBUserData()
            }
            print("CALL BACK FB")
        })
    }
    
    //Signin Google Button
    @IBAction func btnSigninGooglePressed(sender: AnyObject) {
        appDelegate.signInType = "Google"
        GIDSignIn.sharedInstance().signIn()
    }
    
    //get Facebook User Data
    func getFBUserData()
    {
         print("FB GET DATA")
        let graphRequest : FBSDKGraphRequest = FBSDKGraphRequest(graphPath: "me", parameters: ["fields":"id, name, email, gender, birthday, location"])
        graphRequest.startWithCompletionHandler({ (connection, result, error) -> Void in
            
            if ((error) != nil)
            {
                print("Error: \(error)")
            }
            else
            {
                let accountId = result.valueForKey("id") as! String
                print("\(NSDate().formattedISO8601) FB User id is: \(accountId)")
                self.saveUserInfo(accountId)
            }
        })
    }

    //Google Signin Handle
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
                withError error: NSError!) {
        if (error == nil) {
            let userId = user.userID
            print("\(NSDate().formattedISO8601) Google User id is: \(userId)")
            NSNotificationCenter.defaultCenter().postNotificationName(
                "ToggleAuthUINotification",
                object: nil,
                userInfo: ["statusText": "Signed in user:\n\(userId)"])
                self.saveUserInfo(userId)
            // self.performSegueWithIdentifier("gotoHomePage", sender: nil)
        } else {
            print("\(NSDate().formattedISO8601) : \(error.localizedDescription)")
            NSNotificationCenter.defaultCenter().postNotificationName(
                "ToggleAuthUINotification", object: nil, userInfo: nil)
        }
    }
    
    //Google Signin Disconnect
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
                withError error: NSError!) {
        NSNotificationCenter.defaultCenter().postNotificationName(
            "ToggleAuthUINotification",
            object: nil,
            userInfo: ["statusText": "User has disconnected."])
    }
    
    func saveUserInfo(accountId: String){
        // Write Data into CoreData
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("User_Info", inManagedObjectContext: context);
                newUser.setValue(accountId, forKey: "accountId");
                newUser.setValue("Name" , forKey: "empName");
                newUser.setValue("email@gosoft.co.th", forKey: "empEmail");
                newUser.setValue("default_avatar", forKey: "avatarPic");
                newUser.setValue("default_avatar", forKey: "avatarPicTemp");
                newUser.setValue("avatar", forKey: "avatarName")
                newUser.setValue(true, forKey: "avatarCheckSelect")
                newUser.setValue(false, forKey: "activate")
                newUser.setValue("", forKey: "token")
                newUser.setValue("user", forKey: "type")
                newUser.setValue("_id", forKey: "id_")
                newUser.setValue("_rev", forKey: "rev_")
            try context.save();
            print("\(NSDate().formattedISO8601) Save Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data");
        }
        
    }
    
}
