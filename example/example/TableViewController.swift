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

	override func numberOfSections(in _: UITableView) -> Int {
		return 1
	}

	override func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
		return 1000
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell") ?? UITableViewCell(style: .default, reuseIdentifier: "cell")
		cell.textLabel?.text = "\(indexPath.row)"

		Thread.sleep(forTimeInterval: 0.02) // waiting

		return cell
	}
}
