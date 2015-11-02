//
//  CustomTabViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/05.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
Each tab view has the common navigation menu. NavigationBarMenu provides the operations from the menu.
*/
final class NavigationBarMenu: UIViewController{
	private var targetViewController: UIViewController!
	private var delegate: Updatable?
	
	//----------------------------------------------------------------------//
	// view construction
	
	/**
	construct navigation bar menu and add it to the specified view controller
	
	:param: none
	:returns: none
	*/
	func add(targetViewController: UIViewController, targetDelegate: Updatable?) {
		self.targetViewController = targetViewController
		self.delegate = targetDelegate
		
		// create a toolbar
		
		// UIToolbar draws gray border line at the top of the frame.
		// To prevent drawing inappropriate line, use following custom class.
		// This class disable to render original UI design.
		class CustomToolbar : UIToolbar {
			private override func drawRect(rect: CGRect) {
				// do nothing
			}
		}
		let toolbar = CustomToolbar(frame: CGRectMake(0,0,80,44))
		toolbar.autoresizingMask = UIViewAutoresizing.FlexibleHeight
		
		// new bar button item including a toolbar
		let toolbarButtonItem = UIBarButtonItem(customView: toolbar)
		
		// additional UI buttons which are actually used on this view
		let postStudentInformationButton = UIBarButtonItem(image: UIImage(named: "pin"), style: UIBarButtonItemStyle.Plain, target: self, action: "postStudentInformation")
		let refleshAnnotationsButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "refleshStudentInformation")
		
		// register buttons to the toolbar
		let space = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.FlexibleSpace, target: nil, action: nil)
		toolbar.setItems([postStudentInformationButton, space, refleshAnnotationsButton], animated: false)
		
		// locate the toolbar at the right top of navigation item bar.
		targetViewController.navigationItem.rightBarButtonItem = toolbarButtonItem
		
		let logoutButtonItem = UIBarButtonItem(title: "logout", style: UIBarButtonItemStyle.Plain, target: self, action: "logout")
		targetViewController.navigationItem.leftBarButtonItem = logoutButtonItem
	}
	
	//----------------------------------------------------------------------//
	// bar button item actions
	
	/**
	Update the shared student information from the server.
	
	:param: none
	:returns: none
	*/
	func refleshStudentInformation() {
		print("refleshStudentInformation")
		delegate?.update(fromWebAPI: true)
	}
	
	/**
	Launch InformationPostingView to post new student information
	
	:param: none
	:returns: none
	*/
	func postStudentInformation() {
		// From pin button, information posting view will be modally displayed
		let informationPostingViewController = targetViewController.storyboard!.instantiateViewControllerWithIdentifier("InformationPostingViewController") as! InformationPostingViewController
		targetViewController.presentViewController(informationPostingViewController, animated: true, completion: nil)
	}
	
	/**
	logout Udacity and transit to the login view
	
	:param: none
	:returns: none
	*/
	func logout() {
		UdacityClient.sharedInstance().logout { (result, success, error) -> Void in
			if success {
				if let sessionId = result {
					print("success logout: result session id: \(sessionId)")
				}
			} else {
				print("logout failed.")
			}
			// dismiss current view anyway
			self.targetViewController.dismissViewControllerAnimated(false, completion: nil)
		}
	}
}

