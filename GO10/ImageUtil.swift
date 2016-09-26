//
//  ResizeImageUtil.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 9/23/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import Foundation
import Toucan

class ImageUtil{
    
    class func resizeImage(inputImg: UIImage,modelName: String) -> UIImage{
        print("\(NSDate().formattedISO8601) model Name Upload : \(modelName)")
        //Resize image
        print("\(NSDate().formattedISO8601) size image before resize : \(inputImg.size)")
        let databe = UIImagePNGRepresentation(inputImg)
        print("\(NSDate().formattedISO8601) Byte Img before resize : \(databe?.length)")
        
        var resizeWidth: Double
        var reizeHeight: Double
        let maxsize = 300 * 1024
        
        if(modelName == "iPhone 6s Plus" || modelName == "iPhone 6 Plus" || modelName == "Simulator"){
            print("6plusUpload")
            resizeWidth = 100
            reizeHeight = 100
        }else{
            print("6Upload")
            resizeWidth = 200
            reizeHeight = 200
        }
        
        //        browseImg = Toucan(image: browseImg!).resize(CGSize(width: resizeWidth, height: reizeHeight), fitMode: Toucan.Resize.FitMode.Clip).image
        //
        //        print("\(NSDate().formattedISO8601) size image after resize : \(browseImg?.size)")
        //        var dataaf = UIImagePNGRepresentation(browseImg!)
        //        print("\(NSDate().formattedISO8601) Byte Img after resize : \(dataaf?.length)")
        
        var dataImage: NSData
        var resizeImg: UIImage
        
        repeat{
            resizeImg = Toucan(image: inputImg).resize(CGSize(width: resizeWidth, height: reizeHeight), fitMode: Toucan.Resize.FitMode.Clip).image
            dataImage = UIImagePNGRepresentation(resizeImg)!
            resizeWidth = resizeWidth * 0.9
            reizeHeight = reizeHeight * 0.9
            print("\(NSDate().formattedISO8601) size image after resize : \(resizeImg.size)")
            print("\(NSDate().formattedISO8601) Byte Img after resize : \(dataImage.length)")
        }while dataImage.length > maxsize
        return resizeImg
    }
    
    class func setSizeToSrc(objImage: UIImage) -> NSDictionary{
    
        let width = objImage.size.width
        let height = objImage.size.height
        let ratio = round(width/height*100)/100
        var resultLength: NSDictionary!
        print(">>>>>>> RATIO : \(ratio)")
        
        
        if(ratio > 1) {
            if(ratio == 1.33) {
                print("4:3 landscape")
                resultLength.setValue(295, forKey: "width")
                resultLength.setValue(222, forKey: "height")
            } else if(ratio == 1.78 || ratio == 1.77) {
                print("16:9 landscape")
                resultLength.setValue(295, forKey: "width")
                resultLength.setValue(166, forKey: "height")
            } else {
                print("Other Resulotion landscape")
                resultLength.setValue(295, forKey: "width")
                resultLength.setValue(166, forKey: "height")
            }
        } else if(ratio < 1) {
            if(ratio == 0.75) {
                print("3:4 portrait")
                resultLength.setValue(230, forKey: "width")
                resultLength.setValue(307, forKey: "height")
                print("aoisdfoadfsksakjdfbkajdfsbaljks")

            } else if(ratio == 0.56) {
                print("9:16 portrait")
                resultLength.setValue(230, forKey: "width")
                resultLength.setValue(410, forKey: "height")
            } else {
                print("Other Resulotion protrait")
                resultLength.setValue(230, forKey: "width")
                resultLength.setValue(410, forKey: "height")
            }
        } else if(ratio == 1) {
            print("1:1 square")
            resultLength.setValue(295, forKey: "width")
            resultLength.setValue(295, forKey: "height")
        }
        
        
        return resultLength
    }
    
}
