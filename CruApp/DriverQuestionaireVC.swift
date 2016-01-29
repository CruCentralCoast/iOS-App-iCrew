//
//  DriverQuestionaireVC.swift
//  CruApp
//
//  Created by Eric Tran on 1/28/16.
//  Copyright © 2016 iCrew. All rights reserved.
//

import UIKit
import DownPicker

/* This class is used to gather information from a potential driver of the RideShare feature */
class DriverQuestionaireVC: UIViewController {

    @IBOutlet weak var eventsChoice: UITextField!
    @IBOutlet weak var numSeatsAvailChoice: UITextField!
    @IBOutlet weak var depatureTimeChoice: UITextField!
    
    var eventDownPicker: DownPicker!
    var seatDownPicker: DownPicker!
    var datePickerView  : UIDatePicker!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeChoices()
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    override func viewDidAppear(animated : Bool) {
        super.viewDidAppear(animated)
    }

    /* Helper method to populate choices for # of seats available */
    func initializeChoices() {
        
        /* populate event choices */
        let eventChoices = ["event1", "event2", "event3"]
        self.eventDownPicker = DownPicker(textField: self.eventsChoice, withData: eventChoices)
        
        /* populate seat choices */
        let seatChoices = ([Int](1...10)).map(
            {
                (number: Int) -> String in
                return String(number)
        })
        self.seatDownPicker = DownPicker(textField: self.numSeatsAvailChoice, withData: seatChoices)
    }
    
    /* Callback when ideal depature time is clicked */
    @IBAction func idealTimeClicked(sender: UITextField) {
        // Brings up a new datepicker
        datePickerView = UIDatePicker()
        datePickerView.datePickerMode = UIDatePickerMode.Time
        sender.inputView = datePickerView
        datePickerView.addTarget(self, action: Selector("handleDatePicker:"), forControlEvents: UIControlEvents.TouchUpInside)
    }
    
    /* Fills in text field of ideal depature time */
    func handleDatePicker(sender: UIDatePicker) {
        let dateFormatter = NSDateFormatter()
        
        dateFormatter.dateFormat = "hh:mm a"
        depatureTimeChoice.text = dateFormatter.stringFromDate(sender.date)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Calls this function when the tap is recognized.
    func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        
        // sets depature time before dismissing
        handleDatePicker(datePickerView)
        view.endEditing(true)
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