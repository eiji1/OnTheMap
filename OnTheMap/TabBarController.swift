//
//  TabBarController.swift
//  OnTheMap
//
//  Created by eiji on 2015/07/26.
//  Copyright (c) 2015 eiji & Udacity. All rights reserved.
//

import UIKit

/**
TabBarController class creates custom tab bar items with
programmably created icons and titles.
*/
final class TabBarController:UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup customized tabbar items
		let viewControllers = self.viewControllers as! [UIViewController]
		let mapIcon = UIImage(named: "map")
		viewControllers[0].tabBarItem = UITabBarItem(title: "Map", image: mapIcon, selectedImage: mapIcon)
		let listIcon = UIImage(named: "list")
		viewControllers[1].tabBarItem = UITabBarItem(title: "List", image: listIcon, selectedImage: listIcon)
		
	}
}