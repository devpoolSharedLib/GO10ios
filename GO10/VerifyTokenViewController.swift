//
//  VerifyTokenViewController.swift
//  GO10
//
//  Created by Go10Application on 6/13/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData
import MRProgress

class VerifyTokenViewController: UIViewController {

    @IBOutlet weak var painTxt: UILabel!
    @IBOutlet weak var tokenTxtV: UITextView!
    @IBOutlet weak var verifyBtn: UIButton!
    @IBOutlet var verifyView: UIView!
    
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqRoomManageInfo = NSFetchRequest(entityName: "Room_Manage_Info")
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var contexroot = PropertyUtil.getPropertyFromPlist("data",key: "contexroot")
    var getUserByToken:String!
    var profile = [NSDictionary]()
    var activate: Bool!
    var modelName: String!
   
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** VerifyTokenVC Viewdidload ***")
        self.getUserByToken =  "\(self.domainUrl)\(contexroot)api/\(self.versionServer)user/getUserByToken?"
        
        //Radius verify textview Border
        tokenTxtV.layer.cornerRadius = 5
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            print("SIMULATOR")
            painTxt.font = FontUtil.ipadminiPainText
            tokenTxtV.font = FontUtil.ipadminiPainText
            verifyBtn.titleLabel?.font = FontUtil.ipadminiPainText
        }
        
        MRProgressOverlayView.showOverlayAddedTo(self.verifyView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        MRProgressOverlayView.dismissOverlayForView(self.verifyView, animated: true)
    }
    
    @IBAction func verifyToken(sender: AnyObject) {
        let token = self.tokenTxtV.text
        print("xxxxx \(token)")
        if((token == "") || checkSpace(token!)) {
            let alert = UIAlertController(title: "Alert", message: "The token is empty. Please enter the invitation code.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            checkToken()
            
        }
    }
    
    func checkToken(){
        print("\(NSDate().formattedISO8601) token : \(tokenTxtV.text)")
        print("\(NSDate().formattedISO8601) getTokenWebservice")
        let url = "\(self.getUserByToken)token=\(tokenTxtV.text)"
        let urlWs = NSURL(string: url)
        print("\(NSDate().formattedISO8601) URL : \(url)")
        let urlsession = NSURLSession.sharedSession()
        
        let request = urlsession.dataTaskWithURL(urlWs!) { (data, response, error) in
            do{
                self.profile = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! [NSDictionary]
                print("\(NSDate().formattedISO8601) profile : \(self.profile)")
                self.activate = self.profile[0].valueForKey("activate") as! Bool
                print("\(NSDate().formattedISO8601) status :\(self.activate)")
                if(self.profile.isEmpty){
                    print("Profile is Empty")
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Alert", message: "The invitation code is invalid.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }else if((self.activate) == true){
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Alert", message: "This invitation code is activated.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                }else{
                    self.saveTokenToCoredata()
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.performSegueWithIdentifier("gotoSetting", sender:nil)
                    }
                }
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        request.resume()
    }
    
    // Write Data into CoreData
    func saveTokenToCoredata(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
            result[0].setValue(self.tokenTxtV.text, forKey: "token")
            result[0].setValue(self.profile[0].valueForKey("empName"), forKey: "empName")
            result[0].setValue(self.profile[0].valueForKey("empEmail"), forKey: "empEmail")
            result[0].setValue(self.profile[0].valueForKey("type"), forKey: "type")
            result[0].setValue(self.profile[0].valueForKey("activate"), forKey: "activate")
            result[0].setValue(self.profile[0].valueForKey("_id"), forKey: "id_")
            result[0].setValue(self.profile[0].valueForKey("_rev"), forKey: "rev_")
            try self.context.save()
            print("\(NSDate().formattedISO8601) Save Data Success")
                   }catch{
            print("\(NSDate().formattedISO8601) Error Saving Profile Data")
        }
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
