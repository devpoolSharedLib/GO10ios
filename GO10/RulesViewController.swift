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
        PoliciesTxtView.font = FontUtil.ipadminiHotTopicNameAvatar
        let linespace = NSMutableParagraphStyle()
        linespace.lineSpacing = 10
        var fontAtt = FontUtil.iphonepainText
        if(modelName.rangeOfString("ipad Mini") != nil){
            fontAtt = FontUtil.ipadminiPainText
        }else{
            fontAtt = FontUtil.iphonepainText
        }
        let attributes = [NSParagraphStyleAttributeName : linespace,NSFontAttributeName: fontAtt!]
        PoliciesTxtView.attributedText = NSAttributedString(string: PoliciesTxtView.text, attributes:attributes)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

  }
