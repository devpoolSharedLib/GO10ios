//
//  RulesViewController.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 9/27/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit

class RulesViewController: UIViewController {

    @IBOutlet weak var PoliciesTxtView: UITextView!
    var modelName: String!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        modelName = UIDevice.currentDevice().modelName
        
        PoliciesTxtView.font = FontModel.ipadminiHotTopicNameAvatar
        let linespace = NSMutableParagraphStyle()
        linespace.lineSpacing = 10
        var fontAtt = FontModel.iphonepainText
        
        if(modelName.rangeOfString("ipad Mini") != nil){
            fontAtt = FontModel.ipadminiPainText
        }else{
            fontAtt = FontModel.iphonepainText
        }
        
        let attributes = [NSParagraphStyleAttributeName : linespace,NSFontAttributeName: fontAtt!]

        
        PoliciesTxtView.attributedText = NSAttributedString(string: PoliciesTxtView.text, attributes:attributes)
        // Do any additional setup after loading the view.
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
