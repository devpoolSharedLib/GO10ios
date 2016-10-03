//
//  FontModel.swift
//  GO10
//
//  Created by Go10Application on 6/9/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import Foundation

class FontModel {
    

    
    let Headline  = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
    let Subheadline  = UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline)
    let body = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
    let footnote = UIFont.preferredFontForTextStyle(UIFontTextStyleFootnote)
    let caption = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption1)
    let caption2 = UIFont.preferredFontForTextStyle(UIFontTextStyleCaption2)
    
    
    static var ipadminiTopicName = UIFont(name:"Helvetica Neue", size:27)
    static var ipadminiPainText = UIFont(name:"Helvetica Neue", size:22)
    static var ipadminiHotTopicNameAvatar = UIFont(name:"Helvetica Neue", size:17)
    static var ipadminiDateTime = UIFont(name: "Helvetica Neue", size: 15)

//        static var iphoneTopicName = UIFont(name:"Helvetica Neue", size:UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline).pointSize)
//        static var iphonepainText = UIFont(name:"Helvetica Neue", size:UIFont.preferredFontForTextStyle(UIFontTextStyleBody).pointSize)
//        static var iphoneHotTopicNameAvatar = UIFont(name:"Helvetica Neue", size:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline).pointSize)
//        static var iphoneDateTime = UIFont(name: "Helvetica Neue", size:UIFont.preferredFontForTextStyle(UIFontTextStyleSubheadline).pointSize)
        
    static var iphoneTopicName = UIFont(name:"Helvetica Neue", size:21)
    static var iphonepainText = UIFont(name:"Helvetica Neue", size:17)
    static var iphoneHotTopicNameAvatar = UIFont(name:"Helvetica Neue", size:11)
    static var iphoneDateTime = UIFont(name: "Helvetica Neue", size: 9)
    
}
