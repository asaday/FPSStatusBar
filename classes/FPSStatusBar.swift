//
//  FPSStatusBar.swift
//  FPSStatusBar
//
//  Created by asada on 2016/04/24.
//  Copyright © 2016 nagisaworks. All rights reserved.
//

import UIKit
import usage

public class FPSStatusBar: UIWindow {

	public static var sharedInstance = FPSStatusBar()
	public var interval: Int = 5

	let historyLength: Int
	var fpsHistory: [Int] = []
	var cpuHistory: [Int] = []

	let fpsLayer = CAShapeLayer()
	let cpuLayer = CAShapeLayer()
	let lbl: UILabel = UILabel()

	var internalCount: Int = 0
	var firstMem: Float = 0

	lazy var displayLink: CADisplayLink = {
		return CADisplayLink(target: self, selector: #selector(display))
	}()

	let fpsColor = UIColor(red: 1.0, green: 0.22, blue: 0.22, alpha: 1.0)
	let cpuColor = UIColor(red: 0.27, green: 0.85, blue: 0.46, alpha: 1.0)
	let textColor = UIColor.grayColor()

	var lastTimestamp: CFTimeInterval = 0
	var memWarning: Int = 0

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public static func start() {
		sharedInstance.displayLink.paused = false
	}

	public static func stop() {
		sharedInstance.displayLink.paused = true
		sharedInstance.hidden = true
	}

	public static var transparent: Bool {
		get {
			return sharedInstance.backgroundColor == UIColor.clearColor()
		}
		set(v) {
			if v { sharedInstance.backgroundColor = UIColor.clearColor() }
			else { sharedInstance.backgroundColor = UIColor.blackColor() }
		}
	}

	deinit {
		NSNotificationCenter.defaultCenter().removeObserver(self)
		displayLink.paused = true
	}

	init() {
		let rc = UIApplication.sharedApplication().statusBarFrame
		historyLength = Int(rc.size.width)
		super.init(frame: rc)

		userInteractionEnabled = false

		windowLevel = UIWindowLevelStatusBar + 1
		backgroundColor = UIColor.blackColor()

		cpuLayer.strokeColor = cpuColor.CGColor

		cpuLayer.drawsAsynchronously = true
		cpuLayer.fillColor = UIColor.clearColor().CGColor
		layer.addSublayer(cpuLayer)

		fpsLayer.strokeColor = fpsColor.CGColor
		fpsLayer.fillColor = UIColor.clearColor().CGColor
		fpsLayer.drawsAsynchronously = true
		layer.addSublayer(fpsLayer)

		lbl.frame = bounds
		lbl.font = UIFont(name: "Courier", size: 11)
		lbl.textColor = UIColor.grayColor()
		lbl.textAlignment = .Center
		lbl.adjustsFontSizeToFitWidth = true
		addSubview(lbl)

		displayLink.paused = true
		displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)

		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyActive), name: UIApplicationDidBecomeActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(notifyDeactive), name: UIApplicationWillResignActiveNotification, object: nil)
		NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(NotifymemWarning), name: UIApplicationDidReceiveMemoryWarningNotification, object: nil)

		firstMem = mem_usage() // its not equal instruments usage...
	}

	func notifyActive() {
		displayLink.paused = false
		lastTimestamp = 0
	}

	func notifyDeactive() {
		displayLink.paused = true
	}

	func NotifymemWarning() {
		memWarning += 1
	}

	func display() {

		if lastTimestamp == 0 {
			lastTimestamp = displayLink.timestamp
			return
		}

		let duration = displayLink.duration
		if duration == 0 { return }

		// waiting keywindow set
		if hidden && UIApplication.sharedApplication().keyWindow != nil { hidden = false }

		if fpsHistory.count > historyLength { fpsHistory.removeAtIndex(0) }
		let fps = Int(round((displayLink.timestamp - lastTimestamp) / duration))
		fpsHistory.append(fps)
		lastTimestamp = displayLink.timestamp

		var threadCnt: Int64 = 0
		let cpu = Int(cpu_usage(&threadCnt))
		if cpuHistory.count > historyLength { cpuHistory.removeAtIndex(0) }
		cpuHistory.append(cpu)

		internalCount += 1
		if internalCount < interval { return }
		internalCount = 0

		let fpspath = UIBezierPath()

		var x: CGFloat = 0
		var drop: Int = 0
		var totalfc: Int = 0
		for v in fpsHistory {
			totalfc += v
			drop = max(drop, v - 1)

			let y: CGFloat = min(bounds.size.height - 1, CGFloat((v - 1) * 5 + 1))
			if x == 0.0 { fpspath.moveToPoint(CGPoint(x: 0, y: y)) }
			fpspath.addLineToPoint(CGPoint(x: x, y: y))
			x += 1.0
		}

		let cpupath = UIBezierPath()
		cpupath.moveToPoint(CGPointZero)
		x = 0
		for v in cpuHistory {
			let y: CGFloat = bounds.size.height - (CGFloat(v) / 100 * bounds.size.height) - 1
			if x == 0.0 { cpupath.moveToPoint(CGPoint(x: 0, y: y)) }
			cpupath.addLineToPoint(CGPoint(x: x, y: y))
			x += 1.0
		}
		fpsLayer.path = fpspath.CGPath
		cpuLayer.path = cpupath.CGPath

		var avg = 0
		if totalfc > 0 { avg = Int(round(1.0 / duration)) * fpsHistory.count / totalfc }

		lbl.text = String(format: "%dfps %ddrops %dms | cpu %d%% %dth | %dMB %dwar",
			avg, drop, Int(Double(drop) * duration * 1000), cpu, threadCnt,
			Int((mem_usage() - firstMem) / (1024 * 1024)),
			memWarning
		)
	}
}
