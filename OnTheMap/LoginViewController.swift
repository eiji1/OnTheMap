//
//  ViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
LoginViewController class controls the behavior on login Udacity and the transition to the Student Locations Tabbed View.

*/
final class LoginViewController: UIViewController, UITextFieldDelegate {
	
	// views
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var imageView: UIImageView!
	
	private let defaultUsername = "ENTER USER NAME"
	private let defaultPassword = "ENTER PASS WORD"

	// helper classes
	private var sharedApp : AppDelegate!
	private var keyboard: KeyboardController!
	private var indicator: UIActivityIndicatorView!

	//----------------------------------------------------------------------//
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup helper classes
		self.sharedApp = (UIApplication.sharedApplication().delegate as! AppDelegate)
		self.keyboard = KeyboardController(targetView: self.view)
		
		// setup textfields
		self.usernameTextField.text = defaultUsername
		self.passwordTextField.text = defaultPassword
		self.usernameTextField.delegate = self
		self.passwordTextField.delegate = self
		
		// setup login indicator
		self.indicator = sharedApp.createIndicator(targetView: self.view)
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		keyboard.prepareToAppear()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		keyboard.prepareToDisappear()
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
		
	}
	
	//----------------------------------------------------------------------//
	// button handlers
	
	@IBAction func onLoginButtonPressed(sender: AnyObject) {
		
		// alert missing inputs
		if usernameTextField.text == "" {
			sharedApp.showAlertMessage(self, message: "username is empty.")
			return
		}
		if passwordTextField.text == "" {
			sharedApp.showAlertMessage(self, message: "password is empty.")
			return
		}
		
		signinUdacity()
	}
	
	//----------------------------------------------------------------------//
	// login and logout features
	
	private func signinUdacity() {
		
		let username = usernameTextField.text
		let password = passwordTextField.text
		
		self.sharedApp.dispatch_async_main {
			self.indicator.startAnimating()
		}

		// login udacity
		let udacity = UdacityClient.sharedInstance()
		udacity.login(username, password) { success, downloadError in
			if !success {
				self.sharedApp.dispatch_async_main {
					self.indicator.stopAnimating()
					self.onLoginFailed()
				}
			}
			else {
				println("get public user data")
				self.getPublicUserDataFromUdacity()
			}
		}
	}
	
	private func getPublicUserDataFromUdacity() {
		
		let udacity = UdacityClient.sharedInstance()
		udacity.getPublicUserData() { (result, error) -> Void in
			
			self.sharedApp.dispatch_async_main {
				self.indicator.stopAnimating()
			}
			if let student = result {
				println("login udacity and getting student data succeeded. result:\(student)")
				// set shared user data
				self.sharedApp.userData = student
				
				// show tabbar controller
				self.sharedApp.dispatch_async_main {
					let tabViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
					self.presentViewController(tabViewController, animated: false, completion: nil)
				}
			} else {
				println("getting student data failed")
				self.sharedApp.dispatch_async_main {
					self.onLoginFailed()
				}
			}
		}
	}
	
	private func onLoginFailed() {
		let alertView = self.sharedApp.showSelectMessage(self, message: "login failed. are you sure to retry") { OkAction in
			// offer an interface to retry login request
			self.sharedApp.dispatch_async_globally {
				self.signinUdacity()
			}
		}
		
		// notifies the user of login failure with UIView animation
		UIView.animateWithDuration(1.5,
			animations: { () -> Void in
				alertView.transform = CGAffineTransformMakeTranslation(0, -self.view.frame.height/4)
				self.imageView.alpha = 0.0
			}) { (success) -> Void in
				// animation chain
				UIView.animateWithDuration(1.5, animations: { () -> Void in
					self.imageView.alpha = 1.0
					alertView.transform = CGAffineTransformMakeTranslation(0, self.view.frame.height/4)
				},
			completion: nil)
		}
	}
}

