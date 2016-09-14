//
//  EditAvatarNameViewController.swift
//  GO10
//
//  Created by Go10Application on 5/19/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData

class EditAvatarNameViewController: UIViewController,UITextFieldDelegate {

    @IBOutlet weak var avatarNametxt: UITextField!
    
    var updateUserUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/user/updateUser"
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var modelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        avatarNametxt.delegate = self
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            avatarNametxt.font = FontModel.ipadminiPainText
        }
    }
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange,
                   replacementString string: String) -> Bool
    {
        let maxLength = 20
        let currentString: NSString = avatarNametxt.text!
        let newString: NSString =
            currentString.stringByReplacingCharactersInRange(range, withString: string)
        return newString.length <= maxLength
    }

    
    @IBAction func saveAvatarName(sender: AnyObject) {
        let avatarName = self.avatarNametxt.text
        
        if((avatarName == "") || checkSpace(avatarName!)) {
            let alert = UIAlertController(title: "Alert", message: "Please enter your name avatar.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else if(avatarName?.characters.count > 20 ){
            let alert = UIAlertController(title: "Alert", message: "Please enter your name characters less than 20", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            let context: NSManagedObjectContext = appDelegate.managedObjectContext;
            
            do{
                let fetchReq = NSFetchRequest(entityName: "User_Info");
                let result = try context.executeFetchRequest(fetchReq);
                result[0].setValue(avatarNametxt.text, forKey: "avatarName");
                try context.save();
                updateData()
            }catch{
                print("\(NSDate().formattedISO8601) Error Saving Data");
            }
            
            self.performSegueWithIdentifier("unwindToEditAvatarID", sender: nil)

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
