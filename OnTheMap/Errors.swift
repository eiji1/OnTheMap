//
//  Errors.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/14.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import Foundation


/**
custom error definition for On The Map application.
*/
public class CustomError {
	static let OnTheMapErrorDomain = "com.udacity.onthemap.error"
	
	/// custom error codes
	public enum Code: Int{
		case NetworkError = 0
		case ServerError
		case JSONIFYError
		case JSONParseError
		case EmptyDataError
	}
	
	/// error descriptions for each error code
	static let CustomErrorDescription = [
		Code.NetworkError: "network connection failed",
		Code.ServerError: "server error occurred",
		Code.JSONIFYError: "object serialization with JSON failed",
		Code.JSONParseError: "parsing JSON object failed",
		Code.EmptyDataError: "obtained data is empty"
	]

	/// get NSError object from specified custom error code
	class func getError(code: Code) -> NSError {
		return NSError(domain: OnTheMapErrorDomain, code: code.rawValue, userInfo: [ NSLocalizedDescriptionKey: CustomErrorDescription[code]! ])
	}
}



