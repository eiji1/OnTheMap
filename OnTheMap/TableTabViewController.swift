//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
TableTabViewController controls the second tab in tabbed views, which lists students' URLs.

*/
final class TableTabViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, Updatable {
	
	private var sharedApp : AppDelegate!
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
	
	//----------------------------------------------------------------------//
	// table view delegate
	
	// ask the number of rows
	func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return sharedApp.students.count
	}
	
	// ask the cell for each row
	func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("StudentInfoCell") as? UITableViewCell
		
		if let student = sharedApp.students.getData(indexPath.row) {
			// each row shows the student's name
			cell?.textLabel?.text = "\(student.firstName) \(student.lastName)"
			cell?.imageView?.image = UIImage(named: "pin")
		}
		return cell!
	}
	
	// on tapping each row
	func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
		if let student = sharedApp.students.selectObject(indexPath.row) {
			let url = student.mediaURL
			
			// show alart message asking that launching a browser is OK.
			sharedApp.showSelectMessage(self, message: "Are you sure you want to go to here? \(url)") { okAction in
				// go to student's website
				UIApplication.sharedApplication().openURL(NSURL(string:url)!)
			}
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
			let indexPath = NSIndexPath(forRow: index, inSection: 0)
			self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: UITableViewScrollPosition.Top)
		}
		if callWebAPI {
			sharedApp.updateStudentLocations(self, handler: onStudentInformationUpdated)
		} else {
			// update view using client data
			onStudentInformationUpdated()
		}
	}

}
