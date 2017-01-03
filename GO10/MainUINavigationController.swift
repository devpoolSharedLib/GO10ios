//
//  MainUINavigationController.swift
//  GO10
//
//  Created by Go10Application on 5/19/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData

class MainUINavigationController: UINavigationController {
    
    
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var pathUserService = PropertyUtil.getPropertyFromPlist("data",key: "pathUserService")
    var getUserByAccountIdUrl: String!
    var profile = [NSDictionary]();
    var status: Bool!
    var accountId: String!
    var statusLogin: Bool!
    var empEmail: String!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** MainVC ViewDidAppear ***")
        self.getUserByAccountIdUrl = "\(self.domainUrl)\(self.pathUserService)/checkUserActivation?empEmail="
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            

//            print("Results : \(result)")
            print("count Results : \(result.count)")
            if(result.count == 0){
                print("count=0")
                self.statusLogin = false;
            }else if((result[0].valueForKey("statusLogin")) as! Bool == false){
                print("status=false")
                self.statusLogin = false
            }else{
                print("true")
                for results in result as [NSManagedObject] {
                    
                    print("\(NSDate().formattedISO8601) results : \(results)")
                }
                self.statusLogin = true
            }
            
            print("Status Login : \(self.statusLogin)")
            
            if((self.statusLogin) == true){
                self.empEmail = result[0].valueForKey("empEmail") as! String
                checkStatus(self.empEmail)
//                self.performSegueWithIdentifier("gotoHomePage", sender: nil)
            }else{
                self.performSegueWithIdentifier("gotoLoginPage", sender: nil)
            }
            

            
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
        
       //        if (FBSDKAccessToken.currentAccessToken() != nil) || (GIDSignIn.sharedInstance().hasAuthInKeychain()){
//            print("\(NSDate().formattedISO8601) : Facebook or Google is login")
//            do{
//                let fetchReq = NSFetchRequest(entityName: "User_Info");
//                let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
//                
//                self.accountId = result[0].valueForKey("accountId") as! String;
//            }catch{
//                print("\(NSDate().formattedISO8601) Error Reading Data");
//            }
//            checkStatus()
//            
//        } else {
//            print("\(NSDate().formattedISO8601) : Facebook or Google is not login")
//            self.performSegueWithIdentifier("gotoLogin", sender: nil)
//        }
    }
    
    func checkStatus(empEmail: String){
        print("\(NSDate().formattedISO8601) empEmail : \(empEmail)")
        print("\(NSDate().formattedISO8601) getStatusWebservice")
        let urlWs = NSURL(string: self.getUserByAccountIdUrl + empEmail)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let urlsession = NSURLSession.sharedSession()
       
        let request = urlsession.dataTaskWithURL(urlWs!) { (data, response, error) in
            do{
                
                let httpStatus = response as? NSHTTPURLResponse
                dispatch_async(dispatch_get_main_queue(), {
                    if (httpStatus!.statusCode == 201) {
                        print("\(NSDate().formattedISO8601) activated is true")
                       self.performSegueWithIdentifier("gotoHomePage", sender: nil)
                        
        
                    }else if (httpStatus!.statusCode == 404){
                        
                        let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("\(NSDate().formattedISO8601) responseString = \(responseString)")
                        NSOperationQueue.mainQueue().addOperationWithBlock {
                            let alert = UIAlertController(title: "Alert", message: responseString as? String, preferredStyle: UIAlertControllerStyle.Alert)
                            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                            self.presentViewController(alert, animated: true, completion: nil)
                        }
                        let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
                        do{
                            let fetchReq = NSFetchRequest(entityName: "User_Info");
                            let result = try context.executeFetchRequest(fetchReq);
                            result[0].setValue(false, forKey: "statusLogin");
                            try context.save();
                            print("\(NSDate().formattedISO8601) Save status Login Success")
//                            
//                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                            let loginVC =  storyboard.instantiateViewControllerWithIdentifier("mainVCID")
//                            self.presentViewController(loginVC, animated: true, completion: nil)
                            self.viewDidAppear(true)
                            
                        }catch{
                            print("\(NSDate().formattedISO8601) Error Saving Data");
                        }

                        
                    }else{
                        print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus!.statusCode)")
                        print("\(NSDate().formattedISO8601) response = \(response)")
                    }
                })
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        request.resume()
    }
    
    func setUserInfo(){
        // Write Data into CoreData
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq);
            if(result.count > 0){
                print("set Old User")
                result[0].setValue(self.profile[0].valueForKey("accountId"), forKey: "accountId");
                result[0].setValue(self.profile[0].valueForKey("empName") , forKey: "empName");
                result[0].setValue(self.profile[0].valueForKey("empEmail"), forKey: "empEmail");
                result[0].setValue(self.profile[0].valueForKey("avatarPic"), forKey: "avatarPic");
                result[0].setValue("default_avatar", forKey: "avatarPicTemp");
                result[0].setValue(self.profile[0].valueForKey("avatarName"), forKey: "avatarName")
                result[0].setValue(true, forKey: "avatarCheckSelect")
                result[0].setValue(self.profile[0].valueForKey("activate"), forKey: "activate")
                result[0].setValue(self.profile[0].valueForKey("token"), forKey: "token")
                result[0].setValue(self.profile[0].valueForKey("type"), forKey: "type")
                result[0].setValue(self.profile[0].valueForKey("_id"), forKey: "id_")
                result[0].setValue(self.profile[0].valueForKey("_rev"), forKey: "rev_")

            }else{
                print("set New User")
                let newUser = NSEntityDescription.insertNewObjectForEntityForName("User_Info", inManagedObjectContext: context);
                newUser.setValue(self.profile[0].valueForKey("accountId"), forKey: "accountId");
                newUser.setValue(self.profile[0].valueForKey("empName") , forKey: "empName");
                newUser.setValue(self.profile[0].valueForKey("empEmail"), forKey: "empEmail");
                newUser.setValue(self.profile[0].valueForKey("avatarPic"), forKey: "avatarPic");
                newUser.setValue("default_avatar", forKey: "avatarPicTemp");
                newUser.setValue(self.profile[0].valueForKey("avatarName"), forKey: "avatarName")
                newUser.setValue(true, forKey: "avatarCheckSelect")
                newUser.setValue(self.profile[0].valueForKey("activate"), forKey: "activate")
                newUser.setValue(self.profile[0].valueForKey("token"), forKey: "token")
                newUser.setValue(self.profile[0].valueForKey("type"), forKey: "type")
                newUser.setValue(self.profile[0].valueForKey("_id"), forKey: "id_")
                newUser.setValue(self.profile[0].valueForKey("_rev"), forKey: "rev_")
            }
            try context.save();
            print("\(NSDate().formattedISO8601) Save Data Success")
            
            self.performSegueWithIdentifier("gotoHomePage", sender: nil)
            
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data");
        }
    }

}

