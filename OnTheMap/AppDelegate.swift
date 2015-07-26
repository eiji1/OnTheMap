//
//  AppDelegate.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	// models
	var userData: StudentInformation?  // stored udacity user data
	var students = StudentInformationArray() // stored student information as array in the model class
	
	/**
	Update shared student information (locations) from specified view controller.
	
	:param: target Target view controller where completion handler should be executed
	:param: handler completion handler
	:returns: none
	*/
	func updateStudentLocations(target: UIViewController?, handler: () -> () ) {
		let indicator = createIndicator(targetView: target!.view)
		indicator.startAnimating()
		updateStudentLocationsWithMultipleRequests(target) { result, success in
			self.dispatch_async_main {
				indicator.stopAnimating()
			}
			if success {
				handler()
			}
		}
	}
	
	/**
	Update specified number of student information (locations) from multiple requests to the Parse API server.
	
	:param: target Target view controller where error message should be displayed
	:param: handler completion handler
	:returns: none
	*/
	func updateStudentLocationsWithMultipleRequests(target: UIViewController?, handler: ([StudentInformation]?, Bool) -> Void ) {
		println("update student locations.")
		
		let limits = ParseClient.LimitPerRequest * 2 // more than the most recent 100 locations
		let skip = 0
		self.students.reset()
		
		updateStudentLocationsRecursively(limit: limits, skip: skip, trial: 0) { result, success, downloadError in
			if let students = result {
				handler(self.students.array, true)
			} else {
				self.dispatch_async_main {
					self.showNetworkErrorMessage(target, downloadError: downloadError)
				}
				handler(nil, false)
			}
		}
	}
	
	private static let maxHTTPRequestTrials = 10
	
	internal func updateStudentLocationsRecursively(#limit: Int, skip: Int, trial: Int, handler: ([StudentInformation]?, Bool, NSError?) -> Void ) {
		let limitPerRequest = ParseClient.LimitPerRequest
		
		if limit <= 0 || // every student information has been obtained
			limitPerRequest <= 0 || // error: not increasing limits per loop
			trial >= AppDelegate.maxHTTPRequestTrials // avoid infinite loop
		{
			handler(self.students.array, true, nil)
			return
		}
		
		let actualLimit = limit < limitPerRequest ? limit : limitPerRequest
		ParseClient.sharedInstance().getStudentLocations(limit: actualLimit, skip: skip) { result, success, downloadError in
			if let error = downloadError {
				handler(nil, false, error)
			} else {
				if let newStudents = result {
					self.students.append(newStudents) // update student information list
					self.dispatch_async_globally {
						self.updateStudentLocationsRecursively(limit: limit-limitPerRequest, skip: skip+limitPerRequest, trial: trial+1, handler: handler)
					}
				} else { // server error
					handler(nil, false, CustomError.getError(CustomError.Code.ServerError))
				}
			}
		}
	}
	
	// alert messages
	
	/**
	Show an error message about network connection and server status.
	
	:param: target Target view controller where error message should be displayed
	:param: downloadError The download error for the last attempt.
	:returns: none
	*/
	func showNetworkErrorMessage(target: UIViewController?, downloadError: NSError?) {
		if let error = downloadError {
			if WebClient.isTimeout(error) {
				self.showAlertMessage(target, message: "network connection timeout. lack of network connectivity.")
			} else {
				self.showAlertMessage(target, message: "server response error")
			}
		}
	}
	
	/**
	Show an alert message with an OK button
	
	:param: target Target view controller where alert message should be displayed
	:param: message An alert message
	:returns: Created alert view object
	*/
	func showAlertMessage(target: UIViewController?, message: String) -> UIView {
		var alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: nil)
		alert.addAction(okAction)
		
		target?.presentViewController(alert, animated: true, completion: nil)
		return alert.view
	}
	
	/**
	Show an alert message with OK and Cancel buttons
	
	:param: target Target view controller where alert message should be displayed
	:param: message An alert message
	:param: handler The action called on OK button selected
	:returns: Created alert view object
	*/
	func showSelectMessage(target: UIViewController?, message: String, handler:((UIAlertAction!) -> Void)!) -> UIView {
		var alert = UIAlertController(title: "Alert", message: message, preferredStyle: UIAlertControllerStyle.Alert)
		let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: handler)
		let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil)
		alert.addAction(okAction)
		alert.addAction(cancelAction)
		
		target?.presentViewController(alert, animated: true, completion: nil)
		return alert.view
	}
	
	// indicators
	
	/**
	Create an indicator shown while network connection.
	
	:param: targetView A generated indicator will be displayed on this target view
	:returns: created indicator object
	*/
	func createIndicator(targetView view: UIView) -> UIActivityIndicatorView {
		let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
		indicator.frame = CGRectMake(0.0, 0.0, 80.0, 80.0);
		indicator.center = view.center;
		view.addSubview(indicator)
		indicator.bringSubviewToFront(view)
		UIApplication.sharedApplication().networkActivityIndicatorVisible = true
		return indicator
	}
	
	// async dispatching
	
	/**
	Submit functional block to be asynchronously executed on the global queue
	
	:param: handler target handler function which should be executed asynchronously
	:returns: none
	*/
	func dispatch_async_globally(handler: () -> ()) {
		dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), handler)
	}
	
	/**
	Submit functional block to be asynchronously executed on the main thread
	
	:param: handler target handler which should be executed asynchronously
	:returns: none
	*/
	func dispatch_async_main(handler: () -> ()) {
		dispatch_async(dispatch_get_main_queue(),handler);
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		// Override point for customization after application launch.
		return true
	}

	func applicationWillResignActive(application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(application: UIApplication) {
		// Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}


}

