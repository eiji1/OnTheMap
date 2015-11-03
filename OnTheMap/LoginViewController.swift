//
//  ViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
LoginViewController controls a behavior on login Udacity and how this application starts at first.
*/
final class LoginViewController: UIViewController, UITextFieldDelegate {
	
	
	// views
	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	@IBOutlet weak var loginButton: UIButton!
	@IBOutlet weak var imageView: UIImageView!
	
	private let defaultUsername = "ENTER_USER_NAME"
	private let defaultPassword = "ENTER_PASSWORD"
	
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
		udacity.login(username!, password!) { success, downloadError in
			if !success {
				self.sharedApp.dispatch_async_main {
					self.indicator.stopAnimating()
					self.onLoginFailed(downloadError)
				}
			}
			else {
				print("get public user data")
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
				print("login udacity and getting student data succeeded. result:\(student)")
				// set shared user data
				self.sharedApp.userData = student
				
				// show tabbar controller
				self.sharedApp.dispatch_async_main {
					let tabViewController = self.storyboard!.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
					self.presentViewController(tabViewController, animated: false, completion: nil)
				}
			} else {
				print("getting student data failed")
				self.sharedApp.dispatch_async_main {
					self.onLoginFailed(error)
				}
			}
		}
	}
	
	private func onLoginFailed(downloadError: NSError?) {
		
		// differentiates error messages between connection error and invalid user account
		var errorNotifyingMessage = "Login failed: "
		if let error = downloadError {
			// is network connection OK?
			if WebClient.isTimeout(error) ||
			CustomError.isEqual(error, CustomError.Code.ServerError)
			{
				errorNotifyingMessage += "Unreachable network connection."
			// wrong account?
			} else if CustomError.isEqual(error, CustomError.Code.InvalidAccountError) {
				errorNotifyingMessage += "Account not found or invalid credentials."
			} else {
				errorNotifyingMessage += "Unknown error has occurred."
			}
		}
		errorNotifyingMessage += "\nAre you sure to retry?"
		
		let alertView = self.sharedApp.showSelectMessage(self, message: errorNotifyingMessage) { OkAction in
			// offer an interface to retry login request
			self.sharedApp.dispatch_async_globally {
				self.signinUdacity()
			}
		}
		
		// notifies the user of login failure with UIView animations
		AddShakingAmination(self.view)
		AddRotatingAnimation(self.usernameTextField)
		AddRotatingAnimation(self.passwordTextField)
		AddRotatingAnimation(self.loginButton)
		
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
	
	private func AddShakingAmination(targetView: UIView) {
		let animation = CABasicAnimation(keyPath: "position")
		animation.duration = 0.1
		animation.repeatCount = 5
		animation.autoreverses = true
		let shift :CGFloat = 10
		animation.fromValue = NSValue(CGPoint: CGPointMake(self.view.center.x - shift, self.view.center.y))
		animation.toValue = NSValue(CGPoint: CGPointMake(self.view.center.x + shift, self.view.center.y))
		targetView.layer.addAnimation(animation, forKey: "position")
	}
	
	private func AddRotatingAnimation(targetView: UIView) {
		let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
		rotateAnimation.duration = 0.2
		rotateAnimation.repeatCount = 1
		rotateAnimation.autoreverses = true
		rotateAnimation.fromValue = 0.0
		rotateAnimation.toValue = 2*M_PI
		targetView.layer.addAnimation(rotateAnimation, forKey: "rotate-layer")
	}
}

