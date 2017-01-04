//
//  NewTopicViewController.swift
//  GO10
//
//  Created by Go10Application on 5/17/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import RichEditorView
import Toucan
import CoreData
import KMPlaceholderTextView
import MRProgress.MRProgressOverlayView_AFNetworking

class NewTopicViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editor: RichEditorView!
    @IBOutlet weak var subjectTxtView: UITextView!
    @IBOutlet weak var contextTxtView: RichEditorView!
    @IBOutlet var newTopicView: UIView!
    
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var pathTopicService = PropertyUtil.getPropertyFromPlist("data",key: "pathTopicService")
    var postTopicUrl: String!
    var uploadServletUrl: String!
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var receiveNewTopic: NSDictionary!
    var empEmail: String!
    var userNameAvatar: String!
    var userPicAvatar: String!
    var roomId: String!
    var strEncodeBase64: String!
    var strDecodeBase64: String!
    var ImagePicker = UIImagePickerController()
    var modelName: String!
    var toolbar: RichEditorToolbar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** NewTopicVC ViewDidLoad ***")
        self.postTopicUrl = "\(self.domainUrl)\(self.pathTopicService)/post"
        self.uploadServletUrl = "\(self.domainUrl)/GO10WebService/UploadServlet"
        
        //set other button side back button
        self.navigationItem.leftItemsSupplementBackButton = true

        self.roomId = receiveNewTopic.valueForKey("_id") as! String
        print("\(NSDate().formattedISO8601) room id : \(roomId)")
        
        // Do any additional setup after loading the view.
        subjectTxtView.layer.cornerRadius = 5
        contextTxtView.layer.cornerRadius = 5
        editor.layer.cornerRadius = 5
        
        // Set font to each model
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            subjectTxtView.font = FontUtil.ipadminiPainText
            contextTxtView.setFontSize(17)
        }else{
            subjectTxtView.font = FontUtil.iphonepainText
            
        }
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            self.userNameAvatar = result[0].valueForKey("avatarName") as! String;
            self.userPicAvatar = result[0].valueForKey("avatarPic") as! String;
            self.empEmail = result[0].valueForKey("empEmail") as! String;
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
        
        let placeholderTextView = KMPlaceholderTextView(frame: subjectTxtView.bounds)
        view.addSubview(placeholderTextView)
        
        /*
        //set toolbar
//        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
        //custom toolbar
        toolbar.options = [RichEditorOptions.Undo,
                           RichEditorOptions.Redo,
                           RichEditorOptions.Bold,
                           RichEditorOptions.Image,
                           RichEditorOptions.Link,
//                           RichEditorOptions.AlignLeft,
//                           RichEditorOptions.AlignCenter,
//                           RichEditorOptions.AlignRight,
//                           RichEditorOptions.Indent,
//                           RichEditorOptions.Outdent
                            ]
        
         //set toolbar by RichEditorViewUtil
         toolbar = RichEditor.setToolbar(self.view,width: self.view.bounds.width,height: 44)

        //set toolbar to editor
        toolbar.delegate = self
        toolbar.editor = self.editor
       
        editor.delegate = self
        editor.inputAccessoryView = toolbar
        
        //setPlaceholderText
        editor.setPlaceholderText(" Write something ...")
         */
        
        //set toolbar by RichEditorViewUtil
        toolbar = RichEditorUtil.setToolbar(self.view.bounds.width,height: 44,editor: self.editor)
        //set toolbar to editor
        toolbar.delegate = self
        toolbar.editor = self.editor
        
        editor.delegate = self
        editor.inputAccessoryView = toolbar
    }

    func postTopicWebservice(){
        print("\(NSDate().formattedISO8601) postTopicWebService")
        let urlWs = NSURL(string: self.postTopicUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        // Replace Line in Subject
        let strSubjectReplaceLine = subjectTxtView.text.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        
        // let strContentReplaceLine = contentTxtView.text.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        let userNameAvatarReplaceLine = userNameAvatar.stringByReplacingOccurrencesOfString("\n", withString: "\\n")
        
        //Replace " with \"
        let strContent = self.editor.contentHTML.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        let strSubject = strSubjectReplaceLine.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")

        let jsonObj = "{\"subject\":\"\(strSubject)\",\"content\":\"\(strContent)\",\"empEmail\":\"\(empEmail)\",\"avatarName\":\"\(userNameAvatarReplaceLine)\",\"avatarPic\":\"\(userPicAvatar)\",\"date\":\" \",\"type\":\"host\",\"roomId\":\"\(roomId)\",\"countLike\":0}"
        
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
        requestPost.HTTPMethod = "POST"
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithRequest(requestPost) { (data, response, error) in
            
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
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("unwindToRoomVCID", sender:nil)
            })
        }
        request.resume()
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        //browse image from gallery
        var browseImg =  info[UIImagePickerControllerOriginalImage] as? UIImage
        browseImg = ImageUtil.resizeImage(browseImg!, modelName: modelName)
        self.uploadImage(browseImg!)
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
        
        // Define the multipart request type
        let boundary = "Boundary-\(NSUUID().UUIDString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
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
        let MRProgressAF = MRProgressOverlayView.showOverlayAddedTo(self.newTopicView, animated: true)
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error == nil {
                do{
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary;
                    let responseUrl = jsonData.valueForKey("imgUrl") as! String
                    
                    print("\(NSDate().formattedISO8601) imgUrl: \(responseUrl)")
                    dispatch_async(dispatch_get_main_queue(), {
                        // Show Image
                        print("\(NSDate().formattedISO8601) Show Image")
                        var width = objImage.size.width
                        var height = objImage.size.height
                        let ratio = round(width/height*100)/100
                        print(">>>>>>> RATIO : \(ratio)")
                        if(ratio > 1) {
                            if(ratio == 1.33) {
                                print("4:3 landscape")
                                width = 295
                                height = 222
                            } else if(ratio == 1.78 || ratio == 1.77) {
                                print("16:9 landscape")
                                width = 295
                                height = 166
                            } else {
                                print("Other Resulotion landscape")
                                width = 295
                                height = 166
                            }
                        } else if(ratio < 1) {
                            if(ratio == 0.75) {
                                print("3:4 portrait")
                                width = 230
                                height = 307
                            } else if(ratio == 0.56) {
                                print("9:16 portrait")
                                width = 230
                                height = 410
                            } else {
                                print("Other Resulotion protrait")
                                width = 230
                                height = 410
                            }
                        } else if(ratio == 1) {
                            print("1:1 square")
                            width = 295
                            height = 295
                        }
                        self.toolbar.editor?.insertImage(responseUrl,width: width,height: height,alt: "insertImageUrl")
                        MRProgressOverlayView.dismissOverlayForView(self.newTopicView, animated: true)
                    })
                }catch let error as NSError{
                    print("\(NSDate().formattedISO8601) JSON Error: \(error.localizedDescription)");
                }
            }else{
                print("\(NSDate().formattedISO8601) Error: \(error)")
            }
        }
        task.resume()
        MRProgressAF.setModeAndProgressWithStateOfTask(task)
    }
    
    @IBAction func submitTopic(sender: AnyObject) {
        if((self.subjectTxtView.text.isEmpty || checkSpace(self.subjectTxtView.text) || self.editor.getText().isEmpty || checkSpace(self.editor.getText())) && self.editor.getHTML().rangeOfString("<img") == nil){
            let alert = UIAlertController(title: "Alert", message:"Please enter your subject and comment message.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }else{
            postTopicWebservice()
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToRoomVCID" {
            let destVC = segue.destinationViewController as! RoomViewController
            destVC.receiveRoomList = self.receiveNewTopic  //send room Model (room_id , room_name)
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


extension NewTopicViewController: RichEditorDelegate {
    
    func richEditor(editor: RichEditorView, heightDidChange height: Int) { }
    
    func richEditor(editor: RichEditorView, contentDidChange content: String) {
        if content.isEmpty {
//            htmlTextView.text = "HTML Preview"
        } else {
//            htmlTextView.text = content
        }
    }
    
    func richEditorTookFocus(editor: RichEditorView) {    }
    
    func richEditorLostFocus(editor: RichEditorView) {    }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
    
    func richEditor(editor: RichEditorView, handleCustomAction content: String) { }
    
}

extension NewTopicViewController: RichEditorToolbarDelegate {
    
    private func randomColor() -> UIColor {
        let colors = [
            UIColor.redColor(),
            UIColor.orangeColor(),
            UIColor.yellowColor(),
            UIColor.greenColor(),
            UIColor.blueColor(),
            UIColor.purpleColor()
        ]
        
        let color = colors[Int(arc4random_uniform(UInt32(colors.count)))]
        return color
    }
    
    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
    }
    
    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
        
    }
//    
//    func richEditorToolbarBold(toolbar: RichEditorToolbar){
//        print("BOLD")
//        toolbar.editor?.bold()
//        
//       
//    }
    
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        print("asjkhdfklasdhjdfjkhfjkasbhgjkhsgjkhgjklshjl")
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        ImagePicker.allowsEditing = true
        self.presentViewController(ImagePicker, animated: true, completion: nil)
    }
    
    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
//        let strUrl = toolbar.editor?.runJS(("document.getSelection().getRangeAt(0).toString()"))
        toolbar.editor?.insertLink()
        }
    }
}
