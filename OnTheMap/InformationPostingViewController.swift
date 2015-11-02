//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

/**
InformationPostingViewController class defines some operations to post a user's location to the server and it defines some methods to parepare the student information such as geocoding address strings, input the user's URL, and showing user's location on the map.
*/
final class InformationPostingViewController: UIViewController, UITextFieldDelegate {
	
	private var sharedApp: AppDelegate!
	private var tempStudentInfo: StudentInformation?

	// header part
	@IBOutlet weak var headerView: UIView!
	@IBOutlet weak var instructionLabel: UILabel!
	@IBOutlet weak var urlTextfield: UITextField!

	// body part
	@IBOutlet weak var bodyView: UIView!
	@IBOutlet weak var addressTextField: UITextField!
	@IBOutlet weak var containerView: UIView! // contains map view
	
	// footer part
	@IBOutlet weak var footerView: UIView!
	@IBOutlet weak var sendButton: UIButton!

	// helper classes
	private var keyboard: KeyboardController!
	private var indicator: UIActivityIndicatorView!

	// map view controller in the container view
	private var mapKitViewController: MapKitViewController?

	// default textfield values
	private let defaultAddressText = "Mountain View, CA"
	private let defaultUrlText = "www.udacity.com"
	
	var isMapShown = false
	
	//----------------------------------------------------------------------//
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		
		self.keyboard = KeyboardController(targetView: self.headerView, slideTargetView: false)
		// let users know what value should be input for each textfield
		self.urlTextfield.text = defaultUrlText
		self.addressTextField.text = defaultAddressText
		
		self.urlTextfield.delegate = self
		self.addressTextField.delegate = self
		
		// hide statusbar
		self.prefersStatusBarHidden()
		
		// setup login indicator
		self.indicator = sharedApp.createIndicator(targetView: self.view)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		// prepare user data
		if !isMapShown {
			self.tempStudentInfo = self.sharedApp.userData != nil ? self.sharedApp.userData : nil
		} else {
			putAMarkerOntheMap(tempStudentInfo!)
		}
		updateLayout(isMapShown: isMapShown)
		keyboard.prepareToAppear()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		keyboard.prepareToDisappear()
	}

	//----------------------------------------------------------------------//
	// screen transition handlers
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showGeocodedLocationMap" {
			self.mapKitViewController = segue.destinationViewController as? MapKitViewController
			self.mapKitViewController?.markerTapHandler = self.onMarkerTapped
		}
	}
	
	func dismiss() {
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	//----------------------------------------------------------------------//
	// UI layout switching
	
	/**
	Set if InformationView should show an entered location on the map
	
	:param: sholdShowMap true: InformationView shold show the map on appearing its view, false: otherwise
	:returns: none
	*/
	func shouldShowLocation(sholdShowMap: Bool){
		self.isMapShown = sholdShowMap
	}
	
	// update UI layout
	private func updateLayout(isMapShown isMapShown: Bool) {
		// header
		let headerViewColor = [true: UIColor.blueColor(), false: UIColor.lightGrayColor()]
		headerView.backgroundColor = headerViewColor[isMapShown]
		urlTextfield.hidden = !isMapShown
		urlTextfield.backgroundColor = headerView.backgroundColor
		instructionLabel.hidden = isMapShown
		// body
		bodyView.backgroundColor = UIColor.blueColor()
		addressTextField.hidden = isMapShown
		addressTextField.backgroundColor = bodyView.backgroundColor
		containerView.hidden = !isMapShown
		bodyView.hidden = isMapShown
		// footer
		let sendButtonLabel = [true: "submit", false: "find on the map"]
		let footerViewColor = [true: UIColor(white: 1.0, alpha: 0.5), false: UIColor.lightGrayColor()]
		sendButton.setTitle(sendButtonLabel[isMapShown], forState: UIControlState.Normal)
		footerView.backgroundColor = footerViewColor[!isMapShown]
		
		if isMapShown {
			// animate header & footer view color changes
			headerView.backgroundColor = headerViewColor[!isMapShown]
			footerView.backgroundColor = footerViewColor[!isMapShown]
			urlTextfield.backgroundColor = headerView.backgroundColor
			UIView.beginAnimations(nil ,context:nil)
			UIView.setAnimationDuration(3)
			footerView.backgroundColor = footerViewColor[isMapShown]
			headerView.backgroundColor = headerViewColor[isMapShown]
			urlTextfield.backgroundColor = headerView.backgroundColor
			UIView.commitAnimations()
		} else {
			// show prompt that the user should enter a location.
			sharedApp.showAlertMessage(self, message: "Where are you stdying now? Enter your location.")
		}
	}

	//----------------------------------------------------------------------//
	// textfield delegate
	
	func textFieldShouldReturn(textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		textField.text = ""
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		if textField == urlTextfield {
			tempStudentInfo?.mediaURL = textField.text!
			// update url string on the annotation
			self.putAMarkerOntheMap(tempStudentInfo!)
		} else if textField == addressTextField {
			tempStudentInfo?.mapString = textField.text!
		}
	}
	
	//----------------------------------------------------------------------//
	// button actions
	
	@IBAction func onFooterButtonPressed(sender: AnyObject) {
		let isCurrentlySubmitButton = sendButton.titleLabel?.text == "submit"
		if isCurrentlySubmitButton {
			onSubmitButtonPressed()
		} else { // in case of "find on the map" button
			onFindOnTheMapButtonPressed()
		}
	}

	@IBAction func onCancelButtonPressed(sender: AnyObject) {
		dismiss()
	}

	private func onSubmitButtonPressed() {
		if urlTextfield.text == "" {
			sharedApp.showAlertMessage(self, message: "Your URL is empty.")
		} else {
			postNewStudentInformation()
		}
	}
	
	private func onFindOnTheMapButtonPressed() {
		if addressTextField.text == "" {
			sharedApp.showAlertMessage(self, message: "Your address is empty.")
		} else {
			convertAddressToGeocode(addressTextField.text!)
		}
	}
	
	//----------------------------------------------------------------------//
	// student information posting functions
	
	/**
	Start posting a new student information
	
	:param: none
	:returns: none
	*/
	func postNewStudentInformation() {
		if tempStudentInfo == nil {
			print("no user data has been obtained from udacity.")
			return
		}
		tempStudentInfo?.mapString = addressTextField.text!
		tempStudentInfo?.mediaURL = urlTextfield.text!
		print(tempStudentInfo)
		
		indicator.startAnimating()
		
		// check current user's location
		if let uniqueKey = UdacityClient.sharedInstance().userId {
			requestQueryingForALocation(uniqueKey)
		} else {
			print("pareparing for unique key has been failed.")
		}
	}
	
	// Check user's location can be obtained and call putting or posting location methods.
	private func requestQueryingForALocation(uniqueKey: WebClient.UniqueKey) {
		ParseClient.sharedInstance().queryForAStudentLocation(uniqueKey) { (result, success, downloadError) -> Void in
			if success {
				if let myLocations = result {
					let latestLocation = myLocations[myLocations.count-1]
					// check objectId is found in the current student list.
					if let _ = self.sharedApp.students.getIndex(latestLocation.objectId) {
						// store object id
						self.tempStudentInfo?.objectId = latestLocation.objectId
						print(self.tempStudentInfo)
						// modify last student information
						self.requestPuttingALocation(uniqueKey, student: self.tempStudentInfo!)
					} else { // not found
						// post new student info
						self.requestPostingALocation(uniqueKey, student: self.tempStudentInfo!)
					}
					return // avoid completion handler
				}
			} else {
				// no location has ever been posted.
				if let error = downloadError {
					if error.code == CustomError.Code.EmptyDataError.rawValue {
						self.requestPostingALocation(uniqueKey, student: self.tempStudentInfo!)
						return // avoid completion handler
					}
				}
			}
			// failure cases
			self.onFinishPostingStudentLocation(success)
		}
	}
	
	// Put (rewrite) user's location
	private func requestPuttingALocation(uniqueKey: WebClient.UniqueKey, student: StudentInformation) {
		ParseClient.sharedInstance().putAStudentLocation(uniqueKey, student: student) { (success, downloadError) -> Void in
			if success {
				print("putting student info succeeded.")
			}
			self.onFinishPostingStudentLocation(success)
		}
	}
	
	// Post (newly create) user's location
	private func requestPostingALocation(uniqueKey: WebClient.UniqueKey, student: StudentInformation) {
		ParseClient.sharedInstance().postAStudentLocation(uniqueKey, student: student) { (result, success, error) -> Void in
			if success {
				if let objectId = result {
					self.tempStudentInfo?.objectId = objectId
					print("set object id to the user information. \(objectId)")
				}
				// get student locations again because the total number has been increased.
				self.sharedApp.updateStudentLocationsWithMultipleRequests(self) { result, success in
					if success {
						print("student info has been updated.")
					}
				}
			}
			self.onFinishPostingStudentLocation(success)
		}
	}
	
	// completion handler after finished putting or posting a student location
	private func onFinishPostingStudentLocation(success: Bool) {
		self.sharedApp.dispatch_async_main {
			self.indicator.stopAnimating()
		}
		
		if success {
			print("posting student info succeeded.")
			
			// search my location from current student list
			let myObjectId = tempStudentInfo?.objectId
			
			// update student information
			if let index = sharedApp.students.getIndex(myObjectId) {
				sharedApp.students.setObject(index, data: self.tempStudentInfo!)
				sharedApp.students.selectObject(index)
			}
			// update shared user data
			sharedApp.userData = tempStudentInfo
			
			self.dismiss()
		} else {
			self.sharedApp.dispatch_async_main {
				self.sharedApp.showSelectMessage(self, message: "Posting your information failed. Quit posting a location?") { OKAction in
					self.dismiss()
				}
			}
		}
	}
	
	//----------------------------------------------------------------------//
	// geocoding and map operations
	
	func onMarkerTapped(student: StudentAnnotation?) {
		// let users browse to the entered link when users tap the displaying annotation.
		let webViewController = self.storyboard!.instantiateViewControllerWithIdentifier("WebViewController") as! WebViewController
		webViewController.setUrlString(urlTextfield.text!)
		self.presentViewController(webViewController, animated: false, completion: nil)
	}
	
	private func convertAddressToGeocode(addressString: String) {
		indicator.startAnimating()
		self.instructionLabel.text = "Getting a location.\nWait for a while. \n(At most 30 seconds)"
		
		// geocode an address string
		let geocoder = CLGeocoder()
		geocoder.geocodeAddressString(addressString) { (placemarks, geocodingError) -> Void in
			self.indicator.stopAnimating()
			
			// check geocode result
			var isGeocodingOK = true
			if let _ = geocodingError {
				isGeocodingOK = false
			} else if placemarks == nil {
				isGeocodingOK = false
			}
			
			if let placemark = placemarks!.first {
				// store the location, address string and media URL
				self.tempStudentInfo?.coordinates = placemark.location!.coordinate
				self.tempStudentInfo?.mapString = addressString
				self.tempStudentInfo?.mediaURL = self.urlTextfield.text!
				
				self.sharedApp.dispatch_async_main {
					// show the location on the map
					self.putAMarkerOntheMap(self.tempStudentInfo!)
					self.updateLayout(isMapShown: true)
				}
			} else {
				isGeocodingOK = false
			}
			
			if !isGeocodingOK {
				self.sharedApp.dispatch_async_main {
					self.sharedApp.showAlertMessage(self, message: "failed to geocode your address.")
				}
			}
		}
	}
	
	private func putAMarkerOntheMap(student: StudentInformation) {
		let marker = self.mapKitViewController?.createMarker(StudentAnnotation.Kind.AddressAndURL, student: student)
		self.mapKitViewController?.removeAllMarkers()
		self.mapKitViewController?.addMarker(marker)
		// zoom the map to focus the added pin
		self.mapKitViewController?.moveToMarker(marker)
	}
}
