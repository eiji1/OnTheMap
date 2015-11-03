//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
Udacity Client class manages accessing Udacity web APIs and it returns the user's account information on the completion.

*/
final class UdacityClient {

	// current authentication state
	internal var sessionId : String!
	internal var userId :WebClient.UniqueKey!
	
	static let BaseSecuredUrl = "https://www.udacity.com/api"
	static let JSONParseOffset = 5 // the first 5 letters should be skipped for parsing JSON object data.
	// constant variables
	static let LoginErrorStatus = 403
	
	struct Methods {
		static let Session = "session"
		static let User = "users"
	}
	
	struct ParameterKeys {
		// get session
		static let Username = "username"
		static let Password = "password"
	}
	
	struct JSONBodyKeys {
		static let Udacity = "udacity"
		static let Username = "username"
		static let Password = "password"
		static let FacebookMobile = "facebook_mobile"
		static let AccessToken = "access_token"
	}
	
	struct JSONResponseKeys {
		// get session
		static let Account = "account"
		static let Registerrd = "registered"
		static let Key = "key"
		
		static let Session = "session"
		static let Id = "id"
		static let Expiration = "expiration"
		
		static let User = "user"
		
		// error case
		static let Error = "error"
		static let Status = "status"
		
		// Getting public user data
		static let LastName = "last_name"
		static let FirstName = "first_name"
		static let MainlingAddress = "mailing_address"
		static let City = "city"
		static let Country = "country"
		static let WebsiteURL = "website_url"
	}
	
	// make singleton
	private init(){}
	
	class func sharedInstance() -> UdacityClient {
		struct Singleton {
			static let instance = UdacityClient()
		}
		return Singleton.instance
	}
	
	/**
	login Udacity and get a session and registered user id.
	
	:param: username
	:param: passowrd password string
	:param: completionHandler A handler on the completion
	:returns: session id and user id in the completion handler
	*/
	func login(username: String, _ password: String, completionHandler: WebClient.CompletionHandler) {
		let httpClient = WebClient()
		// for all response, it needs to skip the first 5 characters of the response.
		httpClient.startParsePos = UdacityClient.JSONParseOffset
		
		// prepare a URL
		// sample url : https://www.udacity.com/api/session
		let url = httpClient.createURL(UdacityClient.BaseSecuredUrl, method: UdacityClient.Methods.Session)

		// prepare a request
		let httpHeaderField = [
			"Accept": "application/json"
		]
		let request = httpClient.createRequest(url, method: WebClient.Method.POST, parameters: httpHeaderField)
		
		let httpBody = [
			JSONBodyKeys.Udacity: [
				JSONBodyKeys.Username: username,
				JSONBodyKeys.Password: password
			]
		]

		// send a request to Udacity server
		httpClient.sendRequest(request, jsonBody: httpBody) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(success: false, error: downloadError)
				return
			}
			print(result)

			// check if the error status has returned
			if let status = result?.valueForKey(JSONResponseKeys.Status) as? Int {
				if status == UdacityClient.LoginErrorStatus {
					let errorDescription = result?.valueForKey(JSONResponseKeys.Error) as? String
						completionHandler(success: false, error: CustomError.getError(CustomError.Code.InvalidAccountError, description: errorDescription))
					return
				}
			}

			// session id
			var gotSessionId = false
			if let session = result?.valueForKey(JSONResponseKeys.Session) as? WebClient.JSONBody {
				if let sessionId = session[JSONResponseKeys.Id] as? String {
					self.sessionId = sessionId
					gotSessionId = true
				}
			}
			// user id
			var gotUserId = false
			if let account = result?.valueForKey(JSONResponseKeys.Account) as? WebClient.JSONBody {
				if let key = account[JSONResponseKeys.Key] as? String {
					self.userId = key
					gotUserId = true
				}
			}
			// on completion
			if gotSessionId && gotUserId {
				completionHandler(success: true, error: nil)
			} else {
				completionHandler(success: false, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
	
	/**
	logout Udacity
	
	:param: completionHandler A handler on the completion
	:returns: session id in the completion handler
	*/
	func logout(completionHandler: WebClient.CompletionHandlerWithResultString) {
		let httpClient = WebClient()
		httpClient.startParsePos = UdacityClient.JSONParseOffset
		
		// sample url : https://www.udacity.com/api/session
		let url = httpClient.createURL(UdacityClient.BaseSecuredUrl, method: UdacityClient.Methods.Session)

		var httpHeaderField = WebClient.JSONBody()
		
		// prepare for http header field for delete method
		var xsrfCookie: NSHTTPCookie? = nil
		let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
		if let cookies = sharedCookieStorage.cookies {
			for cookie in cookies as [NSHTTPCookie] {
				if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
			}
		}
		if let xsrfCookie = xsrfCookie {
			httpHeaderField["X-XSRF-Token"] = xsrfCookie.value
		}

		let request = httpClient.createRequest(url, method: WebClient.Method.DELETE, parameters: httpHeaderField)
		
		httpClient.sendRequest(request, jsonBody: nil) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(resultString: nil, success: false, error: downloadError)
				return
			}
			// parse session id
			if let session = result?.valueForKey(JSONResponseKeys.Session) as? WebClient.JSONBody {
				if let sessionId = session[JSONResponseKeys.Id] as? String {
					completionHandler(resultString: sessionId, success: true, error: nil)
				}
			} else {
				completionHandler(resultString: nil, success: false, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
	
	/**
	Get registered user data in detail from Udacity and return it as a StudentInformation object.
	
	:param: completionHandler A handler on the completion which gives the result
	:returns: StudentInformation object including user data (such as firstname, lastname, address string, and media URL) in the completion handler
	*/
	func getPublicUserData(completionHandler: (result: StudentInformation?, error: NSError?) -> Void) {
		let httpClient = WebClient()
		httpClient.startParsePos = UdacityClient.JSONParseOffset
		
		// sample url: https://www.udacity.com/api/users/00000000
		let url = httpClient.createURL(UdacityClient.BaseSecuredUrl, method: UdacityClient.Methods.User + "/\(self.userId)")
		
		let httpHeaderField = [
			"Accept": "application/json"
		]
		let request = httpClient.createRequest(url, method: WebClient.Method.GET, parameters: httpHeaderField)
		
		httpClient.sendRequest(request, jsonBody: nil) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(result: nil, error: downloadError)
				return
			}
			// user data
			if let userData = result?.valueForKey(JSONResponseKeys.User) as? WebClient.JSONBody {
				print(userData)
				let student = StudentInformation(dictionary: userData)
				print(student)
				completionHandler(result: student, error: nil)
			} else {
				completionHandler(result: nil, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
}