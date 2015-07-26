//
//  OnTheMapTests.swift
//  OnTheMapTests
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji. All rights reserved.
//

import UIKit
import XCTest
import OnTheMap
import CoreLocation

class OnTheMapTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
	
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock() {
            // Put the code you want to measure the time of here.
        }
    }
	
	//--------------------------------------------------------------//
	// test udacity apis
	
	let userName = "ENTER_USER_NAME"
	let password = "ENTER_PASSWORD"
	let udacityUserId = "ENTER_USER_ID"
	
	func testLoginUdacity() {
		
		var expectation = expectationWithDescription("login")
		TestingHelper.loginUdacity(userName, password) { success, error in
			if success {
				let userId = TestingHelper.getUdacityUserId()
				let sessionId = TestingHelper.getUdacityUserId()
				println("login succeeded!:session:\(sessionId), userid:\(userId)")
				expectation.fulfill()
				
				let expected = self.udacityUserId
				XCTAssert(userId == expected, "Pass")
				
			} else {
				println("login failed")
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
		
		expectation = expectationWithDescription("logout")
		TestingHelper.logoutUdacity() { result, success, error in
			if success {
				if let data = result {
					println("success logout: result session id: \(data)")
					expectation.fulfill()
				} else {
					XCTAssert(false, "failed")
				}
			} else {
				println("login failed")
			}
		}
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testErrorMsg () {
		let OnTheMapErrorDomain = "com.udacity.onthemap.error"
		
		enum ErrorCode: Int{
			case DownloadError = 0
			case JSONParseError
		}

		let code = ErrorCode.DownloadError
		
		let ErrorDescription = [
			ErrorCode.DownloadError : "DownloadError",
			ErrorCode.JSONParseError : "JSONParseError"
		]
		
		let errorDescription = [ NSLocalizedDescriptionKey: ErrorDescription[code]! ]
		let userInfo = errorDescription
		let myError = NSError(domain: OnTheMapErrorDomain, code: code.rawValue, userInfo: userInfo)
		
		if myError.code == ErrorCode.DownloadError.rawValue {
			println(myError)
		}
	}
	
	//--------------------------------------------------------------//
	//
	let uniqueKey = "ENTER_UDACITY_USER_ID"
	let firstName = "AAA"
	let lastName = "BBB"
	let latitude = 0.0
	let longitude = 0.0
	let mediaURL = "www.udacity.com"
	let objectId = "abcdefg"
	
	func testGetStudentLocations() {
		
		var expectation = expectationWithDescription("get sudent locations without skip")
		
		let limits = TestingHelper.getLimitPerRequest()
		TestingHelper.getStudentLocations(limits, skip: 0) { result, success, downloadError in
			if !success {
				XCTAssert(false, "failed")
			} else {
				if let students = result {
					print(students)
					expectation.fulfill()
					XCTAssert(students.count == limits, "Pass")
				} else {
					XCTAssert(false, "failed")
				}
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
		
		expectation = expectationWithDescription("get sudent locations with skip")
		let skip = 3
		TestingHelper.getStudentLocations(limits, skip: skip) { result, success, downloadError in
			if !success {
				XCTAssert(false, "failed")
			} else {
				if let students = result {
					print(students)
					expectation.fulfill()
					XCTAssert(students.count == limits, "Pass")
				} else {
					XCTAssert(false, "failed")
				}
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testGetStudentLocationsWithARequest() {
		var expectation = expectationWithDescription("get sudent locations through multiple requests")
		let limitPerRequest = TestingHelper.getLimitPerRequest()
		TestingHelper.getStudentLocationsWithMultipleRequests(limitPerRequest-2, skip: 3) { (result, success, error) in
			if let students = result {
				print(students)
				XCTAssert(students.count == limitPerRequest-2, "Pass")
				expectation.fulfill()
			} else {
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testGetStudentLocationsWith2Requests() {
		var expectation = expectationWithDescription("get sudent locations through a request")
		let limitPerRequest = TestingHelper.getLimitPerRequest()
		TestingHelper.getStudentLocationsWithMultipleRequests(limitPerRequest+2, skip: 3) { (result, success, error) in
			if let students = result {
				print(students)
				XCTAssert(students.count == limitPerRequest+2, "Pass")
				expectation.fulfill()
			} else {
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testGetStudentLocationsWith3Requests() {
		
		var expectation = expectationWithDescription("get sudent locations through 3 requests")
		let limitPerRequest = TestingHelper.getLimitPerRequest()
		TestingHelper.getStudentLocationsWithMultipleRequests(limitPerRequest*2+2, skip: 13) { (result, success, error) in
			if let students = result {
				print(students)
				XCTAssert(students.count == limitPerRequest*2+2, "Pass")
				expectation.fulfill()
			} else {
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testGetStudentLocationsWithError() {
		TestingHelper.getStudentLocationsWithMultipleRequests(0, skip: 10) { (result, success, error) in
			print(result)
		}
	}
	
	// add new student information to the student location database
	func testPostStudent() {
		return // comment out here to activate this test case
		
		var expectation = expectationWithDescription("postStudent")
		
		let sample = ["firstName" : firstName,
			"lastName" : lastName,
			"mediaURL": mediaURL,
			"latitude": latitude,
			"longitude": longitude
		]
		
		var student = StudentInformation(dictionary: sample as! [String : AnyObject])
		TestingHelper.postAStudentLocation(uniqueKey, student: student) { (result, success, error) -> Void in
			if success {
				println("result:\(result)")
				expectation.fulfill()
				XCTAssert(true, "Pass")
			} else {
				XCTAssert(false, "failed")
			}
		}
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	func testQueryStudent() {

		var expectation = expectationWithDescription("queryStudent")
		
		TestingHelper.queryForAStudentLocation(uniqueKey) { (result, success, error) -> Void in
			if success {
				println("result:\(result)")
				expectation.fulfill()
				XCTAssert(true, "Pass")
			} else {
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
	
	// modify student information
	func testPutStudentInformation() {
		
		var expectation = expectationWithDescription("putStudent")
		
		let sample = ["firstName" : firstName,
			"lastName" : lastName,
			"mediaURL": mediaURL,
			"latitude": latitude,
			"longitude": longitude,
			"objectId": objectId
		]
		
		var student = StudentInformation(dictionary: sample as! [String : AnyObject])
		
		TestingHelper.putAStudentLocation(uniqueKey, student: student) { (success, error) -> Void in
			if success {
				expectation.fulfill()
				XCTAssert(true, "Pass")
			} else {
				XCTAssert(false, "failed")
			}
		}
		
		self.waitForExpectationsWithTimeout(10.0, handler:nil)
	}
}
