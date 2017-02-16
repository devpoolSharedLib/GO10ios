//
//  LoginViewController.swift
//  GO10
//
//  Created by Go10Application on 7/25/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData
import MRProgress
import OneSignal

class LoginViewController: UIViewController {
    
//    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var fetchReqApplication = NSFetchRequest(entityName: "Application")
    var domainUrlHttps = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttps")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var getUserByUserPasswordUrl: String!
    var checkRoomNotificationModel: String!
    var profile = [NSDictionary]()
    var modelName: String!
    var startDate: String!
    var appId = PropertyUtil.getPropertyFromPlist("data",key: "appID")
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var passwordLbl: UILabel!
    @IBOutlet weak var passwordTxtField: UITextField!
    @IBOutlet var loginView: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var forgotPasswordBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserByUserPasswordUrl = "\(self.domainUrlHttps)GO10WebService/api/\(self.versionServer)user/getUserByUserPassword?"
        self.checkRoomNotificationModel = "\(self.domainUrlHttps)GO10WebService/api/\(self.versionServer)user/checkRoomNotificationModel?"
        print("*** LoginVC ViewDidLoad ***")
        modelName = UIDevice.currentDevice().modelName
        self.loginBtn.layer.cornerRadius = 5
        if(modelName.rangeOfString("ipad Mini") != nil){
            emailLbl.font = FontUtil.ipadminiPainText
            passwordLbl.font = FontUtil.ipadminiPainText
            loginBtn.titleLabel?.font = FontUtil.ipadminiPainText
            forgotPasswordBtn.titleLabel?.font = FontUtil.ipadminiPainText
        }else{
            emailLbl.font = FontUtil.iphonepainText
            passwordLbl.font = FontUtil.iphonepainText
            loginBtn.titleLabel?.font = FontUtil.iphonepainText
            forgotPasswordBtn.titleLabel?.font = FontUtil.iphonepainText
        }
    }
    
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        if UIDevice.currentDevice().orientation.isLandscape.boolValue{
            print("Change to Landscape")
        }else{
            print("Change to Portrait")
        }
    }
    
    @IBAction func gotoForgotPage(sender: AnyObject) {
        self.performSegueWithIdentifier("gotoForgotPage", sender: nil)
    }
    
    @IBAction func gotoTermConditon(sender: AnyObject) {
        self.performSegueWithIdentifier("gotoTerm_Cond", sender: nil)
    }
    
    @IBAction func gotoSelectRoomPage(sender: AnyObject) {
        let email = self.emailTxtField.text
        let password = self.passwordTxtField.text
        
        if((email == "") || checkSpace(email!) || password == "" || checkSpace(password!) ) {
            let alert = UIAlertController(title: "Alert", message: "Please enter your E-mail and Password.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            MRProgressOverlayView.showOverlayAddedTo(self.loginView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            checkLogin(email!,password: password!)
        }
    }
    
    func checkLogin(empEmail:String,password:String){
        print("\(NSDate().formattedISO8601) getLoginWebservice")
        let url = "\(self.getUserByUserPasswordUrl)email=\(empEmail)&password=\(password)"
        print("url : \(url)")
        let strUrlEncode = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
        let urlWs = NSURL(string: strUrlEncode!)
        let req = NSMutableURLRequest(URL: urlWs!)
        req.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let request = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, response, error) in
            do{
                self.profile = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) profile : \(self.profile)")
                if(self.profile.isEmpty){
                    print("Profile is Empty")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Alert", message: "The e-mail or password is incorrect.\n\nPlease try again.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        MRProgressOverlayView.dismissOverlayForView(self.loginView, animated: true)
                    }
                }else{
                    if(self.profile[0].valueForKey("activate") as! Bool == false){
                        print("activate is false")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let alert = UIAlertController(title: "Alert", message: "The e-mail or password is incorrect.\n\nPlease try again.", preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                            MRProgressOverlayView.dismissOverlayForView(self.loginView, animated: true)
                        }
                    }
                    else if(self.profile[0].valueForKey("avatarPic") as! String == "default_avatar" && self.profile[0].valueForKey("avatarName") as! String == "Avatar Name"){
                        print("\(NSDate().formattedISO8601) Default Avatar")
                        self.setUserInfoToCoredata()
                        MRProgressOverlayView.dismissOverlayForView(self.loginView, animated: true)
                        self.gotoSetAvatar()
                    }else{
                        MRProgressOverlayView.dismissOverlayForView(self.loginView, animated: true)
                        print(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> \(empEmail)")
                        self.callRoomNotification(empEmail)
                        self.setUserInfoToCoredata()
                        self.registerNotification(empEmail)
                        self.loginToHomepage()
                    }
                }
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        request.resume()
    }
    
    func callRoomNotification(empEmail:String){
        print("\(NSDate().formattedISO8601) callRoomNotification")
        let urlWs = NSURL(string: "\(self.checkRoomNotificationModel)empEmail=\(empEmail)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil && data != nil else {
                print("\(NSDate().formattedISO8601) error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
            self.startDate = responseString as! String
            self.setStartDateToCoreDate()
        }
        requestSent.resume()
    }
    
    func registerNotification(empEmail: String){
//        // get a reference to the app delegate
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        
//        // call didFinishLaunchWithOptions ... why?
//        appDelegate.application(UIApplication.sharedApplication(), didFinishLaunchingWithOptions: nil)
//     
        OneSignal.setSubscription(true)
       OneSignal.registerForPushNotifications()
    }
    
    func gotoSetAvatar(){
        let statusLogin = "First Login"
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("gotoSettingAvatar", sender: statusLogin)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "gotoSettingAvatar" {
            let navController = segue.destinationViewController as! UINavigationController
            let destVC = navController.topViewController as! EditAvatarTableViewController
            destVC.recieveStatusLogin = sender as! String
        }
    }
    
    func loginToHomepage(){
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("LoginToHomepage", sender: nil)
        }
    }
    
    // Write Data into CoreData
    func setStartDateToCoreDate(){
        print("setStartDateToCoreDate")
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqApplication)
            if(result.count > 0){
                print("set Old User")
                result[0].setValue(self.startDate, forKey: "startDate")
            }else{
                print("set New User")
                print("startDate >>>> \(self.startDate)")
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("Application", inManagedObjectContext: context)
                newUser.setValue(self.startDate, forKey: "startDate")
            }
            try self.context.save()
            print("\(NSDate().formattedISO8601) Save StartDate Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data")
        }
    }
    
    // Write Data into CoreData
    func setUserInfoToCoredata(){
        print("setUserInfoToCoredata")
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
            if(result.count > 0){
                print("set Old User")
                result[0].setValue(self.profile[0].valueForKey("_id"), forKey: "id_")
                result[0].setValue(self.profile[0].valueForKey("_rev"), forKey: "rev_")
                result[0].setValue("xxxxxxxxxx", forKey: "accountId")
                result[0].setValue(self.profile[0].valueForKey("activate"), forKey: "activate")
                result[0].setValue(self.profile[0].valueForKey("empName") , forKey: "empName")
                result[0].setValue(self.profile[0].valueForKey("empEmail"), forKey: "empEmail")
                result[0].setValue(self.profile[0].valueForKey("avatarPic"), forKey: "avatarPic")
                result[0].setValue("default_avatar", forKey: "avatarPicTemp")
                result[0].setValue(self.profile[0].valueForKey("avatarName"), forKey: "avatarName")
                result[0].setValue(true, forKey: "avatarCheckSelect")
                result[0].setValue(self.profile[0].valueForKey("birthday"), forKey: "birthday")
                result[0].setValue(self.profile[0].valueForKey("type"), forKey: "type")
                result[0].setValue(true, forKey: "statusLogin")
            }else{
                print("set New User")
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("User_Info", inManagedObjectContext: context)
                newUser.setValue(self.profile[0].valueForKey("_id"), forKey: "id_")
                newUser.setValue(self.profile[0].valueForKey("_rev"), forKey: "rev_")
                newUser.setValue("xxxxxxxxxx", forKey: "accountId")
                newUser.setValue(self.profile[0].valueForKey("activate"), forKey: "activate")
                newUser.setValue(self.profile[0].valueForKey("empName") , forKey: "empName")
                newUser.setValue(self.profile[0].valueForKey("empEmail"), forKey: "empEmail")
                newUser.setValue(self.profile[0].valueForKey("avatarPic"), forKey: "avatarPic")
                newUser.setValue("default_avatar", forKey: "avatarPicTemp")
                newUser.setValue(self.profile[0].valueForKey("avatarName"), forKey: "avatarName")
                newUser.setValue(true, forKey: "avatarCheckSelect")
                newUser.setValue(self.profile[0].valueForKey("birthday"), forKey: "birthday")
                newUser.setValue(self.profile[0].valueForKey("type"), forKey: "type")
                newUser.setValue(true, forKey: "statusLogin")
            }
            try self.context.save()
            print("\(NSDate().formattedISO8601) Save User_Info Data Success")
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data")
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkSpace(strCheck: String) -> Bool {
        let trimmedString = strCheck.stringByTrimmingCharactersInSet(
            NSCharacterSet.whitespaceAndNewlineCharacterSet()
        )
        if trimmedString.characters.count == 0 {
            return true
        }else{
            return false
        }
    }
}
