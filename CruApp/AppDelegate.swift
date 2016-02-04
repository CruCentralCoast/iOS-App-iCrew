//
//  AppDelegate.swift
//  CruApp
//
//  Created by Eric Tran on 11/3/15.
//  Copyright © 2015 iCrew. All rights reserved.
//

import UIKit
import Alamofire
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate {

    var window: UIWindow?
    
    // GCM Variables
    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    let registrationKey = "onRegistrationCompleted"
    let subscriptionTopic = "/topics/global"

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        // Register application for push notifications (local and remote)
        let pushSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        UIApplication.sharedApplication().registerUserNotificationSettings(pushSettings)
        UIApplication.sharedApplication().registerForRemoteNotifications()
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        // Starts GCM service
        let gcmConfig = GCMConfig.defaultConfig()
        gcmConfig.receiverDelegate = self
        GCMService.sharedInstance().startWithConfig(gcmConfig)
        
        initCoreDataModel();
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        postEvent("hello");
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        // Connect to the GCM server to receive non-APNS notifications
        if (!connectedToGCM) {
            GCMService.sharedInstance().connectWithHandler({
                (NSError error) -> Void in
                if error != nil {
                    print("Could not connect to GCM: \(error.localizedDescription)")
                } else {
                    self.connectedToGCM = true
                    print("Connected to GCM")
                }
            })
        }
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        do {
            try self.managedObjectContext!.save()
        }
        catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Received Remote Notification!!")
    }
    
    func application(application: UIApplication, didReceiveLocalNotification notification: UILocalNotification) {
        print("Received Local Notification!!")
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("Error for registering remote notifications: \(error)")
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        print("deviceToken = \(deviceToken)")
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate = self
        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken,
            kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(
                self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    var managedObjectContext: NSManagedObjectContext?
    
    func initCoreDataModel() {
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = NSBundle.mainBundle().URLForResource("CoreDataModel", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOfURL: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        self.managedObjectContext!.persistentStoreCoordinator = psc
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
            let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
            let docURL = urls[urls.endIndex-1]
            /* The directory the application uses to store the Core Data store file.
            This code uses a file named "DataModel.sqlite" in the application's documents directory.
            */
            let storeURL = docURL.URLByAppendingPathComponent("CoreDataModel.sqlite")
            do {
                try psc.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }
    
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID,
            scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    func postEvent(eventName : String) -> () {
        print("got here!!!!")
                let postURL: String = "https://gcm-http.googleapis.com/gcm/send"
                //let postURL: String = "http://localhost:3000/api/event/create?Content-Type=application/json"
                let reqURL = NSURL(string: postURL)
                let request = NSMutableURLRequest(URL: reqURL!)
                request.HTTPMethod = "POST"
                request.setValue("key=AIzaSyCq4DmBRjJK4pE3ZO7or_6lrKLnHx4Ip7E", forHTTPHeaderField: "Authorization")
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        
                let params = ["to": "ljmIBALKMOw:APA91bHuiZWGP-yc9JDKbZfeA9hSQSHLXO0tgBP7w_X9aIiaz5oujeU00TLVaH9SLFhWSuCG88FPchYHW74_W3Kc_g9u1LTVkCwRhJy61GQ32a9V-jklbE5reY9xkK2BmS-il4XZ-fFb", "content-available": "1", "notification":["title":"CruApp", "body": "You have an upcoming event!", "sound": "default", "badge":"1"]]
        
                do {
                    let jsonPost = try NSJSONSerialization.dataWithJSONObject(params, options: NSJSONWritingOptions.PrettyPrinted)
                    request.HTTPBody = jsonPost
        
                    let session = NSURLSession.sharedSession()
        
                    let task = session.dataTaskWithRequest(request, completionHandler: {
                        (data, response, error) in
                        
                        guard let responseData = data else {
                            print("Error: did not receive data")
                            return
                        }
                        guard error == nil else {
                            print("error calling POST on /event/create")
                            print(error)
                            return
                        }
                        print("Response: \(response)")
                        let strData = NSString(data: data!, encoding: NSUTF8StringEncoding)
                        print("Body: \(strData)")
                        print("successful post!")
        
                        // parse the result as JSON, since that's what the API provides
                        let post: NSDictionary
                        do {
                            post = try NSJSONSerialization.JSONObjectWithData(responseData,
                                options: []) as! NSDictionary
                        } catch  {
                            print("error parsing response from POST on /event")
                            return
                        }
                        
                        if let eventName = post["name"] as? String
                        {
                            print("The Event Name is: \(eventName)")
                        }
                    })
                    task.resume()
                } catch {
                    print("Error: cannot create JSON from event")
                }
            }
    
}

