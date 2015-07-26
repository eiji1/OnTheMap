//
//  KeyboardContoller.swift
//  OnTheMap
//
//  Created by eiji on 2015/06/01.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import Foundation
import UIKit


final class KeyboardController : NSObject {
	
	// helper classes
	private var tapRecognizer: UITapGestureRecognizer? = nil
	
	// target views
	private var shouldSlideUpView = true
	private var targetView: UIView!
	private var isSlidedUp = false
	private var defaultPos: CGFloat = 0
	
	init(targetView: UIView, slideTargetView: Bool = true) {
		super.init()
		self.targetView = targetView
		self.shouldSlideUpView = slideTargetView
		self.defaultPos = self.targetView.frame.origin.y
		
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
		self.targetView.endEditing(true)
	}
	
	private func addKeyboardDismissRecognizer() {
		self.targetView.addGestureRecognizer(tapRecognizer!)
	}
	
	private func removeKeyboardDismissRecognizer() {
		self.targetView.removeGestureRecognizer(tapRecognizer!)
	}
	
	private func subscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
	}
	
	private func unsubscribeToKeyboardNotifications() {
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
		NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
	}
	
	func keyboardWillShow(notification: NSNotification) {
		if !shouldSlideUpView {
			return
		}
		if !isSlidedUp { // to avoid sliding up twice
			self.targetView.frame.origin.y -= getKeyboardHeight(notification)
			isSlidedUp = !isSlidedUp
		}
	}
	
	func keyboardWillHide(notification: NSNotification) {
		if !shouldSlideUpView {
			return
		}
		if isSlidedUp {
			self.targetView.frame.origin.y = self.defaultPos
			isSlidedUp = !isSlidedUp
		}
	}
	
	private func getKeyboardHeight(notification: NSNotification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.CGRectValue().height
	}
}