//
//  AboutPageViewController.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 6/16/2560 BE.
//  Copyright © 2560 Gosoft. All rights reserved.
//

import UIKit

class AboutPageViewController: UIViewController {

    @IBOutlet weak var aboutTxtView: UITextView!
    
    var modelName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        modelName = UIDevice.currentDevice().modelName
        aboutTxtView.font = FontUtil.ipadminiHotTopicNameAvatar
        let linespace = NSMutableParagraphStyle()
        linespace.lineSpacing = 10
        var fontAtt = FontUtil.iphonepainText
        if(modelName.rangeOfString("ipad Mini") != nil){
            fontAtt = FontUtil.ipadminiPainText
        }else{
            fontAtt = FontUtil.iphonepainText
        }
        let attributes = [NSParagraphStyleAttributeName : linespace,NSFontAttributeName: fontAtt!]
        aboutTxtView.attributedText = NSAttributedString(string: aboutTxtView.text, attributes:attributes)
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
