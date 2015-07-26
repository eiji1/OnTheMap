//
//  TestingHelper.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/20.
//  Copyright (c) 2015 eiji. All rights reserved.
//

import UIKit

public class TestingHelper {
	// WebClient class
	public class func createURL(baseURL: String, method: String?, parameters: [String : AnyObject]? = [String : AnyObject]()) -> String{
		let url = WebClient().createURL(baseURL, method: method, parameters: parameters)
		return url.absoluteString!
	}
	
	// Udacity APIs
	
	public class func loginUdacity(username: String, _ password: String, handler: (success: Bool, error: NSError?) -> ()) {
		UdacityClient.sharedInstance().login(username, password, completionHandler: handler)
	}
	
	public class func logoutUdacity(handler: (result: String?, success: Bool, error: NSError?) -> Void) {
		UdacityClient.sharedInstance().logout(handler)
	}
	
	public class func getUseDataFromUdacity(handler: (result: StudentInformation?, error: NSError?) -> Void) {
		UdacityClient.sharedInstance().getPublicUserData(handler)
	}

	public class func getUdacityUserId() -> String {
		return UdacityClient.sharedInstance().userId
	}
	
	public class func getUdacitySessionId() -> String {
		return UdacityClient.sharedInstance().sessionId
	}
	
	// parse APIs
	
	public class func getStudentLocations(limit: Int, skip: Int, handler: (result: [StudentInformation]?, success: Bool, error: NSError?) -> Void) {
		ParseClient.sharedInstance().getStudentLocations(limit: limit, skip: skip, completionHandler: handler)
	}
	
	public class func getStudentLocationsWithMultipleRequests(limit: Int, skip: Int, handler: ([StudentInformation]?, Bool, NSError?) -> Void) {
		let sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		sharedApp.students.reset()
		sharedApp.updateStudentLocationsRecursively(limit: limit, skip: skip, trial: 0, handler: handler)
	}
	
	public class func postAStudentLocation(uniqueKey: String, student: StudentInformation, handler: (result: String?, success: Bool, error: NSError?) -> Void) {
		ParseClient.sharedInstance().postAStudentLocation(uniqueKey, student: student, completionHandler: handler)
	}
	
	public class func getLimitPerRequest() -> Int {
		return ParseClient.LimitPerRequest
	}
	
	public class func queryForAStudentLocation(uniqueKey: String, handler: (result: [StudentInformation]?, success: Bool, error: NSError?) -> Void) {
		ParseClient.sharedInstance().queryForAStudentLocation(uniqueKey, completionHandler: handler)
	}
	
	public class func putAStudentLocation(uniqueKey: String, student: StudentInformation, handler: (success: Bool, error: NSError?) -> Void) {
		ParseClient.sharedInstance().putAStudentLocation(uniqueKey, student: student, completionHandler: handler)
	}
}