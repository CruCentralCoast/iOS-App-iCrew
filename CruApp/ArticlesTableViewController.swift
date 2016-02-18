//
//  ArticlesTableViewController.swift
//  CruApp
//
//  Created by Eric Tran on 12/1/15.
//  Copyright © 2015 iCrew. All rights reserved.
//

import UIKit
import SafariServices

/* URLResources is a inner class to hold metadata for a single article or a single tool */
class URLResources {
    private var name: String?
    private var url: String?
    
    init(name: String, url: String) {
        self.name = name
        self.url = url
    }
    
    func getName() -> String {
        return self.name!
    }
    
    func getURL() -> String {
        return self.url!
    }
}

/* ArticlesTableVC is the screen that holds all articles for user to view */
class ArticlesTableViewController: UITableViewController {

    /* A reference to the pull-down-to-refresh ui */
    @IBOutlet weak var refresh: UIRefreshControl!
    
    /* A reference to the animated loading spinner */
    var indicator = UIActivityIndicatorView()
    
    /* Holds all articles to be displayed */
    var articles = [URLResources]()
    
    /* Called when the current view is loaded */
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUpLoadSpinner()
        
        /* Sets up the database */
        //var dbClient: DBClient!
        //dbClient = DBClient()
        //dbClient.getData("event", dict: loadArticles)
        self.loadArticles()
    }

    /* Called when the current view appears */
    override func viewDidAppear(animated: Bool) {
        self.setUpRefresh()
    }
    
    /* Sets up and starts the loading indicator */
    func setUpLoadSpinner() {
        indicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 40, 40))
        indicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.Gray
        indicator.center = self.view.center
        
        /* scales the indicator to twice the color */
        let transform = CGAffineTransformMakeScale(2, 2)
        indicator.transform = transform;
        
        self.view.addSubview(indicator)
        indicator.startAnimating()
    }
    
    /* Resets the refresh UI control */
    func setUpRefresh() {
        
        // Update the displayed "Last update: " time in the UIRefreshControl
        let date = NSDate()
        let formatter = NSDateFormatter()
        formatter.timeStyle = .MediumStyle
        let updateString = "Last updated: " + formatter.stringFromDate(date)
        self.refresh.attributedTitle = NSAttributedString(string: updateString)
        
        /* Set the callback for when pulled down */
        self.refresh.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)
    }
    
    /* Callback method for when user pulls down to refresh */
    func refresh(sender:AnyObject) {
        self.setUpRefresh()
        self.tableView.reloadData()
        self.refresh.endRefreshing()
    }
    
    /* Opens a url string in an embedded web browser */
    func showLink(url: String) {
        if let url = NSURL(string: url) {
            let vc = SFSafariViewController(URL: url, entersReaderIfAvailable: true)
            presentViewController(vc, animated: false, completion: nil)
        }
    }

    /* Populates our articles from the Cru database */
    func loadArticles() {
        
        self.articles += [
            URLResources(name: "The Purpose of Prayer",
                url: "http://www.cru.org/train-and-grow/10-basic-steps/4-prayer.html")
        ]
        
        self.indicator.stopAnimating()
    }
    
    // MARK: - Table view data source

    /* Asks the data source to return the number of sections in the table view. */
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    /* Dynamically size the table according to the number of articles */
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }
    
    /* Loads each cell in the table with a link */
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ArticleCell", forIndexPath: indexPath) as! ArticleTableViewCell
        cell.setName(articles[indexPath.row].getName())
        return cell
    }
    
    /* Callback for when a link is clicked */
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        showLink(articles[indexPath.row].getURL())
    }
    
    /* Callback for when a cell is individually displayed */
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let sectionsAmount = tableView.numberOfSections
        let rowsAmount = tableView.numberOfRowsInSection(indexPath.section)
        if (indexPath.section == sectionsAmount - 1 && indexPath.row == rowsAmount - 1) {
            // This is the last cell in the table, stop the loading indicator
            self.indicator.stopAnimating()
        }
    }

}
