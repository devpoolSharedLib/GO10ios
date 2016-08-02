//
//  ForgotPasswordViewController.swift
//  GO10
//
//  Created by Go10Application on 7/25/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit

class ForgotPasswordViewController: UIViewController {

    
    @IBOutlet weak var emailLbl: UILabel!
    @IBOutlet weak var emailTxtField: UITextField!
    
    @IBOutlet weak var sendEmailBtn: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sendEmailBtn.layer.cornerRadius = 5
        // Do any additional setup after loading the view.
    }


    @IBAction func sendEmail(sender: AnyObject) {
        let email = self.emailTxtField.text
        
        print("E-MAIL : \(email)")
        
        if((email == "") || checkSpace(email!)) {
            let alert = UIAlertController(title: "Alert", message: "Please enter your E-mail and Password.", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        }
        
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
