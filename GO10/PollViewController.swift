//
//  PollViewController.swift
//  GO10
//
//  Created by Jirapas Chiradechwiroj on 4/18/2560 BE.
//  Copyright © 2560 Gosoft. All rights reserved.
//

import UIKit
import CoreData

class PollViewController: UIViewController,UITableViewDataSource,UITableViewDelegate,UIScrollViewDelegate{

    @IBOutlet weak var pollTableView: UITableView!
    
    @IBOutlet var pollView: UIView!
    
    var context: NSManagedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
    var fetchReqUserInfo = NSFetchRequest(entityName: "User_Info")
    var domainUrl = PropertyUtil.getPropertyFromPlist("data",key: "urlDomainHttp")
    var versionServer = PropertyUtil.getPropertyFromPlist("data",key: "versionServer")
    var savePollUrl: String!
    
    var receivePollModel = [NSDictionary]()
    var questionMasterModel = [NSDictionary]()
    var choiceMasterModel = [NSDictionary]()
    var tempCheckSelected: Int!
    var selectedRows = [String:NSIndexPath]()
//    var selected: NSDictionary!
    var selected = [String:NSIndexPath]()
    var savePollModel = [String:NSDictionary]()
//    var savePollModel = [String:String]()
    var tempPoll = [String:String]()
    var pollId: String!
    var empEmail: String!
    var arrayPoll: String!
    var sendPoll: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("POLL VIEW CONTROLLER")
        print("POLL MODEL : \(self.receivePollModel)")
        
        self.savePollUrl = "\(self.domainUrl)GO10WebService/api/\(self.versionServer)poll/savePoll"
        
        self.questionMasterModel = self.receivePollModel[0].valueForKey("questionMaster") as! [NSDictionary]
        self.pollId = self.receivePollModel[0].valueForKey("_id") as! String

        self.pollTableView.estimatedSectionHeaderHeight = 50.0
        self.pollTableView.sectionHeaderHeight = UITableViewAutomaticDimension;
        
//        print("questionMasterModel : \(self.questionMasterModel)")
//        print("count of questionMasterModel : \(self.questionMasterModel.count)")
        
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        // Auto Scale Height
        self.getValuefromUserInfo()
//        self.pollTableView.sectionIndexBackgroundColor = UIColor.blueColor()
        self.pollTableView.rowHeight = UITableViewAutomaticDimension;
        self.pollTableView.estimatedRowHeight = 44.0; // set to whatever your "average" cell height is

//        fix bug auto scale
        self.pollView.setNeedsLayout()
        self.pollView.layoutIfNeeded()
        
        //set other button side back button
        self.navigationItem.leftItemsSupplementBackButton = true
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //refresh Table View
    func refreshTableView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.pollTableView.reloadData()
            print("\(NSDate().formattedISO8601)  REFRESHTABLE")
        })
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.questionMasterModel.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.choiceMasterModel = self.questionMasterModel[section].valueForKey("choiceMaster") as! [NSDictionary]
        print("count of choice model [\(section)] : \( self.choiceMasterModel.count) ")
        return self.choiceMasterModel.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        print("cellForRowAtIndexPath \(indexPath.section) : \(self.pollTableView.bounds.size.height)")
        let questionMasterBean = self.questionMasterModel[indexPath.section]
                print("\(indexPath.row) questionMasterBean : \(questionMasterBean)")
        
         let choiceMasterBean = questionMasterBean.valueForKey("choiceMaster") as! [NSDictionary]
        
        if(questionMasterBean.valueForKey("choiceMaster") != nil){
            cell = tableView.dequeueReusableCellWithIdentifier("choiceCell", forIndexPath: indexPath)
            let choiceTitleLbl = cell.viewWithTag(70) as! UILabel
            choiceTitleLbl.text = "\(indexPath.row+1). \((choiceMasterBean[indexPath.row].valueForKey("choiceTitle") as? String)!)"
            cell.contentView.backgroundColor = UIColor.clearColor()
            cell.accessoryType = .None
            
            let selectedIndexPath = selected["s\(indexPath.section)"];
            print("selectedIndexPath \(selectedIndexPath?.section) \(selectedIndexPath?.row)")
            if (indexPath == selectedIndexPath) {
                cell.contentView.backgroundColor = UIColor.redColor()
                cell.accessoryType = .Checkmark
            }else
            {
                cell.contentView.backgroundColor = UIColor.clearColor()
                cell.accessoryType = .None
            }

            
        }else{
            cell = tableView.dequeueReusableCellWithIdentifier("noCell", forIndexPath: indexPath)
            
        }
        return cell
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        print("viewForHeaderInSection \(section+1) : \(self.pollTableView.sectionHeaderHeight)")
        let questionMasterBean = self.questionMasterModel[section]

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5.0
        
        let myAttribute = [ NSFontAttributeName: UIFont(name:"Helvetica Neue", size:17)! ]
        let attrString = NSMutableAttributedString(string: "ข้อที่ \(section+1) \((questionMasterBean.valueForKey("questionTitle") as? String)!)", attributes: myAttribute)
        attrString.addAttribute(NSParagraphStyleAttributeName, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        
        let questionTitle = UITextView(frame: CGRectMake(0, 0, self.pollTableView.bounds.size.width,self.pollTableView.sectionHeaderHeight))

        questionTitle.backgroundColor = UIColor.lightGrayColor()
        questionTitle.textAlignment = .Left
        questionTitle.sizeToFit()
        questionTitle.scrollEnabled = false
        questionTitle.font = UIFont(name:"Helvetica Neue", size:17)
        questionTitle.textContainerInset = UIEdgeInsetsMake(10,10, 10, 10) //top left bottom right
        questionTitle.attributedText  = attrString
        return questionTitle
    }
    
//    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let questionMasterBean = self.questionMasterModel[section]
//        return questionMasterBean.valueForKey("questionTitle") as? String
//    }
    
    func addSelectedCellWithSection(indexPath:NSIndexPath) ->NSIndexPath?
    {
        let existingIndexPath = selectedRows["\(indexPath.section)"];
        if (existingIndexPath == nil) {
            selectedRows["\(indexPath.section)"]=indexPath;
        }else
        {
            selectedRows["\(indexPath.section)"]=indexPath;
            return existingIndexPath
        }
        
        return nil;
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)!
        let previusSelectedCellIndexPath = self.addSelectedCellWithSection(indexPath);
        print("didSelectRowAtIndexPath")
        
        if(previusSelectedCellIndexPath != nil)
        {
            print("previusSelectedCellIndexPath --> section :  \(previusSelectedCellIndexPath?.section) row : \(previusSelectedCellIndexPath?.row)" )
            if(previusSelectedCellIndexPath != indexPath){
                selected["s\(indexPath.section)"]=indexPath;
                print("previusSelectedCellIndexPath != indexPath")
                let previusSelectedCell = tableView.cellForRowAtIndexPath(previusSelectedCellIndexPath!)
                previusSelectedCell!.contentView.backgroundColor = UIColor.clearColor()
                previusSelectedCell?.accessoryType = .None
                previusSelectedCell!.userInteractionEnabled = true
                
                cell.contentView.backgroundColor = UIColor.redColor()
                tableView.deselectRowAtIndexPath(previusSelectedCellIndexPath!, animated: true);
                cell.accessoryType = .Checkmark
                
            }else{
                print("previusSelectedCellIndexPath == indexPath")
                //set if press same selection cell
                cell.userInteractionEnabled = false
            }
        }
        else
        {
            //set for reuse cell in tableviewcell
            selected["s\(indexPath.section)"]=indexPath;
            cell.contentView.backgroundColor = UIColor.redColor()
            cell.accessoryType = .Checkmark
        }
        
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

//    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        print("heightForHeaderInSection \(section) : \(UITableViewAutomaticDimension)")
//        return UITableViewAutomaticDimension
//    }
//
//    func tableView(tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
//        return UITableViewAutomaticDimension
//    }
    
    @IBAction func savePollBtn(sender: AnyObject) {
        self.sendPoll = ""
        self.sendPoll = "["
        for index in 0...(self.questionMasterModel.count)-1{
            if(selected["s\(index)"] == nil){
                NSOperationQueue.mainQueue().addOperationWithBlock {
                    let alert = UIAlertController(title: "Alert", message: "Please enter questoin \(index+1).", preferredStyle: UIAlertControllerStyle.Alert)
                    alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
                    self.presentViewController(alert, animated: true, completion: nil)
                }
                break
            }
            
            self.sendPoll = self.sendPoll + "{\"empEmail\": \"\(self.empEmail)\", \"choiceKey\": \"q\((selected["s\(index)"]?.section)!+1)c\((selected["s\(index)"]?.row)!+1)\", \"pollId\": \"\(self.pollId)\", \"questionId\": \"q\(index+1)\", \"type\": \"choice\"}"
            
            if(index != (self.questionMasterModel.count)-1){
                self.sendPoll = self.sendPoll + ","
            }
        }
        self.sendPoll = self.sendPoll + "]"
        print("list Poll to save\(self.sendPoll)")
        savePollWebservice(self.sendPoll)
    }
    
    func savePollWebservice(pollStr:String){
        print("\(NSDate().formattedISO8601) savePollWebservice")
        let urlWs = NSURL(string: self.savePollUrl)
        print("\(NSDate().formattedISO8601) URL : \(urlWs)")
        let requestPost = NSMutableURLRequest(URL: urlWs!)
        
        requestPost.HTTPBody = pollStr.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
        requestPost.setValue("application/json", forHTTPHeaderField: "Content-Type")
        requestPost.setValue("application/json",forHTTPHeaderField: "Accept")
        requestPost.HTTPMethod = "POST"
        let urlsession = NSURLSession.sharedSession()
        let request = urlsession.dataTaskWithRequest(requestPost) { (data, response, error) in
            guard error == nil && data != nil else {
                print("\(NSDate().formattedISO8601) error=\(error)")
                return
            }
            if let httpStatus = response as? NSHTTPURLResponse where httpStatus.statusCode != 200 {
                print("\(NSDate().formattedISO8601) statusCode should be 200, but is \(httpStatus.statusCode)")
                print("\(NSDate().formattedISO8601) response = \(response)")
            }
            let responseString = NSString(data: data!, encoding: NSUTF8StringEncoding)
            print("\(NSDate().formattedISO8601) responseString = \(responseString!)")
            dispatch_async(dispatch_get_main_queue(), {
                self.performSegueWithIdentifier("unwindToBoardVCID", sender:nil)
            })
        }
        request.resume()
    }
    
    func getValuefromUserInfo(){
        do{
            let result = try self.context.executeFetchRequest(self.fetchReqUserInfo) as! [NSManagedObject]
            
            self.empEmail = result[0].valueForKey("empEmail") as! String
        }catch{
            print("\(NSDate().formattedISO8601) Error Reading Data")
        }
    }
    
}
