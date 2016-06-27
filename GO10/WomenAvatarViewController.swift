//
//  WomenAvatarViewController.swift
//  GO10
//
//  Created by devpool on 5/18/2559 BE.
//  Copyright © 2559 Gosoft. All rights reserved.
//

import UIKit
import CoreData


class WomenAvatarViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

    var avatarWoman = ["girl01", "girl02", "girl03", "girl04", "girl05", "girl06", "girl07", "girl08", "girl09", "girl10", "girl11", "girl12", "girl13", "girl14", "girl15", "girl16", "girl17"]
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    var context: NSManagedObjectContext!
    @IBOutlet weak var womanCollection: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        context = appDelegate.managedObjectContext;
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        print("WomanAvatarVC viewDidDisappear")
        refreshCollectionView()
    }

    func refreshCollectionView(){
        dispatch_async(dispatch_get_main_queue(), {
            self.womanCollection.reloadData()
        })
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.avatarWoman.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("avatarCell", forIndexPath: indexPath)
        let imageAvatar = cell.viewWithTag(41) as! UIImageView
        imageAvatar.image = UIImage(named: avatarWoman[indexPath.row])
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
            result[0].setValue(avatarWoman[indexPath.row], forKey: "avatarPicTemp");
            result[0].setValue(true, forKey: "avatarCheckSelect");
            try context.save();
            
        }catch{
            print("Error: Saving Data");
        }
    }
}
