//
//  AboutPageViewController.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 6/16/2560 BE.
//  Copyright © 2560 Gosoft. All rights reserved.
//

import UIKit

class AboutPageViewController: UIViewController {

    @IBOutlet weak var appNameLbl: UILabel!
    @IBOutlet weak var versionNameLbl: UILabel!
    @IBOutlet weak var copyRightsTxtView: UITextView!
    @IBOutlet weak var gotoTermBtn: UIButton!
    
    var modelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let dictionary = NSBundle.mainBundle().infoDictionary!
        let version = dictionary["CFBundleShortVersionString"] as! String
        let build = dictionary["CFBundleVersion"] as! String
        print("version : \(version) build : \(build)")
        versionNameLbl.text = version
        modelName = UIDevice.currentDevice().modelName
        if(modelName.rangeOfString("ipad Mini") != nil){
            appNameLbl.font = UIFont(name:"Helvetica Neue", size:20)
            versionNameLbl.font = UIFont(name:"Helvetica Neue", size:17)
            copyRightsTxtView.font = UIFont(name:"Helvetica Neue", size:17)
            gotoTermBtn.titleLabel?.font = UIFont(name:"Helvetica Neue", size:17)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
