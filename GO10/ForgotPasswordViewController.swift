//
//  ForgotPasswordViewController.swift
//  GO10
//
//  Created by Go10Application on 7/25/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import Foundation
import MRProgress

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet var forgotView: UIView!
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    @IBOutlet weak var sendEmailBtn: UIButton!
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttps")
    var pathUserService = PropertyUtil.getPropertyFromPlist("data",key: "pathUserService")
    var resetPasswordByEmailUrl: String!

    override func viewDidLoad() {
        super.viewDidLoad()
        print("*** ForgotPasswordVC ViewDidLoad ***")
        self.resetPasswordByEmailUrl = "\(self.domainUrl)\(self.pathUserService)/resetPasswordByEmail?email="
        self.sendEmailBtn.layer.cornerRadius = 5
    }

    @IBAction func sendEmail(sender: AnyObject) {
        let email = self.emailTxtField.text
        print("E-MAIL : \(email)")
        if((email == "") || checkSpace(email!)) {
            NSOperationQueue.mainQueue().addOperationWithBlock {
                let alert = UIAlertController(title: "Alert", message: "Please enter your E-mail.", preferredStyle: UIAlertControllerStyle.Alert)
                alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }else{
            MRProgressOverlayView.showOverlayAddedTo(self.forgotView, title: "Processing", mode: MRProgressOverlayViewMode.Indeterminate, animated: true)
            self.resetPassword(email!)
        }
    }
    
    func resetPassword(email: String){
        print("\(NSDate().formattedISO8601) getResetPasswordWebservice")
        let url = resetPasswordByEmailUrl + email
        let strUrlEncode = url.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLFragmentAllowedCharacterSet())
        let urlWs = NSURL(string: strUrlEncode!)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")

        let req = NSMutableURLRequest(URL: urlWs!)
        req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        let request = NSURLSession.sharedSession().dataTaskWithRequest(req) { (data, response, error) in
            do{
                let dataString = String(data: data!, encoding: NSUTF8StringEncoding)
                print("\(NSDate().formattedISO8601) response : \(dataString)")
                print("----------- \(response)")
                let httpURLResponse = response as? NSHTTPURLResponse
                print("----------- \(httpURLResponse!.statusCode)")
                if(dataString == "User does not exist on the system."){
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        let alert = UIAlertController(title: "Alert", message: "User does not exist on the system.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                        MRProgressOverlayView.dismissOverlayForView(self.forgotView, animated: true)
                    }
                }else{
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        MRProgressOverlayView.dismissOverlayForView(self.forgotView, animated: true)
                        let alert = UIAlertController(title: "Alert", message: "You can check e-mail for reset password.", preferredStyle: UIAlertControllerStyle.Alert)
                        alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                        self.presentViewController(alert, animated: true, completion: nil)
                    }
                    NSOperationQueue.mainQueue().addOperationWithBlock {
                        self.emailTxtField.text = ""
                        self.gotoLoginPage()
                    }
                }
            }catch let error as NSError{
                print("\(NSDate().formattedISO8601) error : \(error.localizedDescription)")
            }
        }
        request.resume()
    }

    func gotoLoginPage(){
        print("gotoLoginPage")
            self.performSegueWithIdentifier("gotoLoginPage", sender: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
