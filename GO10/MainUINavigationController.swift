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
//    var getUserByAccountIdUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/user/getUserByAccountId?accountId="
    var getUserByAccountIdUrl = "http://go10.au-syd.mybluemix.net/GO10WebService/api/user/getUserByAccountId?accountId="
    
    var profile = [NSDictionary]();
    var status: Bool!
    var accountId: String!
    var statusLogin: Bool!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** MainVC ViewDidAppear ***")
         let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            print("Results : \(result)")
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
                self.performSegueWithIdentifier("gotoHomePage", sender: nil)
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
    
    func checkStatus(){
        print("\(NSDate().formattedISO8601) accoundId : \(self.accountId)")
        print("\(NSDate().formattedISO8601) getStatusWebservice")
        let urlWs = NSURL(string: self.getUserByAccountIdUrl + self.accountId)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let urlsession = NSURLSession.sharedSession()
       
        let request = urlsession.dataTaskWithURL(urlWs!) { (data, response, error) in
            do{
                
                self.profile = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) profile : \(self.profile)")
                if(self.profile.isEmpty){
                    print("Profile is Empty")
                     self.performSegueWithIdentifier("gotoVerify", sender: nil)
                }
                else{
                    self.setUserInfo()
                }
                
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

