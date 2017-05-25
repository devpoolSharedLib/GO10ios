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
    
//    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var contexroot = PropertyUtil.getPropertyFromPlist("data",key: "contexroot")
    var getUserByAccountIdUrl: String!
    var profile = [NSDictionary]()
    var status: Bool!
    var accountId: String!
    var statusLogin: Bool!
    var empEmail: String!
    var accessAppUrl: String!
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** MainVC ViewDidAppear ***")
        self.getUserByAccountIdUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)user/checkUserActivation?empEmail="
        self.accessAppUrl = "\(self.domainUrl)\(contexroot)api/\(self.versionServer)topic/accessapp?"
        do{
            if(checkStatusLogin()){
                print("statusLogin true")
                let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
                self.empEmail = result[0].valueForKey("empEmail") as! String
                checkUserActivation(self.empEmail)
                self.accessAppWebservice(self.empEmail)
            }else{
                print("statusLogin false")
                self.performSegueWithIdentifier("gotoLoginPage", sender: nil)
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    func checkStatusLogin() -> BooleanType{
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            if(result.count == 0){
                print("No data in coredata")
                return false
            }else if((result[0].valueForKey("statusLogin")) as! Bool == false){
                return false
            }else{
                for results in result as [NSManagedObject] {
                    print("\(NSDate().formattedISO8601) results : \(results)")
                }
                return true
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
            return false
        }
    }
    
    func checkUserActivation(empEmail: String){
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
                        do{
                            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
                            result[0].setValue(false, forKey: "statusLogin")
                            try self.context.save()
                            print("\(NSDate().formattedISO8601) Save status Login Success")
                            self.viewDidAppear(true)
                        }catch{
                            print("\(NSDate().formattedISO8601) Error Saving Data")
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
    
    func accessAppWebservice(empEmail: String){
        print("\(NSDate().formattedISO8601) accessAppWebservice")
        
        let urlWs = NSURL(string: "\(self.accessAppUrl)empEmail=\(empEmail)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil && data != nil else {
                print("\(NSDate().formattedISO8601) error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 201 {
                print("\(NSDate().formattedISO8601) statusCode should be 201, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }else{
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
            }
        }
        requestSent.resume()
    }
    
}