//
//  StudentLocation.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/03.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import CoreLocation

/**
A protocol updating stored model data directly or from web API.

*/
protocol Updatable {
	/**
	Update the shared student information.
	
	:param: callWebAPI if student information should be taken from Web APIs and should be updated immediately.
	:returns: none
	*/
	func update(fromWebAPI callWebAPI: Bool)
}

/**
Student information to store indivisual name, links and locations. Their locations are shown on the map and media URLs are listed on the table view.
*/
public struct StudentInformation : Printable {
	var firstName: String = ""
	var lastName: String = ""
	var mediaURL: String = ""
	var mapString: String = ""
	var coordinates = CLLocationCoordinate2D(latitude: 0,longitude: 0)
	var objectId: String!

	public init(dictionary: [String : AnyObject]) {
		// check Udacity API response keys and store the values
		firstName = getValue(dictionary, UdacityClient.JSONResponseKeys.FirstName)
		lastName = getValue(dictionary, UdacityClient.JSONResponseKeys.LastName)
		if let mailingAddress = dictionary[UdacityClient.JSONResponseKeys.MainlingAddress] as? WebClient.JSONBody {
			mapString = getValue(mailingAddress, UdacityClient.JSONResponseKeys.City)
		}
		mediaURL = getValue(dictionary, UdacityClient.JSONResponseKeys.WebsiteURL)
		
		// check Parse API response keys
		/* sample dictionary from Parse API query result:
		{"createdAt":"2015-06-03T00:36:13.751Z","firstName":"xxx","lastName":"yyy","latitude":36.67,"longitude":-121.65,"mapString":"zzz","mediaURL":"http://www.udacity.com","objectId":"xyzw","uniqueKey":"1234","updatedAt":"2015-06-03T00:36:13.751Z"}
		*/
		// if following information cannot be obtained from Udacity firstly, check Parse API Keys next and store the values
		firstName = (firstName == "") ? getValue(dictionary, ParseClient.JSONResponseKeys.FirstName) : firstName
		lastName = (lastName == "") ? getValue(dictionary, ParseClient.JSONResponseKeys.LastName) : lastName
		mediaURL = (mediaURL == "") ? getValue(dictionary, ParseClient.JSONResponseKeys.MediaURL) : mediaURL
		mapString = (mapString == "") ? getValue(dictionary, ParseClient.JSONResponseKeys.MapString) : mapString

		// check keys only in Parse APIs
		objectId = getValue(dictionary, ParseClient.JSONResponseKeys.ObjectId)
		if let latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double {
			if let longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double {
				
				// fix invalid range
				if self.coordinates.latitude < -90 || self.coordinates.latitude > 90 {
					self.coordinates.latitude = 0
				}
				if self.coordinates.longitude < -180 || self.coordinates.longitude > 180 {
					self.coordinates.longitude = 0
				}
				self.coordinates.latitude = latitude
				self.coordinates.longitude = longitude
			}
		}
	}

	/**
      given an array of dictionaries, convert them to an array of StudentInformation objects
	*/
	static func getStudentInformationFromResults(results: [[String : AnyObject]]) -> [StudentInformation] {
		var studentInformation = [StudentInformation]()
		for result in results {
			studentInformation.append(StudentInformation(dictionary: result))
		}
		return studentInformation
	}
	
	public var description: String {
		var str = "\(firstName) \(lastName), "
		str += "\(mediaURL), "
		str += "\(mapString), "
		str += "\(coordinates.latitude), \(coordinates.longitude)"
		if objectId != nil {
			str += ", objectId: \(objectId)"
		}
		return str
	}
	
	private func getValue(dictionary: [String : AnyObject], _ key: String) -> String {
		if let result = dictionary[key] as? String {
			return result
		} else {
			return ""
		}
	}

}

/**
StudentInformationArray class holds an array of StudentInformation objects. It stores which object is currently selected and has some useful methods for gettin and setting StudentInformation easily.
*/
final class StudentInformationArray {
	
	private var array_: [StudentInformation] = [StudentInformation]()
	private var currentIndex: Int? // currently selected element
	
	func reset() {
		array_ = [StudentInformation]()
		currentIndex = 0
	}
	
	var array: [StudentInformation]? {
		return array_
	}
	
	var count: Int{
		return array_.count
	}
	
	/**
	get the index of currently indicating StudentInformation element
	*/
	func append(elements: [StudentInformation]) -> [StudentInformation]{
		array_ += elements
		return array_
	}
	
	/**
	get the index of currently indicating StudentInformation element
	*/
	func getCurrentIndex() -> Int {
		if let index = currentIndex {
			return index
		}
		return 0
	}
	
	/**
	Select a StudentInformation element by specified index
	*/
	func selectObject(index: Int) -> StudentInformation? {
		currentIndex = index
		println("index \(currentIndex) was selected.")
		return getData(index)
	}
	
	/**
	Replace the element of the specified index with new StudentInformation data.
	*/
	func setObject(index: Int, data: StudentInformation?) {
		if let validData = data {
			if index < array_.count {
				array_[index] = validData
			}
		}
	}
	
	/**
	Get the StudentInformation with specified index.
	*/
	func getData(index: Int) -> StudentInformation? {
		if index >= array_.count {
			return nil
		} else {
			return array_[index]
		}
	}
	
	/**
	Get index of the StudentInformation element corresponding to the specified object id.
	*/
	func getIndex(objectId: String?) -> Int? {
		let foundIndex = [Int](0..<array_.count).filter({self.array_[$0].objectId == objectId}).first
		return foundIndex
	}
}

