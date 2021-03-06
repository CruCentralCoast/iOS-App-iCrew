//
//  InvolvedGroupsTVC.swift
//  CruApp
//
//  Created by Daniel Lee on 2/29/16.
//  Copyright © 2016 iCrew. All rights reserved.
//

import UIKit

class InvolvedGroupsTVC: UITableViewController {
    var savedCGs = [CommunityGroupData]()
    var savedMinistryTeams = [MinistryTeamData]()
    var combinedGroups = [[CombinedObject]]()
    var involvedGroupIds = [String]()
    var totalGroups = 0
    let padding = "   "
    
    @IBOutlet weak var editButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        savedCGs = UserProfile.getCommunityGroups()
        savedMinistryTeams = UserProfile.getMinistryTeams()
        combinedGroups = Array(count: 2, repeatedValue: [CombinedObject]())
        combineGroups()
        
        //remove extra separators
        self.tableView.tableFooterView = UIView()
        
        //set empty back button
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
    }
    
    func combineGroups() {
        for cg in savedCGs {
            if !involvedGroupIds.contains(cg.id) {
                combinedGroups[0].append(CombinedObject(cg: cg))
            }
            involvedGroupIds.append(cg.id)
        }
        for ministryTeam in savedMinistryTeams {
            if !involvedGroupIds.contains(ministryTeam.id) {
                combinedGroups[1].append(CombinedObject(ministryTeam: ministryTeam))
            }
            involvedGroupIds.append(ministryTeam.id)
        }
        
        self.editButton.enabled = involvedGroupIds.count != 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 2 //
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return combinedGroups[section].count
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "Community Groups" : "Ministry Teams"
    }
    
    override func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if (combinedGroups[section].count == 0) {
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.tableView.bounds.size.width, height: 100))
            label.text = section == 0 ? padding + "No community groups yet" : padding + "No ministry teams yet"
            label.sizeToFit()
            
            return label
        }
        return UIView()
    }
    
    // Uncomment
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MinistryTeamDataCell", forIndexPath: indexPath) as! MinistryTeamDataCell
        
        print("got here")
        
        let group = combinedGroups[indexPath.section][indexPath.row]
        
        if (group.ministryTeam != nil) {
            cell.nameLabel.text = group.ministryTeam!.name
            cell.locationLabel.text = UserProfile.getMinistryNameFromID(group.ministryTeam!.parentMinistry)
        }
        else {
            // TODO: Fix date
            //            let dateFormatter = NSDateFormatter()
            //            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            //            let date = dateFormatter.dateFromString((group.communityGroup?.time)!)
            //            dateFormatter.dateFormat = "eeee, h:mm a"
            
            cell.nameLabel.text = group.communityGroup?.name
            cell.locationLabel.text = (group.communityGroup?.time)!
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = UILabel()

        
        if (section == 0) {
            label.backgroundColor = UIColor(red: 249/255, green: 182/255, blue: 37/255, alpha: 1.0)
            label.text = padding + "Community Groups"
        }
        else {
            label.backgroundColor = UIColor(red: 221/255, green: 125/255, blue: 27/255, alpha: 1.0)
            label.text = padding + "Ministry Teams"
        }
        
        label.backgroundColor = label.backgroundColor?.colorWithAlphaComponent(1.0)
        label.textColor = UIColor.whiteColor()
        label.font = UIFont.boldSystemFontOfSize(15)
        
        return label
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        let cell:UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if (self.tableView.editing) {
            return UITableViewCellEditingStyle.Delete;
        }
        
        return UITableViewCellEditingStyle.None;
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == UITableViewCellEditingStyle.Delete) {
            combinedGroups[indexPath.section].removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
        }
    }
    
    @IBAction func editPressed(sender: AnyObject) {
        if (self.tableView.editing) {
            editButton.title = "Edit"
            self.tableView.setEditing(false, animated: true)
        } else {
            editButton.title = "Done"
            self.tableView.setEditing(true, animated: true)
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if (involvedGroupIds.count != combinedGroups[0].count + combinedGroups[1].count) {
            let arr = Array(combinedGroups.flatten())
            UserProfile.refreshInvolvedGroups(arr)
        }
    }
}
