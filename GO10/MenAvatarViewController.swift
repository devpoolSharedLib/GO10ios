//
//  MenAvatarViewController.swift
//  GO10
//
//  Created by devpool on 5/18/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData

class MenAvatarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var menCollection: UICollectionView!
    var avatarMan = ["man01", "man02", "man03", "man04", "man05", "man06", "man07", "man08", "man09", "man10", "man11", "man12", "man13", "man14"]
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.managedObjectContext;
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("ManAvatarVC viewDidDisappear")
        refreshCollectionView()
    }
    
    func refreshCollectionView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.menCollection.reloadData()
        })
    }

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatarMan.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("avatarCell", forIndexPath: indexPath)
        let imageAvatar = cell.viewWithTag(40) as! UIImageView
        imageAvatar.image = UIImage(named: avatarMan[indexPath.row])
        flagDeSelect()
        cell.layer.borderWidth = 0
        cell.layer.cornerRadius = 10
        return cell
        
    }

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        
        if cell!.layer.borderWidth != 0 {
            cell!.layer.borderWidth = 0
            flagDeSelect()
        } else {
            cell!.layer.borderWidth = 2.0
            cell!.layer.borderColor = UIColor.grayColor().CGColor
            flagSelect(indexPath)
        }
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        if cell != nil {
            cell!.layer.borderWidth = 0
        }
    }
    
    func flagDeSelect(){
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq);
            result[0].setValue(false, forKey: "avatarCheckSelect");
            try context.save();
            
        }catch{
            print("Error: Saving Data");
        }
    }

    func flagSelect(indexPath: NSIndexPath){
        do{
            let fetchReq = NSFetchRequest(entityName: "User_Info");
            let result = try context.executeFetchRequest(fetchReq);
            result[0].setValue(avatarMan[indexPath.row], forKey: "avatarPicTemp");
            result[0].setValue(true, forKey: "avatarCheckSelect");
            try context.save();
            
        }catch{
            print("Error: Saving Data");
        }
        
    }

}
