//
//  TabBarController.swift
//  OnTheMap
//
//  Created by eiji on 2015/07/26.
//  Copyright (c) 2015 Udacity. All rights reserved.
//

import UIKit

class TabBarController:UITabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// setup customized tabbar
		let viewControllers = self.viewControllers as! [UIViewController]
		let mapIcon = UIImage(named: "map")
		viewControllers[0].tabBarItem = UITabBarItem(title: "Map", image: mapIcon, selectedImage: mapIcon)
		let listIcon = UIImage(named: "list")
		viewControllers[1].tabBarItem = UITabBarItem(title: "List", image: listIcon, selectedImage: listIcon)
		
	}
}