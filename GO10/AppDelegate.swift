    //
//  Copyright (c) Google Inc.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
    
import Foundation
import UIKit
import CoreData
import Fabric
import Crashlytics
import IQKeyboardManagerSwift
import Siren
import OneSignal

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, NSURLSessionDelegate {
    var window: UIWindow?
    var signInType: String?
    var badgeCount: Int = 0
    var appId = PropertyUtil.getPropertyFromPlist("data",key: "OneSignal_appID")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var getbadgenumbernotificationUrl: String!
    var empEmail: String!
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    
    func application(application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        print("** App Delegate **)")
        application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        OneSignal.initWithLaunchOptions(launchOptions, appId: self.appId, handleNotificationReceived: { (notification) in
            print("Received Notification - \(notification.payload.notificationID)")
            }, handleNotificationAction: { (result) in
                
                // This block gets called when the user reacts to a notification received
                let payload = result.notification.payload
                let fullMessage = payload.title
                
                print("Title Notification : \(fullMessage) >>>>> Content Notification : \(payload.body  )" )
                
            }, settings: [kOSSettingsKeyAutoPrompt : false, kOSSettingsKeyInFocusDisplayOption : OSNotificationDisplayType.None.rawValue])
        
//        Fabric.with([Crashlytics.self])
        IQKeyboardManager.sharedManager().enable = true
        window?.makeKeyAndVisible()
        setupSiren()
        return true
        
    }
    
    
    func application(application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: NSError){
        print("One Signal")
        print("**************************** didFailToRegisterForRemoteNotificationsWithError")
        print(error)
    }
    
    func getBadgeNumberNotification() {
        print("\(NSDate().formattedISO8601) getBadgeNumberNotification empEmail : \(self.empEmail)")
        self.getbadgenumbernotificationUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/getbadgenumbernotification?"
        let urlWs = NSURL(string: "\(self.getbadgenumbernotificationUrl)empEmail=\(self.empEmail)")
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let request = NSMutableURLRequest(URL: urlWs!)
        request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
        let urlsession = NSURLSession.sharedSession()
        let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
            guard error == nil && data != nil else {
                print("\(NSDate().formattedISO8601) error=\(error)")
                return
            }
            
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 201 {
                print("\(NSDate().formattedISO8601) statusCode should be 201, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }else{
                let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
                self.badgeCount = Int(responseString as! String)!
                self.showBadgeNumber()
            }
//            completionHandler(UIBackgroundFetchResult.NoData)
        }
        requestSent.resume()

    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        print("xxxxxx didReceiveRemoteNotification xxxxxx")

        if (application.applicationState == UIApplicationState.Active) {
            print("******* State Active")
        }
        else {
            print("******* State Inactive")
            //        completionHandler(UIBackgroundFetchResult.NewData)
                    self.getValuefromUserInfo()
            //        self.getBadgeNumberNotification()
                    print("\(NSDate().formattedISO8601) getBadgeNumberNotification empEmail : \(self.empEmail)")
                    self.getbadgenumbernotificationUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)topic/getbadgenumbernotification?"
                    let urlWs = NSURL(string: "\(self.getbadgenumbernotificationUrl)empEmail=\(self.empEmail)")
                    print("\(NSDate().formattedISO8601) URL : \(urlWs)")
                    let request = NSMutableURLRequest(URL: urlWs!)
                    request.setValue("no-cache", forHTTPHeaderField: "Cache-Control")
                    let urlsession = NSURLSession.sharedSession()
                    let requestSent = urlsession.dataTaskWithRequest(request) { (data, response, error) in
                        guard error == nil && data != nil else {
                            print("\(NSDate().formattedISO8601) error=\(error)")
                            return
                        }
            
                        if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 201 {
                            print("\(NSDate().formattedISO8601) statusCode should be 201, but is \(httpStatus.statusCode)")
                            print("\(NSDate().formattedISO8601) response = \(response)")
                        }else{
                            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
                            print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
                            self.badgeCount = Int(responseString as! String)!
                            self.showBadgeNumber()
                        }
                            completionHandler(UIBackgroundFetchResult.NewData)
                    }
                    requestSent.resume()
        }
    }
    
    
    func showBadgeNumber()
    {
        print("badgeCount : \(self.badgeCount)")
        let application = UIApplication.sharedApplication()
//        application.registerUserNotificationSettings(UIUserNotificationSettings(forTypes: [.Badge, .Alert, .Sound], categories: nil))
        application.applicationIconBadgeNumber = self.badgeCount
    }
    
    func setupSiren() {
        let siren = Siren.sharedInstance
        siren.delegate = self
        siren.debugEnabled = true
        siren.majorUpdateAlertType = .Option
        siren.minorUpdateAlertType = .Option
        siren.patchUpdateAlertType = .Option
        siren.revisionUpdateAlertType = .Option
        siren.checkVersion(.Immediately)
    }
    
//    func applicationWillEnterForeground(application: UIApplication) {
//        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//        print(">>>>>>>>>>>>>>>>>>>>  : applicationWillEnterForeground")
//        Siren.sharedInstance.checkVersion(.Immediately)
//    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        print("applicationDidEnterBackground")
        self.badgeCount = 0
        showBadgeNumber()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print(">>>>>>>>>>>>>>>>>>>> applicationDidBecomeActive")
        Siren.sharedInstance.checkVersion(.Daily)
    }
    
    func applicationWillTerminate(application: UIApplication) {
        print(">>>>>>>>>>>>>>>>>>>> applicationWillTerminate")
        UIApplicationState.Inactive
        UIApplicationWillTerminateNotification
    }
        
    func getValuefromUserInfo(){
        
        do{
            let context = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
            let result = try context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            
            self.empEmail = result[0].valueForKey("empEmail") as! String
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
    // MARK: - Core Data stack
    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "co.th.gosoft.testCoreData" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("GO10", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
}
    extension AppDelegate: SirenDelegate
    {
        func sirenDidShowUpdateDialog(alertType: SirenAlertType) {
            print(#function, alertType)
        }
        
        func sirenUserDidCancel() {
            print(#function)
        }
        
        func sirenUserDidSkipVersion() {
            print(#function)
        }
        
        func sirenUserDidLaunchAppStore() {
            print(#function)
        }
        
        func sirenDidFailVersionCheck(error: NSError) {
            print(#function, error)
        }
        
        func sirenLatestVersionInstalled() {
            print(#function, "Latest version of app is installed")
        }
        
        /**
         This delegate method is only hit when alertType is initialized to .None
         */
        func sirenDidDetectNewVersionWithoutAlert(message: String) {
            print(#function, "\(message)")
        }
    }

