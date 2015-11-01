//
//  WebViewController.swift
//  OnTheMap
//
//  Created by eiji on 2015/07/28.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
WebViewController receives a URL string from InformationPostingView and shows its website.
*/
final class WebViewController: UIViewController {
	
	private var urlString: String = ""
	@IBOutlet weak var webView: UIWebView!
	
	// ViewController methods
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		let url = NSURL(string: "http://"+urlString)
		let request = NSURLRequest(URL: url!)
		self.webView.loadRequest(request)
	}
	
	// button actions
	
	@IBAction func onDismiss(sender: AnyObject?) {
		
		// Return back to the InformationPostingView. Then keep showing the location.
		if let InformationPostingVC = self.presentingViewController as? InformationPostingViewController {
			InformationPostingVC.shouldShowLocation(true)
		}
		
		self.dismissViewControllerAnimated(true, completion: nil)
	}
	
	func setUrlString(url: String) {
		self.urlString = url
	}
}
