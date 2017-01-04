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

}

