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
    var recieveformverify: String!
    var recieveFirstLogin: String!
     var backbtn: UIBarButtonItem!
     var submitBtn: UIBarButtonItem!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var avatarImageButton: UIButton!
    
    @IBOutlet weak var avartarNameLbl: UILabel!
    @IBOutlet weak var editAvatarLbl: UILabel!
    @IBOutlet weak var cameraImg: UIImageView!
    @IBOutlet var editavatarTableView: UITableView!
    
    var modelName: String!
    override func viewDidLoad() {
        super.viewDidLoad()
        modelName = UIDevice.currentDevice().modelName
        print("*** EditAvatarTableVC ViewDidLoad")
        if(modelName.rangeOfString("ipad Mini") != nil){
            avartarNameLbl.font = FontModel.ipadminiPainText
            editAvatarLbl.font = FontModel.ipadminiHotTopicNameAvatar
        }
    
            if(recieveFirstLogin == "First Login"){
                print("First Login")
                self.navigationItem.setHidesBackButton(true, animated:true);
                
            }else{
                print("not First Login")
                submitBtn =  self.navigationItem.rightBarButtonItems![0]
                self.navigationItem.rightBarButtonItems?.removeAtIndex(0)
            }
        
//        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
//        do{
//            let fetchReq = NSFetchRequest(entityName: "User_Info");
//            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
//            
//            let activate = result[0].valueForKey("activate") as! Bool;
//            print("activate :\(activate)")
//            if(!activate){
//                print("from verfify page")
//                self.navigationItem.setHidesBackButton(true, animated:true);
//                
//            }else{
//                print("not from verfify page")
//                submitBtn =  self.navigationItem.rightBarButtonItems![0]
//                self.navigationItem.rightBarButtonItems?.removeAtIndex(0)
//            }
//        }catch{
//            print("\(NSDate().formattedISO8601) Error Reading Data");
//        }

    }
    
    override func viewDidAppear(animated: Bool) {
        
        super.viewDidAppear(animated)
        print("*** EditAvatarTableVC ViewDidAppear ***")
        MRProgressOverlayView.showOverlayAddedTo(self.editavatarTableView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String;
            let userNameAvatar = result[0].valueForKey("avatarName") as! String;
            let activate = result[0].valueForKey("activate") as! Bool;
            print("\(NSDate().formattedISO8601) result :\(result)")
            if(!activate){
                 print("from verfify page")
                self.navigationItem.setHidesBackButton(true, animated:true);
                
            }

            
            let avatarImage = UIImage(named: userPicAvatar)
            
            if(avatarImage != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(userPicAvatar)")
                avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                avatarImageButton.setImage(avatarImage, forState: .Normal)
                cameraImg.image = UIImage(named: "camera")
            }
            
            editAvatarLbl.text = userNameAvatar
//            updateRev(token)
            MRProgressOverlayView.dismissOverlayForView(self.editavatarTableView, animated: true)
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
        
    }

    

    @IBAction func submitAvatar(sender: AnyObject) {
       updateData()
        NSOperationQueue.mainQueue().addOperationWithBlock {
            self.performSegueWithIdentifier("gotoHomePage", sender:nil)
        }
    }
    
    func updateRev(token: String){
        print("\(NSDate().formattedISO8601) getTokenWebservice")
        let url = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/user/getUserByToken?token=\(token)"
        let urlWs = NSURL(string: url)
        print("\(NSDate().formattedISO8601) URL : \(url)")
        let urlsession = NSURLSession.sharedSession()
        
        let request = urlsession.dataTaskWithURL(urlWs!) { (data, response, error) in
            do{
                let profile = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) profile : \(profile)")
                
                // Write Data into CoreData
                let context: NSManagedObjectContext = self.appDelegate.managedObjectContext;
                do{
                    let fetchReq = NSFetchRequest(entityName: "User_Info");
                    let result = try context.executeFetchRequest(fetchReq);
                    result[0].setValue(profile[0].valueForKey("_rev"), forKey: "rev_")
                    try context.save();
                    print("\(NSDate().formattedISO8601) Save Data Success")
                    
                    }catch{
                        print("\(NSDate().formattedISO8601) Error Saving Profile Data");
                    }
                
                }catch let error as NSError{
                    print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
                }
            }
            request.resume()
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
            let activate = result[0].valueForKey("activate") as! Bool;
            let type = result[0].valueForKey("type") as! String;
            let birthday = result[0].valueForKey("birthday") as! String;
            result[0].setValue(true, forKey: "activate")
            
            print("\(NSDate().formattedISO8601) putUpdateWebservice")
            let urlWs = NSURL(string: "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/user/updateUser")
            print("\(NSDate().formattedISO8601) URL : \(urlWs)")
            let requestPost = NSMutableURLRequest(URL: urlWs!)
            
            
            let jsonObj = "{\"_id\":\"\(_id)\",\"_rev\":\"\(_rev)\",\"accountId\":\"\(accountId)\",\"empName\":\"\(empName)\",\"empEmail\":\"\(empEmail)\",\"avatarName\":\"\(avatarName)\",\"avatarPic\":\"\(avatarPic)\",\"birthday\":\"\(birthday)\",\"activate\":\"\(activate)\",\"type\":\"\(type)\"}"
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
    @IBAction func unwindToEditAvatar(segue: UIStoryboardSegue) {
        print("\(NSDate().formattedISO8601) unwindToEditAvatar")
    }
}
