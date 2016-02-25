//
//  DriverQuestionaireVC.swift
//  CruApp
//
//  Created by Eric Tran on 1/28/16.
//  Copyright © 2016 iCrew. All rights reserved.
//

import UIKit
import DownPicker
import CheckmarkSegmentedControl
import Alamofire
import GoogleMaps

/* This class is used to gather information from a potential driver of the RideShare feature */
class DriverQuestionaireVC: UIViewController {

    /* constants for setting up datepicker in ideal pickup time */
    let IDEAL_TIME_INTERVAL = 15
    let TIME_FORMAT = "hh:mm a"
    
    var resultsViewController: GMSAutocompleteResultsViewController?
    var searchController: UISearchController?
    var resultView: UITextView?
    
    @IBOutlet weak var pickupLocation: UITextField!
    @IBOutlet weak var driverPhoneNumber: UITextField!
    @IBOutlet weak var driverFullName: UITextField!
    @IBOutlet weak var eventsChoice: UITextField!
    @IBOutlet weak var numSeatsAvailChoice: UITextField!
    @IBOutlet weak var depatureTimeChoice: UITextField!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var driveTypes: CheckmarkSegmentedControl!
    
    // Present the Autocomplete view controller when the button is pressed.
    @IBAction func autocompleteClicked(sender: AnyObject) {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        self.presentViewController(autocompleteController, animated: true, completion: nil)
    }
    
    var eventDownPicker: DownPicker!
    var seatDownPicker: DownPicker!
    var datePickerView  : UIDatePicker!
    var dbClient: DBClient!

    var eventChoices = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        /* sets up the database to pull from */
        dbClient = DBClient()
        dbClient.getData("event", dict: setEvents)
        
        /* prepares fields to be filled for questionaire */
        initializeChoices()
    }
    
    override func viewDidAppear(animated : Bool) {
        super.viewDidAppear(animated)

        /* looks for single or multiple taps */
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    /* Helper method to populate choices for # of seats available */
    func initializeChoices() {
        
        /* set up radio buttons */
        driveTypes.options = [
            CheckmarkOption(title:"To & From Event \n(Round Trip)"),
            CheckmarkOption(title: "To Event \n(One-way)"),
            CheckmarkOption(title: "From Event \n(One-way)")]
        driveTypes.addTarget(self, action: "optionSelected:", forControlEvents: UIControlEvents.ValueChanged)

        /* populate seat choices */
        let seatChoices = ([Int](1...10)).map(
            {
                (number: Int) -> String in
                return String(number)
        })
        
        self.seatDownPicker = DownPicker(textField: self.numSeatsAvailChoice, withData: seatChoices)
        self.seatDownPicker.setPlaceholder("# Seats Available")
    }
    
    // Obtain event information from the database to an Object
    func setEvents(event: NSDictionary) {
        let name = event["name"] as! String
        self.eventChoices.append(name)
        
        /* populate event choices */
        self.eventDownPicker = DownPicker(textField: self.eventsChoice, withData: eventChoices)
        self.eventDownPicker.setPlaceholder("Choose an event...")
    }
    
    /* Callback for when a new radio button is clicked */
    func optionSelected(sender: AnyObject) {
        print("DriverQ - Selected option: \(driveTypes.options[driveTypes.selectedIndex])")
    }
    
    /* Callback when ideal depature time is clicked */
    @IBAction func idealTimeClicked(sender: UITextField) {
        // Brings up a new datepicker
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Time
        datePickerView.minuteInterval = IDEAL_TIME_INTERVAL;
        sender.inputView = datePickerView
        
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    /* Fills in text field of ideal depature time */
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = TIME_FORMAT;
        depatureTimeChoice.text = dateFormatter.stringFromDate(sender.date)
    }
    
    /* Calls this function when the tap is recognizedd
     * Causes the view (or one of its embedded text fields) to resign the first responder status. */
    func dismissKeyboard() {
        // sets depature time before dismissing
        if datePickerView != nil {
            handleDatePicker(datePickerView)
        }
        view.endEditing(true)
    }
    
    /* Callback for when submit button is pressed */
    @IBAction func submitPressed(sender: UIButton) {
        
        /* TO DO: Validate driver information, make sure everything is good to go */
        
        //grab questionaire data to add to data
        
        var rideDirection : String
        
        if(driveTypes.options[driveTypes.selectedIndex].title == "To & From Event \n(Round Trip)") {
            rideDirection = "both"
        }
        else if (driveTypes.options[driveTypes.selectedIndex].title == "To Event \n(One-way)") {
            rideDirection = "to"
        } else {
            rideDirection = "from"
        }
        
        let params = ["direction": rideDirection, "seats": Int(numSeatsAvailChoice.text!)!, "driverNumber": Int(driverPhoneNumber.text!)!, "event": "563b11135e926d03001ac15c", "driverName": driverFullName.text!, "gcm_id" : 1234567]

        do {
            let body = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
            dbClient.addData("ride", body : body)
        } catch {
            print("Error sending data to database")
        }
        
        /* Show a visual alert displaying successful signup */
        let successAlert = UIAlertController(title: "Success!", message:
            "Thank you for signing up as a driver!", preferredStyle: UIAlertControllerStyle.Alert)
        successAlert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:
            {
                (action: UIAlertAction!) -> Void in
                self.performSegueWithIdentifier("finishQuestionaire", sender: self)
            }))
    
        self.presentViewController(successAlert, animated: true, completion: nil)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension DriverQuestionaireVC: GMSAutocompleteViewControllerDelegate {
    
    // Handle the user's selection.
    func viewController(viewController: GMSAutocompleteViewController!, didAutocompleteWithPlace place: GMSPlace!) {
        print("Place name: ", place.name)
        print("Place address: ", place.formattedAddress)
        print("Place attributions: ", place.attributions)
        self.locationLabel.text = place.name + " " + place.formattedAddress!
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func viewController(viewController: GMSAutocompleteViewController!, didFailAutocompleteWithError error: NSError!) {
        // TODO: handle the error.
        print("Error: ", error.description)
    }
    
    // User canceled the operation.
    func wasCancelled(viewController: GMSAutocompleteViewController!) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // Turn the network activity indicator on and off again.
    func didRequestAutocompletePredictions(viewController: GMSAutocompleteViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(viewController: GMSAutocompleteViewController!) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}