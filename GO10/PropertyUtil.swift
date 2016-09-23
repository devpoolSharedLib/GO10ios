//
//  PropertyUtil.swift
//  GO10
//
//  Created by Go10Application on 9/21/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import Foundation

class PropertyUtil{
    
    class func getPropertyFromPlist(namePlist:String,key:String) -> String {
        let path = NSBundle.mainBundle().pathForResource(namePlist, ofType: "plist")
        let dict = NSDictionary(contentsOfFile:path!)
        return dict![key] as! String
    }
    
}
