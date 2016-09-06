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

class CommentViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    @IBOutlet weak var editor: RichEditorView!
    var toolbar: RichEditorToolbar!
    
    var topicId: String!
    var roomId: String!
    var userNameAvatar: String!
    var userPicAvatar: String!
    var receiveComment: NSDictionary!
    var ImagePicker = UIImagePickerController()
    var modelName: String!
    
    @IBOutlet weak var commentTxtView: RichEditorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** CommentVC ViewDidiLoad ***")
        topicId = receiveComment.valueForKey("_id") as! String
        roomId = receiveComment.valueForKey("roomId") as! String
        print("\(NSDate().formattedISO8601) topic id : \(topicId) room id : \(roomId)")
        modelName = UIDevice.currentDevice().modelName
        
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
        }catch{
            print("\(NSDate().formattedISO8601) Error: Reading Data");
            
        }
        
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
        //set toolbar to editor
        toolbar.delegate = self
        toolbar.editor = self.editor
        
        editor.delegate = self
        editor.inputAccessoryView = toolbar
        
        //setPlaceholderText
        editor.setPlaceholderText("Write something ...")
    }
    
    func postCommentWebservice(){
        print("\(NSDate().formattedISO8601) postCommentWebService")
        let urlWs = NSURL(string: "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/topic/post")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        //Replace " with \"
        let strComment = self.editor.contentHTML.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        
        let userNameAvatarReplaceLine = userNameAvatar.stringByReplacingOccurrencesOfString("\n", withString: "\\n").stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
        
        let jsonObj = "{\"topicId\":\"\(topicId)\",\"avatarName\":\"\(userNameAvatarReplaceLine)\",\"avatarPic\":\"\(userPicAvatar)\",\"content\":\"\(strComment)\",\"date\":\" \",\"type\":\"comment\",\"roomId\":\"\(roomId)\"}"
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
        print("\(NSDate().formattedISO8601) model Name Upload : \(modelName)")
        //Resize image
        print("\(NSDate().formattedISO8601) size image before resize : \(browseImg?.size)")
        let databe = UIImagePNGRepresentation(browseImg!)
        print("\(NSDate().formattedISO8601) Byte Img before resize : \(databe?.length)")
        
        if(modelName == "iPhone 6s Plus" || modelName == "iPhone 6 Plus" || modelName == "Simulator"){
            browseImg = Toucan(image: browseImg!).resize(CGSize(width: 300, height: 300), fitMode: Toucan.Resize.FitMode.Clip).image
        }else{
            browseImg = Toucan(image: browseImg!).resize(CGSize(width: 450, height: 450), fitMode: Toucan.Resize.FitMode.Clip).image
        }
        //90 and 60 //150 and 225 //450 and 300 //300 and 200
        
        print("\(NSDate().formattedISO8601) size image after resize : \(browseImg?.size)")
        let dataaf = UIImagePNGRepresentation(browseImg!)
        print("\(NSDate().formattedISO8601) Byte Img after resize : \(dataaf?.length)")
    
        uploadImage(browseImg!)
        
        picker.dismissViewControllerAnimated(true, completion: nil)
        
        
    }

    func uploadImage(objImage: UIImage) {
        print("\(NSDate().formattedISO8601) width : \(objImage.size.width) height :\(objImage.size.height)")
        
        let imageData = UIImagePNGRepresentation(objImage)
        if(imageData == nil)
        {
            return
        }
        
        // Generate Request
        print("\(NSDate().formattedISO8601) Upload Image")
        //        let url = NSURL(string: "http://localhost:9080/GO10WebService/UploadServlet")
        let url = NSURL(string: "http://go10webservice.au-syd.mybluemix.net/GO10WebService/UploadServlet")
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
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error == nil {
                do{
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary;
                    let responseUrl = jsonData.valueForKey("imgUrl") as! String
                    
//                    let imgUrl = "http://go10webservice.au-syd.mybluemix.net\(responseUrl)"
                    
//                     let imgUrl = "http://localhost:9080\(responseUrl)"
                    
                    print("\(NSDate().formattedISO8601) imgUrl: \(responseUrl)")
                    dispatch_async(dispatch_get_main_queue(), {
                        // Show Image
                        print("\(NSDate().formattedISO8601) Show Image")
                        var width = objImage.size.width
                        var height = objImage.size.height
                        if(width > height){
                            width = 295
                            height = 166
                            
                        }else if(width < height){
                            width = 230
                            height = 408
                        }else if(width == height){
                            width = 295
                            height = 295
                        }
                        self.toolbar.editor?.insertImage(responseUrl,width: width,height: height,alt: "insertImageUrl")
                        
                    })
                    
                }catch let error as NSError{
                    print("\(NSDate().formattedISO8601) JSON Error: \(error.localizedDescription)");
                }
    
            }else{
                print("\(NSDate().formattedISO8601) Error: \(error)")
            }
        }
        task.resume()
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
        if content.isEmpty {
            //htmlTextView.text = "HTML Preview"
        } else {
            //htmlTextView.text = content
        }
    }
    
    func richEditorTookFocus(editor: RichEditorView) { }
    
    func richEditorLostFocus(editor: RichEditorView) { }
    
    func richEditorDidLoad(editor: RichEditorView) { }
    
    func richEditor(editor: RichEditorView, shouldInteractWithURL url: NSURL) -> Bool { return true }
    
    func richEditor(editor: RichEditorView, handleCustomAction content: String) { }
    
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
    
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
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

