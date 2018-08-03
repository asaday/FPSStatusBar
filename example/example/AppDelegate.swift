//
//  AppDelegate.swift
//  example
//
//  Created by asada on 2016/04/24.
//  Copyright © 2016 nagisaworks. All rights reserved.
//

import UIKit
import FPSStatusBar

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?

	func application(_: UIApplication, didFinishLaunchingWithOptions _: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		FPSStatusBar.start()
		// FPSStatusBar.transparent = true

		return true
	}
}
