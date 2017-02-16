//
//  GetBadgeNumberUtil.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 2/10/2560 BE.
//  Copyright © 2560 Gosoft. All rights reserved.
//

import Foundation

class GetBadgeNumberUtil {
    class
        func getBadgeNumberNotification(){
        
        print("\(NSDate().formattedISO8601) getBadgeNumberNotification")
        let getbadgenumbernotificationUrl = "http://go10webservice.au-syd.mybluemix.net/GO10WebService/api/v116103/topic/getbadgenumbernotification?"
        let urlWs = NSURL(string: "\(getbadgenumbernotificationUrl)empEmail=jirapaschi@gosoft.co.th")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        
                let request = NSURLRequest(URL: urlWs!)
                NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue()) {(response, data, error) in
                    print("aslkdfjlsdflksdajflksalkdajsf")
                    print(NSString(data: data!, encoding: NSUTF8StringEncoding))
                }
        
//        let request = NSMutableURLRequest(URL: urlWs!)
//        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
//        
//        let configuration = NSURLSessionConfiguration.backgroundSessionConfigurationWithIdentifier("com.newrelic.bgt")
//        configuration.discretionary = true
//        
//        let backgroundSession = NSURLSession(configuration: configuration, delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        
        //        let config = NSURLSessionConfiguration.defaultSessionConfiguration()
        //        let session = NSURLSession(configuration: config, delegate: nil, delegateQueue: nil)
        
//        let urlsession = NSURLSession.sharedSession()
//        print("xxxxxxx")
//        let requestSent = backgroundSession.dataTaskWithRequest(request) { (data, response, error) in
//            guard error == nil && data != nil else {
//                print("\(NSDate().formattedISO8601) error=\(error)")
//                return
//            }
//            
//            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
//                print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("\(NSDate().formattedISO8601) response = \(response)")
//            }
//            print("12345678901234567890123456789012345678901234567890")
//            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
//            print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
//            //            self.startDate = responseString as! String
//            //            self.setStartDateToCoreDate()
//        }
//        requestSent.resume()
    }

}