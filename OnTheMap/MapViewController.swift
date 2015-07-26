//
//  MapViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit
import Foundation

/**
MapViewController controls the first tab view showing a lot of student locations on the map at the same time.
*/
final class MapViewController: UIViewController, Updatable{
	
	private var sharedApp : AppDelegate!
	private var navigationBarMenu: NavigationBarMenu!
	private var mapKitViewController: MapKitViewController?
	
	@IBOutlet weak var containerView: UIView!
	
	//----------------------------------------------------------------------//
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		
		self.navigationBarMenu = NavigationBarMenu()
		self.navigationBarMenu.add(self, targetDelegate: self)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		mapKitViewController?.delegate = self
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	// assosiate this instance with the map kit view controller in the container view
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMainMap" {
			self.mapKitViewController = segue.destinationViewController as? MapKitViewController
			self.mapKitViewController?.markerTapHandler = self.onMarkerTapped
			self.mapKitViewController?.delegate = self
		}
	}
	
	//----------------------------------------------------------------------//
	// location data and annotation handlers
	
	/**
	Update the shared student information.
	
	:param: callWebAPI if student information should be taken from Web APIs and should be updated immediately.
	:returns: none
	*/
	func update(fromWebAPI callWebAPI: Bool) {
		let onStudentInformationUpdated: () -> () = {
			self.sharedApp.dispatch_async_main {
				self.mapKitViewController?.showAllMarkers(StudentAnnotation.Kind.NameAndURL)
				let index = self.sharedApp.students.getCurrentIndex()
				let marker = self.mapKitViewController?.getMarker(index)
				self.mapKitViewController?.moveToMarker(marker)
			}
		}
		if callWebAPI {
			sharedApp.updateStudentLocations(self, handler: onStudentInformationUpdated)
		} else {
			onStudentInformationUpdated()
		}
	}
	
	/**
	What should be done on tapped a specified marker.
	
	:param: student corresponding student information
	:returns: none
	*/
	func onMarkerTapped(student: StudentAnnotation?) {
		if let url = student?.url {
			self.sharedApp.showSelectMessage(self, message: "Are you sure to open to the url? \(url)") { action in
				// launch browser and open the student’s link
				UIApplication.sharedApplication().openURL(NSURL(string:url)!)
			}
		}
	}
}