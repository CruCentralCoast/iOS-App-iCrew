//
//  RideShareStatusTableViewController.swift
//  CruApp
//
//  Created by Tammy Kong on 2/25/16.
//  Copyright © 2016 iCrew. All rights reserved.
//

import UIKit
import SwiftLoader
import DZNEmptyDataSet


let kDriverHeader = "You will be a driver for..."
let kPassengerHeader = "You will be a passenger for..."

class RideShareStatusTableViewController: UITableViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    var eventNames = [String]()
    var eventIds = [String]()
    
    /* Header titles, can be changed if needed */
    let headerTitles = [kDriverHeader, kPassengerHeader]
    
    /* Arrays used to hold each section of user's rideshare data */
    var driverCollection = [Driver]()
    var passengerCollection = [Passenger]()
    var passengersData = [Passenger]()
    var tableData = [[AnyObject]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .None
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        // Replaces the extra cells at the end with a clear view
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Gets the orders from Firebase
        self.fetchStatuses()
        
        tableView.separatorStyle = .SingleLine
    }
    
    func fetchStatuses() {
        SwiftLoader.show(title: "Loading...", animated: true)
        driverCollection = [Driver]()
        passengerCollection = [Passenger]()
        tableData = [[AnyObject]]()
        DBClient.getData("events", dict: setEvents)
    }
    
    // Obtain event information from the database to an Object
    func setEvents(events: NSArray) {
        for event in events {
            let name = event["name"] as! String
            let id = event["_id"] as! String
            self.eventNames.append(name)
            self.eventIds.append(id)
        }
        DBClient.getData("passengers", dict: setPassenger)
        
    }
    
    func setPassenger(passengers:NSArray){
        for passenger in passengers {
            let passengerId = passenger["_id"] as! String
            let gcmId = passenger["gcm_id"] as! String
            let phoneNumber = passenger["phone"] as! String
            let name = passenger["name"] as! String
            
            let passengerObj = Passenger(passengerId:passengerId, gcmId:gcmId, phoneNumber:phoneNumber, name:name)
            passengersData.append(passengerObj)
        }
        DBClient.getData("rides", dict: setRides)
    }
    
    func setRides(rides:NSArray) {
        for ride in rides {
            let gcmId = ride["gcm_id"] as! String
            let rideId = ride["_id"] as! String
            let event = ride["event"] as! String
            let driverNumber = ride["driverNumber"] as! String
            let driverName = ride["driverName"] as! String
            let time = ride["time"] as! String
            let passengers = ride["passengers"] as! [String]
            let availableSeats = (ride["seats"] as! Int) - (passengers.count)
            var passengersInfo = [Passenger]()
            
            var direction = ""
            var street = ""
            var city = ""
            var zipcode = ""
            var suburb = ""
            var state = ""
            var country = ""
            
            if(ride["direction"]! != nil) {
                direction = ride["direction"] as! String
            }
            
            if(ride["location"]?!.objectForKey("postcode") != nil && !(ride["location"]?!.objectForKey("postcode") is NSNull)) {
                zipcode = ride["location"]?!.objectForKey("postcode") as! String
            }
            
            if(ride["location"]?!.objectForKey("state") != nil && !(ride["location"]?!.objectForKey("state") is NSNull)) {
                state = ride["location"]?!.objectForKey("state") as! String
            }
            
            if(ride["location"]?!.objectForKey("suburb") != nil && !(ride["location"]?!.objectForKey("suburb") is NSNull)) {
                city = ride["location"]?!.objectForKey("suburb") as! String
            }
            
            if(ride["location"]?!.objectForKey("street1") != nil && !(ride["location"]?!.objectForKey("street1") is NSNull)) {
                street = ride["location"]?!.objectForKey("street1") as! String
            }
            
            if(ride["location"]?!.objectForKey("country") != nil && !(ride["location"]?!.objectForKey("country") is NSNull)) {
                country = ride["location"]?!.objectForKey("country") as! String
            }
            
            let location2 = city + ", " + state + ", " + country + " " + zipcode
            
            
            for pssngr in passengers{
                for data in passengersData {
                    if data.passengerId == pssngr {
                        passengersInfo.append(data)
                        
                        //if user is a passenger
                        if(gcm_id == data.gcmId) {
//                            let passengerObj = Passenger(rideId:rideId, passengerId:pssngr, eventId:event, departureTime:time, departureLoc1: street, departureLoc2: location2, driverNumber:driverNumber, driverName:driverName)
//                            passengerCollection.append(passengerObj)
                        }
                    }
                }
            }
            
            //if user is a driver
            if(gcm_id == gcmId) {
//                let rideObj = Driver(rideId:rideId, eventId:event, departureTime:time, departureLoc1:street, departureLoc2:location2, availableSeats:availableSeats, passengers:passengersInfo)
//                driverCollection.append(rideObj)
            }
        }
        
        self.tableData = [self.driverCollection, self.passengerCollection]
        SwiftLoader.hide()
        
        // Sets up the controller to display notification screen if no ridesharing can be accessed
        self.tableView.emptyDataSetSource = self;
        self.tableView.emptyDataSetDelegate = self;
        
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return tableData.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numCellsInSection = tableData[section].count
        
        if (numCellsInSection == 0) {
            return 1
        }
        
        return numCellsInSection
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        var cell = UITableViewCell()
        
        switch (headerTitles[indexPath.section]) {
        case kDriverHeader:
            if (self.driverCollection.count > 0) {
                cell = tableView.dequeueReusableCellWithIdentifier("DriverCell")!
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("NoDataCell")!
            }
            break
        case kPassengerHeader:
            if (self.passengerCollection.count > 0) {
                cell = tableView.dequeueReusableCellWithIdentifier("PassengerCell")!
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("NoDataCell")!
            }
            break
        default:
            break
        }
        return cell.contentView.bounds.size.height
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section < headerTitles.count {
            return headerTitles[section]
        }
        
        return nil
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch(headerTitles[indexPath.section]) {
        case kDriverHeader:
            let alert = UIAlertView()
            alert.delegate = self
            alert.title = "Passengers"
            let driver = driverCollection[indexPath.row] as Driver
            
            if (driver.passengers.count != 0) {
                var msg = ""
                
                for index in 0...(driver.passengers.count - 1) {
                    
                    var number = String(driver.passengers[index].phoneNumber)
                    number = number.insert("(", ind: 0)
                    number = number.insert(") ", ind: 4)
                    number = number.insert(" - ", ind: 9)
                    
                    msg += driver.passengers[index].name + " " + number + "\n"
                }
                alert.message = msg
            } else {
                alert.message = "No passengers at this time."
            }
            alert.addButtonWithTitle("OK")
            alert.show()
            break
            
        default:
            break
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        var cell = UITableViewCell()
        
        switch (headerTitles[indexPath.section]) {
        case kDriverHeader:
            if (self.driverCollection.count > 0) {
                cell = tableView.dequeueReusableCellWithIdentifier("DriverCell", forIndexPath: indexPath)
                populateDriverCell(indexPath, cell: (cell as! DriverStatusTableViewCell))
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("NoDataCell", forIndexPath: indexPath)
            }
            break
        case kPassengerHeader:
            if (self.passengerCollection.count > 0) {
                cell = tableView.dequeueReusableCellWithIdentifier("PassengerCell", forIndexPath: indexPath)
                populatePassengerCell(indexPath, cell: (cell as! PassengerStatusTableViewCell))
            } else {
                cell = tableView.dequeueReusableCellWithIdentifier("NoDataCell", forIndexPath: indexPath)
            }
            break
        default:
            break
        }
        
        return cell
    }
    
    /* Helper function for filling in driver cell with its information */
    func populateDriverCell(indexPath: NSIndexPath, cell: DriverStatusTableViewCell) {
        cell.tableController = self
        
        let driver = driverCollection[indexPath.row]
        
        for index in 0...(eventIds.count - 1) {
            if(eventIds[index] == driver.eventId) {
                cell.eventName.text = eventNames[index]
                cell.eventName.font = UIFont.boldSystemFontOfSize(20)
                break
            }
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.dateFromString(driver.departureTime)
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        cell.departureTime.text = "Departure on " + dateFormatter.stringFromDate(date!)
        cell.departureLoc1.text = driver.departureLoc1
        cell.departureLoc2.text = driver.departureLoc2
        
        cell.availableSeats.text = String(driver.availableSeats) + " available seats left"
    }
    
    /* Callback for when a cancel button is pressed in a driver cell. Input is the row of the cell at which it's pressed */
    func cancelDriver(row: Int) {
        let titleMsg = "Are you sure?"
        let msg = "Are you sure you want to cancel your ride offering?"
        
        let confirmDialog = UIAlertController(title: titleMsg, message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Confirm", style: .Default) { (UIAlertAction) -> Void in
            
            let rideId = self.driverCollection[row].rideId;
            DBClient.deleteData("rides/" + rideId)
            
            
            for pssngr in self.passengerCollection {
                if (pssngr.rideId == self.driverCollection[row].rideId) {
                    self.passengerCollection.removeAtIndex(row)
                }
            }
            
            self.driverCollection.removeAtIndex(row)
            
            
            self.tableData = [self.driverCollection, self.passengerCollection]
            
            self.tableView.reloadData()
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        confirmDialog.addAction(okAction)
        confirmDialog.addAction(cancelAction)
        
        self.presentViewController(confirmDialog, animated: true, completion: nil)
    }
    
    /* Helper function for filling in passenger cell with its information */
    func populatePassengerCell(indexPath: NSIndexPath, cell: PassengerStatusTableViewCell) {
        cell.tableController = self
        
        let passenger = passengerCollection[indexPath.row]
        
        
        for index in 0...(eventIds.count - 1) {
            if(eventIds[index] == passenger.eventId) {
                cell.eventName.text = eventNames[index]
                cell.eventName.font = UIFont.boldSystemFontOfSize(20)
                break
            }
        }
        
        cell.driverName.text = passenger.driverName
        
        var number = String(passenger.driverNumber)
        
        number = number.insert("(", ind: 0)
        number = number.insert(") ", ind: 4)
        number = number.insert(" - ", ind: 9)
        cell.driverNumber.text = number
        
        cell.departureLoc1.text = passenger.departureLoc1
        cell.departureLoc2.text = passenger.departureLoc2
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let date = dateFormatter.dateFromString(passenger.departureTime)
        dateFormatter.dateStyle = NSDateFormatterStyle.ShortStyle
        dateFormatter.timeStyle = .ShortStyle
        cell.departureTime.text = "Departing on " + dateFormatter.stringFromDate(date!)
        
    }
    
    /* Callback for when a cancel button is pressed in a passenger cell. Input is the row of the cell at which it's pressed */
    func cancelPassenger(row: Int) {
        let titleMsg = "Are you sure?"
        let msg = "Are you sure you want to cancel your spot in the ride?"
        
        let confirmDialog = UIAlertController(title: titleMsg, message: msg, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "Confirm", style: .Default) { (UIAlertAction) -> Void in
            //            let params = ["ride_id": self.passengerCollection[row].rideId, "passenger_id": self.passengerCollection[row].passengerId]
            let rideId = self.passengerCollection[row].rideId
            let passengerId = self.passengerCollection[row].passengerId
            //            do {
            //                let body = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            //                DBClient.deleteData("rides/dropPassenger", body:body)
            
            DBClient.deleteData("rides/" + rideId + "/passengers/" + passengerId)
            self.passengerCollection.removeAtIndex(row)
            self.tableData = [self.driverCollection, self.passengerCollection]
            
            
            self.tableView.reloadData()
            //
            //            } catch {
            //                print("Error sending data to database")
            //            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        
        confirmDialog.addAction(okAction)
        confirmDialog.addAction(cancelAction)
        
        self.presentViewController(confirmDialog, animated: true, completion: nil)
    }
    
    
    @IBAction func addButtonPressed(sender: UIBarButtonItem) {
        
        //Create the AlertController
        let actionSheetController: UIAlertController = UIAlertController(title: "Choose an option", message: "What would you like to do?", preferredStyle: .ActionSheet)
        
        //Create and add the Cancel action
        let cancelAction: UIAlertAction = UIAlertAction(title: "Cancel", style: .Cancel) { action -> Void in
            //Just dismiss the action sheet
        }
        actionSheetController.addAction(cancelAction)
        
        //Create and add first option action
        let offerRideAction: UIAlertAction = UIAlertAction(title: "Offer a ride", style: .Default)
        { action -> Void in
            self.performSegueWithIdentifier("toDriverQ", sender: self)
        }
        actionSheetController.addAction(offerRideAction)
        
        //Create and add a second option action
        let requestRideAction: UIAlertAction = UIAlertAction(title: "Request a ride", style: .Default)
        { action -> Void in
            self.performSegueWithIdentifier("toRiderQ", sender: self)
            
        }
        actionSheetController.addAction(requestRideAction)
        
        //We need to provide a popover sourceView when using it on iPad
        //            actionSheetController.popoverPresentationController?.sourceView = sender as UIView
        
        //Present the AlertController
        self.presentViewController(actionSheetController, animated: true, completion: nil)
        
    }
    
    func titleForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Ride Share can't be loaded."
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    func descriptionForEmptyDataSet(scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Please make sure you have internet connectivity."
        let attrs = [NSFontAttributeName: UIFont.preferredFontForTextStyle(UIFontTextStyleBody)]
        return NSAttributedString(string: str, attributes: attrs)
    }
    
    
}