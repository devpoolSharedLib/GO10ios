//
//  CommentViewController.swift
//  GO10
//
//  Created by Go10Application on 5/11/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import RichEditorView
import Toucan
import CoreData
import MRProgress
import MRProgress.MRProgressOverlayView_AFNetworking

class CommentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet var commentView: UIView!
    @IBOutlet weak var editor: RichEditorView!
    @IBOutlet weak var commentTxtView: RichEditorView!
    
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
     var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
//    var pathTopicService = PropertyUtil.getPropertyFromPlist("data",key: "pathTopicService")
    var postCommentUrl: String!
    var uploadServletUrl: String!
  
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var toolbar: RichEditorToolbar!
    var topicId: String!
    var roomId: String!
    var empEmail: String!
    var userNameAvatar: String!
    var userPicAvatar: String!
    var receiveComment: NSDictionary!
    var ImagePicker = UIImagePickerController()
    var modelName: String!
    
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** CommentVC ViewDidiLoad ***")
        
        self.postCommentUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/post"
        self.uploadServletUrl = "\(self.domainUrl)GO10WebService/UploadServlet"
        topicId = receiveComment.valueForKey("_id") as! String
        roomId = receiveComment.valueForKey("roomId") as! String
        print("\(NSDate().formattedISO8601) topic id : \(topicId) room id : \(roomId)")
        modelName = UIDevice.currentDevice().modelName
        
        
        //set other button side back button
        self.navigationItem.leftItemsSupplementBackButton = true
        
        //Radius Button Border
        commentTxtView.layer.cornerRadius = 5
        editor.layer.cornerRadius = 5
        if(modelName.rangeOfString("ipad Mini") != nil){
            commentTxtView.setFontSize(17)
        }

        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            
            userNameAvatar = result[0].valueForKey("avatarName") as! String;
            userPicAvatar = result[0].valueForKey("avatarPic") as! String;
            empEmail = result[0].valueForKey("empEmail") as! String;
        }catch{
            print("\(NSDate().formattedISO8601) Error: Reading Data");
            
        }
        /*
        //set toolbar
        toolbar = RichEditorToolbar(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 44))
        
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
//        toolbar = RichEditor.setToolbar(self.view,width: self.view.bounds.width,height: 44)
        
         
        
        //set toolbar by RichEditorViewUtil
//        toolbar = RichEditor.setToolbar(self.view,width: self.view.bounds.width,height: 44)
        
        //set toolbar to editor
        toolbar.delegate = self
        toolbar.editor = self.editor
        
        editor.delegate = self
        editor.inputAccessoryView = toolbar
        
        //setPlaceholderText
        editor.setPlaceholderText("Write something ...")
        */
        
        //set toolbar by RichEditorViewUtil
        toolbar = RichEditorUtil.setToolbar(self.view.bounds.width,height: 44,editor: self.editor)
        //set toolbar to editor
        toolbar.delegate = self
        toolbar.editor = self.editor
        
        editor.delegate = self
        editor.inputAccessoryView = toolbar
        
    }
    
    func postCommentWebservice(){
        print("\(NSDate().formattedISO8601) postCommentWebService")
        let urlWs = NSURL(string: self.postCommentUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        //Replace " with \"
        let strComment = self.editor.contentHTML.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        
        let userNameAvatarReplaceLine = userNameAvatar.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        
        let jsonObj = "{\"topicId\":\"\(topicId)\",\"empEmail\":\"\(empEmail)\",\"avatarName\":\"\(userNameAvatarReplaceLine)\",\"avatarPic\":\"\(userPicAvatar)\",\"content\":\"\(strComment)\",\"date\":\" \",\"type\":\"comment\",\"roomId\":\"\(roomId)\"}"
        
        print("\(NSDate().formattedISO8601) Json Obj : \(jsonObj)")
        
        requestPost.HTTPBody = jsonObj.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
//        requestPost.timeoutInterval = 30
        requestPost.HTTPMethod = "POST"
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
        }
        request.resume()
        
    }
        
    @IBAction func submitComment(sender: AnyObject) {
        if((self.editor.getText().isEmpty || checkSpace(self.editor.getText())) && self.editor.getHTML().rangeOfString("<img") == nil){
            let alert = UIAlertController(title: "Alert", message: "Please enter your comment message.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
        else{
            postCommentWebservice()
            self.performSegueWithIdentifier("unwindToBoardVCID", sender:nil)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "unwindToBoardVCID" {
            let destVC = segue.destinationViewController as! BoardcontentViewController
            destVC.receiveBoardContentList = self.receiveComment    // send topic model (topic_id)
        }
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //browse image from gallery
        var browseImg =  info[UIImagePickerControllerOriginalImage] as? UIImage
        
        print("WIDTH : \(browseImg?.size.width)")
        print("HEIGHT: \(browseImg?.size.height)")
        print("RATIO: \((browseImg?.size.width)!/(browseImg?.size.height)!)")
        browseImg = ImageUtil.resizeImage(browseImg!, modelName: modelName)
        uploadImage(browseImg!)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
    }

    func uploadImage(objImage: UIImage) {

        print("\(NSDate().formattedISO8601) width : \(objImage.size.width) height :\(objImage.size.height)")
        
//        let imageData = UIImagePNGRepresentation(objImage)
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
        
        let MRProgressAF = MRProgressOverlayView.showOverlayAddedTo(self.commentView, animated: true)
        
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
                                print("aoisdfoadfsksakjdfbkajdfsbaljks")
                                
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
                        
                        MRProgressOverlayView.dismissOverlayForView(self.commentView, animated: true)

                        
                        print("\(NSDate().formattedISO8601)  REFRESHTABLE")
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

extension CommentViewController: RichEditorDelegate {
    
    func richEditor(editor: RichEditorView, heightDidChange height: Int) { }
    
    func richEditor(editor: RichEditorView, contentDidChange content: String) {
//        if content.isEmpty {
//            //htmlTextView.text = "HTML Preview"
//        } else {
//            //htmlTextView.text = content
//        }
    }
    
    func richEditorTookFocus(editor: RichEditorView) { }
    
    func richEditorLostFocus(editor: RichEditorView) { }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
    
    func richEditor(editor: RichEditorView, handleCusßtomAction content: String) { }
    
}

extension CommentViewController: RichEditorToolbarDelegate {
    
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
        print("richEditorToolbarChangeTextColor")
        return color
    }
    
    func richEditorToolbarChangeTextColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextColor(color)
        print("richEditorToolbarChangeTextColor")
    }
    
    func richEditorToolbarChangeBackgroundColor(toolbar: RichEditorToolbar) {
        let color = randomColor()
        toolbar.editor?.setTextBackgroundColor(color)
        print("richEditorToolbarChangeBackgroundColor")
    }
    
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        ImagePicker.allowsEditing = true
        self.presentViewController(ImagePicker, animated: true, completion: nil)
    }
    
    func richEditorToolbarInsertLink(toolbar: RichEditorToolbar) {
        // Can only add links to selected text, so make sure there is a range selection first
        if let hasSelection = toolbar.editor?.rangeSelectionExists() where hasSelection {
//            let strUrl = toolbar.editor?.runJS(("document.getSelection().getRangeAt(0).toString()"))
            toolbar.editor?.insertLink()
        }
    }
}

