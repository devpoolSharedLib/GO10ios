//
//  SelectAvatarViewController.swift
//  GO10
//
//  Created by Go10Application on 5/17/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CarbonKit
import CoreData

class SelectAvatarViewController: UIViewController, CarbonTabSwipeNavigationDelegate {
    
    var updateUserUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/user/updateUser"
    
    var items = NSArray()
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var carbonTabSwipeNavigation: CarbonTabSwipeNavigation = CarbonTabSwipeNavigation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** SelectAvatarVC ViewDidLoad ***")
        self.title = "Select Avatar"
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let userAvatar = result[0].valueForKey("avatarPic") as! String;
            
            result[0].setValue(userAvatar, forKey: "avatarPicTemp");
            try context.save();

        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Data");
        }
    
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        items = ["Man", "Woman"]
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation(items: items as [AnyObject], delegate: self)
        carbonTabSwipeNavigation.insertIntoRootViewController(self)
        self.style()

    }
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        switch index {
        case 0:
            return self.storyboard!.instantiateViewControllerWithIdentifier("MenAvatarVC") as! MenAvatarViewController
        default:
            return self.storyboard!.instantiateViewControllerWithIdentifier("WomenAvatarVC") as! WomenAvatarViewController
        }

    }
    
    
    func style() {
        let color: UIColor = UIColor(red: 24.0 / 255, green: 75.0 / 255, blue: 152.0 / 255, alpha: 1)
//        self.navigationController!.navigationBar.translucent = false
//        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
//        self.navigationController!.navigationBar.barTintColor = color
//        self.navigationController!.navigationBar.barStyle = .BlackTranslucent
        carbonTabSwipeNavigation.toolbar.translucent = false
        carbonTabSwipeNavigation.setIndicatorColor(color)
//        carbonTabSwipeNavigation.setTabExtraWidth(30)
        
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(150, forSegmentAtIndex: 0)
        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(150, forSegmentAtIndex: 1)
//        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(150, forSegmentAtIndex: 2)
//        carbonTabSwipeNavigation.carbonSegmentedControl!.setWidth(150, forSegmentAtIndex: 3)
        
        carbonTabSwipeNavigation.setNormalColor(UIColor.blackColor().colorWithAlphaComponent(0.6))
        carbonTabSwipeNavigation.setSelectedColor(color, font: UIFont.boldSystemFontOfSize(14))
        
    }
    
    @IBAction func clickSelectAvatar(sender: AnyObject) {
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let userAvatarTemp = result[0].valueForKey("avatarPicTemp") as! String;
            
            let avatarCheckSelect = result[0].valueForKey("avatarCheckSelect") as! Bool;

            if(avatarCheckSelect){
                result[0].setValue(userAvatarTemp, forKey: "avatarPic");
                try context.save();
                updateData()
                self.performSegueWithIdentifier("unwindToEditAvatarID", sender: nil)
            }else{
                let alert = UIAlertController(title: "Alert", message: "Please Select Avatar.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Data");
        }

        
    }
    
    
    
    func updateData(){
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let _id = result[0].valueForKey("id_") as! String;
            let _rev = result[0].valueForKey("rev_") as! String;
            let accountId = result[0].valueForKey("accountId") as! String;
            let empName = result[0].valueForKey("empName") as! String;
            let empEmail = result[0].valueForKey("empEmail") as! String;
            let avatarName = result[0].valueForKey("avatarName") as! String;
            let avatarPic = result[0].valueForKey("avatarPic") as! String;
//            let token = result[0].valueForKey("token") as! String;
            let activate = result[0].valueForKey("activate") as! Bool;
            let type = result[0].valueForKey("type") as! String;
            
            let birthday = result[0].valueForKey("birthday") as! String;
            
            print("\(NSDate().formattedISO8601) putUpdateWebservice")
            let urlWs = NSURL(string: self.updateUserUrl)
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
            print("\(NSDate().formattedISO8601) Error Reading and Saving Data");
        }
        
    }

}
