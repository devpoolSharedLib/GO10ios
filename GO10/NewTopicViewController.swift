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
class NewTopicViewController: UIViewController , UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var editor: RichEditorView!
    @IBOutlet weak var subjectTxtView: UITextView!
    @IBOutlet weak var contextTxtView: RichEditorView!
    
//    var postTopicUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/topic/post"
//    var uploadServletUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/UploadServlet"
    var postTopicUrl = "http://go10.au-syd.mybluemix.net/GO10WebService/api/topic/post"
    var uploadServletUrl = "http://go10.au-syd.mybluemix.net/GO10WebService/UploadServlet"
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
        roomId = receiveNewTopic.valueForKey("_id") as! String
        print("\(NSDate().formattedISO8601) room id : \(roomId)")
        // Do any additional setup after loading the view.
        subjectTxtView.layer.cornerRadius = 5
        contextTxtView.layer.cornerRadius = 5
        editor.layer.cornerRadius = 5
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            subjectTxtView.font = FontModel.ipadminiPainText
            contextTxtView.setFontSize(17)
        }
        
        let context: NSManagedObjectContext = appDelegate.managedObjectContext;
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq) as! [NSManagedObject];
            userNameAvatar = result[0].valueForKey("avatarName") as! String;
            userPicAvatar = result[0].valueForKey("avatarPic") as! String;
            empEmail = result[0].valueForKey("empEmail") as! String;
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data");
        }
        
        let placeholderTextView = KMPlaceholderTextView(frame: subjectTxtView.bounds)
        view.addSubview(placeholderTextView)
        
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
        editor.setPlaceholderText(" Write something ...")
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
//                let topicId:NSDictionary = ["_id":responseString!]
//                let storyboard = UIStoryboard(name: "Main", bundle: nil)
//                let boardVC =  storyboard.instantiateViewControllerWithIdentifier("boardContentVCID") as! BoardcontentViewController
//                boardVC.receiveBoardContentList = topicId
//                 self.presentViewController(boardVC, animated: true, completion: nil)
                
            })
        }
        request.resume()
        
    }
    
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        //browse image from gallery
        var browseImg =  info[UIImagePickerControllerOriginalImage] as? UIImage
        
        //Resize image
        print("\(NSDate().formattedISO8601) size image before resize : \(browseImg?.size)")
        let databe = UIImagePNGRepresentation(browseImg!)
        
        print("\(NSDate().formattedISO8601) Byte Img before resize : \(databe?.length)")
//        browseImg = Toucan(image: browseImg!).resize(CGSize(width: 100, height: 100), fitMode: Toucan.Resize.FitMode.Clip).image
        
        if(modelName == "iPhone 6s Plus" || modelName == "iPhone 6 Plus" || modelName == "Simulator"){
            browseImg = Toucan(image: browseImg!).resize(CGSize(width: 300, height: 300), fitMode: Toucan.Resize.FitMode.Clip).image
        }else{
            browseImg = Toucan(image: browseImg!).resize(CGSize(width: 450, height: 450), fitMode: Toucan.Resize.FitMode.Clip).image
        }

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
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            if error == nil {
                do{
                    let jsonData = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as! NSMutableDictionary;
                    let responseUrl = jsonData.valueForKey("imgUrl") as! String
                    
                    print("\(NSDate().formattedISO8601) imgUrl: \(responseUrl)")
                    
//                    let imgUrl = "http://go10webservice.au-syd.mybluemix.net\(responseUrl)"
                    
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
    
    @IBAction func submitTopic(sender: AnyObject) {
        if((self.subjectTxtView.text.isEmpty || checkSpace(self.subjectTxtView.text) || self.editor.getText().isEmpty || checkSpace(self.editor.getText())) && self.editor.getHTML().rangeOfString("<img") == nil){
            let alert = UIAlertController(title: "Alert", message:"Please enter your subject and comment message.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }else{
            postTopicWebservice()
//            self.performSegueWithIdentifier("unwindToRoomVCID", sender:nil)
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
    
    func richEditorToolbarInsertImage(toolbar: RichEditorToolbar) {
        ImagePicker.delegate = self
        ImagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
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
