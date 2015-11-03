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
		case InvalidAccountError
		case JSONIFYError
		case JSONParseError
		case EmptyDataError
		case UnknownError
	}
	
	/// error descriptions for development
	static let Description = [
		Code.NetworkError: "unreachable network connection",
		Code.ServerError: "server error occurred",
		Code.InvalidAccountError: "wrong account or invalid credentials",
		Code.JSONIFYError: "object serialization with JSON failed",
		Code.JSONParseError: "parsing JSON object failed",
		Code.EmptyDataError: "obtained data is empty",
		Code.UnknownError: "unknown error has been occurred"
	]

	/// get NSError object from specified custom error code
	class func getError(code: Code, description: String? = nil) -> NSError {
		return NSError(domain: OnTheMapErrorDomain, code: code.rawValue, userInfo: [ NSLocalizedDescriptionKey: (description == nil ? getDescription(code) : description!) ])
	}
	
	class func getDescription(code: Code) -> String {
		if let description = CustomError.Description[code] {
			return description
		}
		return CustomError.Description[CustomError.Code.UnknownError]!
	}
	
	class func isEqual(error:NSError, _ code: Code) -> Bool {
		return error.code == code.rawValue
	}
	
}



