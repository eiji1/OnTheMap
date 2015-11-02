//
//  MapAndTableViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/12.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/* 
MapAndTableTabViewController manages the additional tab with other representations of the locations. This view contains a map and a list of students' names. If a student's name is tapped in the list, the map show the student's location automatically.
*/
final class MapAndTableTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Updatable {
	
	private var sharedApp : AppDelegate!
	private var mapKitViewController: MapKitViewController?
	private var navigationBarMenu: NavigationBarMenu!
	@IBOutlet weak var tableView: UITableView!
	
	//----------------------------------------------------------------------//
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		
		navigationBarMenu = NavigationBarMenu()
		navigationBarMenu.add(self, targetDelegate: self)
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		tableView.reloadData()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
	}
	
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
		if segue.identifier == "showMapAndTable" {
			self.mapKitViewController = segue.destinationViewController as? MapKitViewController
			self.mapKitViewController?.markerTapHandler = self.onMarkerTapped
			self.mapKitViewController?.delegate = self
		}
	}
	
	//----------------------------------------------------------------------//
	// table view delegate
	
	// ask the number of rows
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sharedApp.students.count
	}
	
	// ask what cells are for each row
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("StudentInfoCell")! as UITableViewCell
		// create a table view cell
		if let student = sharedApp.students.getData(indexPath.row) {
			cell.textLabel?.text = "\(student.firstName) \(student.lastName)"
			cell.imageView?.image = UIImage(named: "pin")
		}
		return cell
	}
	
	// on selecting each row
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let student = self.sharedApp.students.selectObject(indexPath.row) {
			// create a new marker to show on the map
			putAMarkerOntheMap(student)
		}
	}
	
	//----------------------------------------------------------------------//
	// location data handlers
	
	/**
	Update the shared student information.
	
	:param: callWebAPI if student information should be taken from Web APIs and should be updated immediately.
	:returns: none
	*/
	func update(fromWebAPI callWebAPI: Bool) {
		let onStudentInformationUpdated: () -> () = {
			self.tableView.reloadData()
			let index = self.sharedApp.students.getCurrentIndex()
			if let student = self.sharedApp.students.getData(index) {
				self.sharedApp.dispatch_async_main {
					self.putAMarkerOntheMap(student)
				}
			}
		}
		if callWebAPI {
			sharedApp.updateStudentLocations(self, handler: onStudentInformationUpdated)
		} else {
			// update view using client data
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
			self.sharedApp.showSelectMessage(self, message: "Do you open the url? \(url)") { action in
				// launch browser and open the student’s link
				UIApplication.sharedApplication().openURL(NSURL(string:url)!)
			}
		}
	}
	
	private func putAMarkerOntheMap(student: StudentInformation) {
		let marker = self.mapKitViewController?.createMarker(StudentAnnotation.Kind.NameAndURL, student: student)
		// add and select the new maker
		self.mapKitViewController?.removeAllMarkers()
		self.mapKitViewController?.addMarker(marker!)
		self.mapKitViewController?.moveToMarker(marker)
	}
}
