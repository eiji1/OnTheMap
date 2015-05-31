//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class UdacityClient {

	// current authentication state
	var sessionId : String!
	
	static let BaseSecuredUrl = "https://www.udacity.com/api/"
	
	struct Methods {
		static let RequestForSession = "session"
	}
	
	struct ParameterKeys {
		static let Username = "username"
		static let Password = "password"
	}
	
	class func sharedInstance() -> UdacityClient {
		struct Singleton {
			static let instance = UdacityClient()
		}
		return Singleton.instance
	}
	
	
	func authenticate(hostViewController: UIViewController, parameters: [String: AnyObject], completionHandler: (success: Bool, errorString: String?) -> Void) {
		
		let username = parameters[ParameterKeys.Username] as? String
		let password = parameters[ParameterKeys.Password] as? String
		
		let urlString = UdacityClient.BaseSecuredUrl + UdacityClient.Methods.RequestForSession
		let url = NSURL(string: urlString)
		println(urlString)
		
		let request = NSMutableURLRequest(URL: url!)
		request.HTTPMethod = "POST"
		request.addValue("application/json", forHTTPHeaderField: "Accept")
		request.addValue("application/json", forHTTPHeaderField: "Content-Type")
		request.HTTPBody = "{\"udacity\": {\"username\": \"\(username)\", \"password\":\"\(password)\"}}".dataUsingEncoding(NSUTF8StringEncoding)
		
		let session = NSURLSession.sharedSession()
		let task = session.dataTaskWithRequest(request) { data, response, error in
			if error != nil { // Handle error...
			return
			}
			let newData = data.subdataWithRange(NSMakeRange(5, data.length - 5)) /* subset response data! */
			println(NSString(data: newData, encoding: NSUTF8StringEncoding))
			/*
			{"account":
			{"registered": true, "key": "618989053"},
			"session": {"id": "1464634266S5bd8e6ff7d2024f0fc66c30294c70f63", "expiration", "2015-07-30T18:51:06.660980Z"}
			}
			*/
			var parsingError: NSError? = nil
			
			let parsedResult: AnyObject? = NSJSONSerialization.JSONObjectWithData(newData, options: NSJSONReadingOptions.AllowFragments, error: &parsingError)
			
			if let error = parsingError {
				//completionHandler(result: nil, error: error)
			} else {
				//completionHandler(result: parsedResult, error: nil)
				if let session = parsedResult?.valueForKey("session") as? [String: AnyObject] {
				if let sessionId = session["id"] as? String {
				println(sessionId)
				UdacityClient.sharedInstance().sessionId = sessionId
				}
				}
			}
		}
		task.resume()
	}
	
}