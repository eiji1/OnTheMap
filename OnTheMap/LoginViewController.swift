//
//  ViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

	@IBOutlet weak var usernameTextField: UITextField!
	@IBOutlet weak var passwordTextField: UITextField!
	
	let defaultUsername = "username"
	let defaultPassword = "password"
	
	var keyboard: KeyboardController!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		keyboard = KeyboardController(view: self.view)
		
		// let users know what value should be input for each textfield
		usernameTextField.text = defaultUsername
		passwordTextField.text = defaultPassword
		
		usernameTextField.delegate = self
		passwordTextField.delegate = self
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		
		keyboard.prepareToAppear()
	}
	
	override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		
		keyboard.prepareToDisappear()
	}
	
	func textFieldDidBeginEditing(textField: UITextField) {
		textField.text = ""
	}
	
	func textFieldDidEndEditing(textField: UITextField) {
		if textField.text == "" {
			if textField == usernameTextField {
				usernameTextField.text = defaultUsername
			}
			else if textField == passwordTextField {
				passwordTextField.text = defaultPassword
			}
		}
	}
	
	@IBAction func onLoginButtonPressed(sender: AnyObject) {
		
		if usernameTextField.text == "" || passwordTextField.text == "" {
			return
		}
		
		let username = usernameTextField.text
		let password = passwordTextField.text
		
		let parameters = [UdacityClient.ParameterKeys.Username : username, UdacityClient.ParameterKeys.Password : password]
		
		UdacityClient.sharedInstance().authenticate(self, parameters: parameters) {
			success, error in
			if success {
				println("login succeeded!")
			} else {
				println("login failed")
			}
		}
		
	}

}

