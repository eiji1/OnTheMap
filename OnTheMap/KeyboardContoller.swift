//
//  KeyboardContoller.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit

class KeyboardController : NSObject {
	
	var tapRecognizer: UITapGestureRecognizer? = nil
	
	var view: UIView!
	
	init(view: UIView) {
		super.init()
		self.view = view
		tapRecognizer = UITapGestureRecognizer(target: self, action: "handleSingleTap:")
		tapRecognizer?.numberOfTapsRequired = 1
	}
	
	func prepareToAppear() {
		addKeyboardDismissRecognizer()
		subscribeToKeyboardNotifications()
	}
	
	func prepareToDisappear() {
		removeKeyboardDismissRecognizer()
		unsubscribeToKeyboardNotifications()
	}
	
	func handleSingleTap(recognizer: UITapGestureRecognizer) {
		println("End editing here")
		self.view.endEditing(true)
		
	}
	
	func addKeyboardDismissRecognizer() {
		self.view.addGestureRecognizer(tapRecognizer!)
	}
	
	func removeKeyboardDismissRecognizer() {
		self.view.removeGestureRecognizer(tapRecognizer!)
	}
	
	func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func unsubscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		self.view.frame.origin.y -= getKeyboardHeight(notification)
	}
	
	func keyboardWillHide(notification: NSNotification) {
		self.view.frame.origin.y += getKeyboardHeight(notification)
	}
	
	func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.CGRectValue().height
	}
}