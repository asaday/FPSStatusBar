//
//  ViewController.swift
//  example
//
//  Created by asada on 2016/04/24.
//  Copyright © 2016 nagisaworks. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
		return 1
	}

	override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1000
	}

	override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCellWithIdentifier("cell") ?? UITableViewCell(style: .Default, reuseIdentifier: "cell")
		cell.textLabel?.text = "\(indexPath.row)"

		NSThread.sleepForTimeInterval(0.02) // waiting
		
		return cell
	}
}
