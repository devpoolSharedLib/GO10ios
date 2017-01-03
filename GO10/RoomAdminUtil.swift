//
//  RoomAdminUtil.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 12/31/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import Foundation

class RoomAdminUtil{
    class func checkAccess(userArray: Array<String>,empEmail: String ) -> BooleanType{
        if userArray.contains("all") {
//            print("Find All")
            return true
        }else if userArray.contains(empEmail) {
//            print("Find User in Array")
            return true
        }else{
//            print("not Find Post User")
            return false
            
        }
    }
    
    
    
}