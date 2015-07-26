//
//  ParseClient.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/03.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit
/**
Parse Client class offers getting and posting student information through Parse APIs.

*/
final class ParseClient {
	
	// current authentication state
	private var sessionId : String!
	
	// constant variables
	static let BaseSecuredUrl = "https://api.parse.com/1/classes/StudentLocation"
	private static let ApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
	private static let APIKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	static let LimitPerRequest = 100 // maximum limit per get-locations-request
	
	struct ParameterKeys {
		// get a location
		static let Limit = "limit"
		static let Skip = "skip"
		// query a location
		static let Where = "where"
	}
	
	struct JSONBodyKeys {
		static let UniqueKey = "uniqueKey"
		static let FirstName = "firstName"
		static let LastName = "lastName"
		static let MapString = "mapString"
		static let MediaURL = "mediaURL"
		static let Latitude = "latitude"
		static let Longitude = "longitude"
	}
	
	struct JSONResponseKeys {
		static let Results = "results"
		static let UniqueKey = "uniqueKey"
		 static let FirstName = "firstName"
		static let LastName = "lastName"
		static let MapString = "mapString"
		static let MediaURL = "mediaURL"
		static let Latitude = "latitude"
		static let Longitude = "longitude"
		static let CreatedAt = "createdAt"
		static let UpdatedAt = "updatedAt"
		static let ObjectId = "objectId"
	}
	
	// make singleton
	private init(){}
	
	class func sharedInstance() -> ParseClient {
		struct Singleton {
			static let instance = ParseClient()
		}
		return Singleton.instance
	}
	
	/**
	Get student posted locations up to the specified numbers. It can be specified how many locations should be skipped from the first element.
	
	:param: limit Maximum number of locations to obtain
	:param: skip The number of locations to be skipped from the first index.
	:param: completionHandler A handler on the completion
	:returns: An array of StudentInformation in the completion handler. The StudentInformation includes name, address, URL, location and objectId.
	*/
	func getStudentLocations(#limit: Int, skip: Int, completionHandler: (result: [StudentInformation]?, success: Bool, error: NSError?) -> Void) {
		let httpClient = WebClient()
		
		var mutableParameters = [String : AnyObject]()
		// check if limit is valid
		if limit > 0 && limit <= ParseClient.LimitPerRequest {
			mutableParameters[ParseClient.ParameterKeys.Limit] = limit
			mutableParameters[ParseClient.ParameterKeys.Skip] = skip
		}
		
		// sample url: https://api.parse.com/1/classes/StudentLocation?limit=100
		let url = httpClient.createURL(ParseClient.BaseSecuredUrl, method: nil, parameters: mutableParameters)

		let httpHeaderField = [
			ParseClient.ApplicationId: "X-Parse-Application-Id",
			ParseClient.APIKey: "X-Parse-REST-API-Key"
		]
		
		let request = httpClient.createRequest(url, method: WebClient.Method.GET, parameters: httpHeaderField)
		
		httpClient.sendRequest(request, jsonBody: nil) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(result: nil, success: false, error: downloadError)
				return
			}
			/*
			{
			"results":[
			{
			"createdAt": "2015-02-25T01:10:38.103Z",
			"firstName": "AAA",
			"lastName": "BBB",
			"latitude": 34.7303688,
			....
			}
			*/
			if let resultJSON = result?.valueForKey(JSONResponseKeys.Results) as? [WebClient.JSONBody] {
				// println(resultJSON)
				let studentList = StudentInformation.getStudentInformationFromResults(resultJSON)
				completionHandler(result: studentList, success: true, error: nil)
			} else {
				completionHandler(result: nil, success: false, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
	
	/**
	Post new student location to the server.
	
	:param: uniqueKey Use Udacity user id
	:param: student The information the user wants to post
	:param: completionHandler A handler on the completion
	:returns: objectId is returned in the completion handler. Object id is the number given to each posted information uniquely to identify them.
	*/
	func postAStudentLocation(uniqueKey: WebClient.UniqueKey, student: StudentInformation, completionHandler: WebClient.CompletionHandlerWithResultString) {
		let httpClient = WebClient()
		let url = httpClient.createURL(ParseClient.BaseSecuredUrl, method: nil, parameters: nil)
		
		let httpHeaderField = [
			ParseClient.ApplicationId: "X-Parse-Application-Id",
			ParseClient.APIKey: "X-Parse-REST-API-Key"
		]
		
		let request = httpClient.createRequest(url, method: WebClient.Method.POST, parameters: httpHeaderField)
		
		let jsonBody = createJSONBody(uniqueKey, student: student)
		
		println(jsonBody)
		
		httpClient.sendRequest(request, jsonBody: jsonBody) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(resultString: nil, success: false, error: downloadError)
				return
			}
			
			/*
			{
			"createdAt":"2015-03-11T02:48:18.321Z",
			"objectId":"xxxyyyzzz"
			}
			*/
			println(result)
			
			if let objectId = result?.valueForKey(JSONResponseKeys.ObjectId) as? String {
				completionHandler(resultString: objectId, success: true, error: nil)
			} else {
				completionHandler(resultString: nil, success: false, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
	
	private func createJSONBody(uniqueKey: WebClient.UniqueKey, student: StudentInformation) -> WebClient.JSONBody {
		
		/*
		sample json body
		{
		"uniqueKey": "1234",
		"firstName": "aaa",
		"lastName": "bbb",
		"mapString": "Mountain View, CA",
		"mediaURL": "https://www.udacity.com",
		"latitude": 37.386052,
		"longitude": -122.083851
		}
		*/
		
		let jsonBody : WebClient.JSONBody = [
			JSONBodyKeys.UniqueKey: uniqueKey, // use Udacity account (user) id
			JSONBodyKeys.FirstName: student.firstName,
			JSONBodyKeys.LastName: student.lastName,
			JSONBodyKeys.MapString: student.mapString,
			JSONBodyKeys.MediaURL: student.mediaURL,
			JSONBodyKeys.Latitude: student.coordinates.latitude,
			JSONBodyKeys.Longitude: student.coordinates.longitude
		]
		
		return jsonBody
	}
	
	/**
	search student location from the DB. The query string is specified with uniqueKey.
	
	:param: uniqueKey Use Udacity user id
	:param: completionHandler A handler on the completion
	:returns: a StudentInformation is returned in the completion handler, which contains every informatoin in detail.
	*/
	func queryForAStudentLocation(uniqueKey: WebClient.UniqueKey, completionHandler: (result: [StudentInformation]?, success: Bool, error: NSError?) -> Void) {

		let httpClient = WebClient()
		
		/*
		sample url:
		https://api.parse.com/1/classes/StudentLocation?where=%7B%22uniqueKey%22%3A%221234%22%7D
		%7B%22uniqueKey%22%3A%221234%22%7D <--- {"uniqueKey":"1234"}
		*/
		var mutableParameters = [String : AnyObject]()
		let escapedStringOfQueryJson = "{\"uniqueKey\":\"\(uniqueKey)\"}" //"\%7B%22uniqueKey%22%3A%22\(uniqueKey)%22%7D"
		mutableParameters[ParseClient.ParameterKeys.Where] = escapedStringOfQueryJson
		
		// sample url: https://api.parse.com/1/classes/StudentLocation?limit=100
		let url = httpClient.createURL(ParseClient.BaseSecuredUrl, method: nil, parameters: mutableParameters)
		
		let httpHeaderField = [
			ParseClient.ApplicationId: "X-Parse-Application-Id",
			ParseClient.APIKey: "X-Parse-REST-API-Key"
		]
		
		let request = httpClient.createRequest(url, method: WebClient.Method.GET, parameters: httpHeaderField)
		
		httpClient.sendRequest(request, jsonBody: nil) { (result, success, downloadError) -> Void in
			if !success {
				completionHandler(result: nil, success: false, error: downloadError)
				return
			}
			
			/*
			{
			"results":[
			{
			"createdAt":"2015-02-24T22:35:30.639Z",
			"firstName":"AAA",
			"lastName":"BBB",
			"latitude":37.3229,
			"longitude":-122.0321,
			"mapString":"Cupertino, CA",
			"mediaURL":"https://udacity.com",
			"objectId":"xxxyyyzzz",
			"uniqueKey":"1234",
			"updatedAt":"2015-03-11T02:42:59.217Z"
			}
			]
			}
			*/
			if let resultList = result?.valueForKey(JSONResponseKeys.Results) as? [[String: AnyObject]] {
				println(resultList)
				
				// result data is empty (no location is registered)
				let studentList = StudentInformation.getStudentInformationFromResults(resultList)
				if studentList.count == 0 {
					completionHandler(result: nil, success: false, error: CustomError.getError(CustomError.Code.EmptyDataError))
				} else {
					completionHandler(result: studentList, success: true, error: nil)
				}
			} else {
				completionHandler(result: nil, success: false, error: CustomError.getError(CustomError.Code.JSONParseError))
			}
		}
	}
	
	/**
	Replace target student location with specified one. Only one student information is modified 
	and total number of registered student locations won't be changed unlike postStudnetLocation
	
	:param: uniqueKey Use Udacity user id
	:param: student The information the user wants to rewrite
	:param: completionHandler A handler on the completion
	:returns: nothing is returned in the completion handler.
	*/
	func putAStudentLocation(uniqueKey: WebClient.UniqueKey, student: StudentInformation, completionHandler: (success: Bool, error: NSError?) -> Void) {
		
		let httpClient = WebClient()
		let url = httpClient.createURL(ParseClient.BaseSecuredUrl, method: student.objectId, parameters: nil)
		
		let httpHeaderField = [
			ParseClient.ApplicationId: "X-Parse-Application-Id",
			ParseClient.APIKey: "X-Parse-REST-API-Key"
		]
		
		let request = httpClient.createRequest(url, method: WebClient.Method.PUT, parameters: httpHeaderField)
		/*
		sample json body
		{
		"uniqueKey": "1234",
		"firstName": "aaa",
		"lastName": "bbb",
		"mapString": "Mountain View, CA",
		"mediaURL": "https://www.udacity.com",
		"latitude": 37.386052,
		"longitude": -122.083851
		}
		*/
		let jsonBody = createJSONBody(uniqueKey, student: student)
		
		httpClient.sendRequest(request, jsonBody: jsonBody) { (result, success, downloadError) -> Void in
			completionHandler(success: success, error: downloadError)
			
			/*
			{
			"updatedAt":"2015-03-11T02:48:18.321Z",
			}
			*/
		}
		
	}
	
}