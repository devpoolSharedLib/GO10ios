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
import MRProgress.MRProgressOverlayView_AFNetworking

class EditAvatarTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet weak var avatarImageButton: UIButton!
    @IBOutlet weak var avartarNameLbl: UILabel!
    @IBOutlet weak var editAvatarLbl: UILabel!
    @IBOutlet weak var cameraImg: UIImageView!
    @IBOutlet var editavatarTableView: UITableView!
    //    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var getUserByTokenUrl: String!
    var updateUserUrl: String!
    var uploadServletUrl: String!
    var recieveformverify: String!
    var recieveStatusLogin: String!
    var backbtn: UIBarButtonItem!
    var submitBtn: UIBarButtonItem!
    var modelName: String!
    var ImagePicker = UIImagePickerController()
    var avatatPic: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.getUserByTokenUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)user/getUserByToken?token="
        self.updateUserUrl = "\\(self.domainUrl)GO10WebService/api/\(self.versionServer)user/updateUser"
        self.uploadServletUrl = "\(self.domainUrl)GO10WebService/UploadServlet"
        modelName = UIDevice.currentDevice().modelName
        print("*** EditAvatarTableVC ViewDidLoad")
        if(modelName.rangeOfString("ipad Mini") != nil){
            avartarNameLbl.font = FontUtil.ipadminiPainText
            editAvatarLbl.font = FontUtil.ipadminiHotTopicNameAvatar
        }else{
            avartarNameLbl.font = FontUtil.iphonepainText
            editAvatarLbl.font = FontUtil.iphoneHotTopicNameAvatar
        }
        if(recieveStatusLogin == nil){
            recieveStatusLogin = "not First Login"
        }
            if(recieveStatusLogin == "First Login" && recieveStatusLogin != nil){
                print("First Login")
                    do{
                        let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
                        result[0].setValue(false, forKey: "statusLogin")
                        try self.context.save()
                        }catch{
                            print("\(NSDate().formattedISO8601) Error Reading Data")
                        }
                self.navigationItem.setHidesBackButton(true, animated:true)
            }else{
                print("not First Login")
                submitBtn =  self.navigationItem.rightBarButtonItems![0]
                self.navigationItem.rightBarButtonItems?.removeAtIndex(0)
            }
    }
    
    @IBAction func gotoSelectAvatarView(sender: AnyObject) {
        self.performSegueWithIdentifier("gotoSelectAvatar", sender: nil)
//                    let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
//        
//                    let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel) { action in
//                        // ...
//                    }
//                    alertController.addAction(cancelAction)
//        
//                    let uploadPhoto = UIAlertAction(title: "Upload Photo", style: .Default) { action in
//                        print("Upload Photo")
//                        self.ImagePicker.delegate = self
//                        self.ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
//                        self.ImagePicker.allowsEditing = true
//                        self.presentViewController(self.ImagePicker, animated: true, completion: nil)
//                    }
//        
//                    let selectAvatar = UIAlertAction(title: "Select Avatar", style: .Default) { action in
//                        print("Select Avatar")
//                        self.performSegueWithIdentifier("gotoSelectAvatar", sender: nil)
//                    }
//        
//                    alertController.addAction(uploadPhoto)
//                    alertController.addAction(selectAvatar)
//                    self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //browse image from gallery
        var browseImg =  info[UIImagePickerControllerOriginalImage] as? UIImage
        browseImg = ImageUtil.resizeImage(browseImg!, modelName: modelName)
        uploadImage(browseImg!)
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func uploadImage(objImage: UIImage) {
        print("\(NSDate().formattedISO8601) width : \(objImage.size.width) height :\(objImage.size.height)")
        let imageData = UIImageJPEGRepresentation(objImage, 0.8)
        if(imageData == nil)
        {
            return
        }
        // Generate Request
        print("\(NSDate().formattedISO8601) Upload Image")
        let url = NSURL(string: self.uploadServletUrl)
        print("\(NSDate().formattedISO8601) url request image : \(url)")
        let request = NSMutableURLRequest(URL: url!)
        request.HTTPMethod = "POST"
        request.timeoutInterval = 30
        // Define the multipart request type
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        //requestPost.timeoutInterval = 30
        let fileName = "\(objImage)upload001.jpg"
        let mimeType = "image/jpg"
        
        // Define the data post parameter
        let body = NSMutableData()
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"test\"\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("hi\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Disposition:form-data; name=\"file\"; filename=\"\(fileName)\"\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("Content-Type: \(mimeType)\r\n\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData(imageData!)
        body.appendData("\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        body.appendData("--\(boundary)--\r\n".dataUsingEncoding(NSUTF8StringEncoding)!)
        request.HTTPBody = body
        let session = NSURLSession.sharedSession()
        let MRProgressAF = MRProgressOverlayView.showOverlayAddedTo(self.editavatarTableView, animated: true)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error == nil {
                do{
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary
                    let responseUrl = jsonData.valueForKey("imgUrl") as! String
                    print("\(NSDate().formattedISO8601) imgUrl: \(responseUrl)")
                    dispatch_async(dispatch_get_main_queue(), {
                        // Show Image
                        print("\(NSDate().formattedISO8601) Show Image")
//                        self.toolbar.editor?.insertImage(responseUrl,width: width,height: height,alt: "insertImageUrl")
                        
                        let url = NSURL(string:responseUrl)
                        let data = NSData(contentsOfURL:url!)
                        if data != nil {
//                            self.avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                            self.avatarImageButton.setImage(UIImage(data:data!), forState: .Normal)
                        }
                        self.avatatPic = responseUrl
                        self.updataData()
                        MRProgressOverlayView.dismissOverlayForView(self.editavatarTableView, animated: true)
                    })
                    
                }catch let error as NSError{
                    print("\(NSDate().formattedISO8601) JSON Error: \(error.localizedDescription)")
                }
            }else{
                print("\(NSDate().formattedISO8601) Error: \(error)")
            }
        }
        task.resume()
        MRProgressAF.setModeAndProgressWithStateOfTask(task)
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        print("*** EditAvatarTableVC ViewDidAppear ***")
        MRProgressOverlayView.showOverlayAddedTo(self.editavatarTableView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String
            let userNameAvatar = result[0].valueForKey("avatarName") as! String
            print("\(NSDate().formattedISO8601) Data_Info :\(result)")
            let avatarImage = UIImage(named: userPicAvatar)
            if(avatarImage != nil){
                print("\(NSDate().formattedISO8601) avatarImage : \(userPicAvatar)")
                avatarImageButton.imageView?.contentMode = UIViewContentMode.ScaleAspectFit
                avatarImageButton.setImage(avatarImage, forState: .Normal)
                cameraImg.image = UIImage(named: "camera")
                avatarImageButton.addSubview(cameraImg)
            }
            editAvatarLbl.text = userNameAvatar
            MRProgressOverlayView.dismissOverlayForView(self.editavatarTableView, animated: true)
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }

    @IBAction func submitAvatar(sender: AnyObject) {
        print("\(NSDate().formattedISO8601) submitAvatar")
        if(recieveStatusLogin == "First Login" && recieveStatusLogin != nil){
            print("First Login")
            do{
                let result = try self.context.executeFetchRequest(self.fetchReqUserInfo)
                result[0].setValue(false, forKey: "statusLogin")
                try self.context.save()
            }catch{
                print("\(NSDate().formattedISO8601) Error Reading Data")
            }
            self.navigationItem.setHidesBackButton(true, animated:true)
        }
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let userPicAvatar = result[0].valueForKey("avatarPic") as! String
            let userNameAvatar = result[0].valueForKey("avatarName") as! String
            if(userNameAvatar=="Avatar Name" || userPicAvatar == "default_avatar"){
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let alert = UIAlertController(title: "Alert", message: "Please Set Your Avatar Picture and Avatar Name.", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
            }else{
                self.updataDataToDB()
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    self.performSegueWithIdentifier("gotoHomePage", sender:nil)
                }
            }
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    func updataData(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            result[0].setValue(self.avatatPic, forKey: "avatarPic")
            try context.save()
            self.updataDataToDB()
        }catch{
            print("\(NSDate().formattedISO8601) Error Saving Data")
        }
    }
    
    func updataDataToDB(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            let _id = result[0].valueForKey("id_") as! String
            let _rev = result[0].valueForKey("rev_") as! String
            let empName = result[0].valueForKey("empName") as! String
            let empEmail = result[0].valueForKey("empEmail") as! String
            let avatarName = result[0].valueForKey("avatarName") as! String
            let avatarPic = result[0].valueForKey("avatarPic") as! String
            let activate = result[0].valueForKey("activate") as! Bool
            let type = result[0].valueForKey("type") as! String
            let birthday = result[0].valueForKey("birthday") as! String
            result[0].setValue(true, forKey: "activate")
            print("\(NSDate().formattedISO8601) putUpdateWebservice")
            let urlWs = NSURL(string: self.updateUserUrl )
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
            print("\(NSDate().formattedISO8601) Error Reading and Saving Data")
        }
    }
    
    @IBAction func unwindToEditAvatar(segue: UIStoryboardSegue) {
        print("\(NSDate().formattedISO8601) unwindToEditAvatar")
    }
    
}
