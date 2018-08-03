//
//  FPSStatusBar.swift
//  FPSStatusBar
//
//  Created by asada on 2016/04/24.
//  Copyright © 2016 nagisaworks. All rights reserved.
//

import UIKit

open class FPSStatusBar: UIWindow {

	open static var shared = FPSStatusBar()
	open var interval: Int = 5

	let historyLength: Int
	var fpsHistory: [Int] = []
	var cpuHistory: [Int] = []

	let fpsLayer = CAShapeLayer()
	let cpuLayer = CAShapeLayer()
	let lbl: UILabel = UILabel()

	var internalCount: Int = 0
	var firstMem: Float = 0

	lazy var displayLink: CADisplayLink = {
		return CADisplayLink(target: self, selector: #selector(doDisplay))
	}()

	let fpsColor = UIColor(red: 1.0, green: 0.22, blue: 0.22, alpha: 1.0)
	let cpuColor = UIColor(red: 0.27, green: 0.85, blue: 0.46, alpha: 1.0)
	let textColor = UIColor.gray

	var lastTimestamp: CFTimeInterval = 0
	var memWarning: Int = 0

	required public init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	open static func start() {
		shared.displayLink.isPaused = false
	}

	open static func stop() {
		shared.displayLink.isPaused = true
		shared.isHidden = true
	}

	open static var transparent: Bool {
		get {
			return shared.backgroundColor == .clear
		}
		set(v) {
			if v { shared.backgroundColor = .clear }
			else { shared.backgroundColor = .black }
		}
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
		displayLink.isPaused = true
	}

	init() {
		let rc = UIApplication.shared.statusBarFrame
		historyLength = Int(rc.size.width)
		super.init(frame: rc)

		isUserInteractionEnabled = false

		windowLevel = UIWindowLevelStatusBar + 1
		backgroundColor = .black

		cpuLayer.strokeColor = cpuColor.cgColor

		cpuLayer.drawsAsynchronously = true
		cpuLayer.fillColor = UIColor.clear.cgColor
		layer.addSublayer(cpuLayer)

		fpsLayer.strokeColor = fpsColor.cgColor
		fpsLayer.fillColor = UIColor.clear.cgColor
		fpsLayer.drawsAsynchronously = true
		layer.addSublayer(fpsLayer)

		lbl.frame = bounds
		lbl.font = UIFont(name: "Courier", size: 11)
		lbl.textColor = .gray
		lbl.textAlignment = .center
		lbl.adjustsFontSizeToFitWidth = true
		addSubview(lbl)

		displayLink.isPaused = true
		displayLink.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)

		NotificationCenter.default.addObserver(self, selector: #selector(notifyActive), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(notifyDeactive), name: NSNotification.Name.UIApplicationWillResignActive, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(NotifymemWarning), name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)

		firstMem = mem_usage() // its not equal instruments usage...
	}

	func notifyActive() {
		displayLink.isPaused = false
		lastTimestamp = 0
	}

	func notifyDeactive() {
		displayLink.isPaused = true
	}

	func NotifymemWarning() {
		memWarning += 1
	}

	func doDisplay() {

		if lastTimestamp == 0 {
			lastTimestamp = displayLink.timestamp
			return
		}

		let duration = displayLink.duration
		if duration == 0 { return }

		// waiting keywindow set
		if isHidden && UIApplication.shared.keyWindow != nil { isHidden = false }

		if fpsHistory.count > historyLength { fpsHistory.remove(at: 0) }
		let fps = Int(round((displayLink.timestamp - lastTimestamp) / duration))
		fpsHistory.append(fps)
		lastTimestamp = displayLink.timestamp

		var threadCnt: Int64 = 0
		let cpu = Int(cpu_usage(&threadCnt))
		if cpuHistory.count > historyLength { cpuHistory.remove(at: 0) }
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
			if x == 0.0 { fpspath.move(to: CGPoint(x: 0, y: y)) }
			fpspath.addLine(to: CGPoint(x: x, y: y))
			x += 1.0
		}

		let cpupath = UIBezierPath()
		cpupath.move(to: CGPoint.zero)
		x = 0
		for v in cpuHistory {
			let y: CGFloat = bounds.size.height - (CGFloat(v) / 100 * bounds.size.height) - 1
			if x == 0.0 { cpupath.move(to: CGPoint(x: 0, y: y)) }
			cpupath.addLine(to: CGPoint(x: x, y: y))
			x += 1.0
		}
		fpsLayer.path = fpspath.cgPath
		cpuLayer.path = cpupath.cgPath

		var avg = 0
		if totalfc > 0 { avg = Int(round(1.0 / duration)) * fpsHistory.count / totalfc }

		lbl.text = String(format: "%dfps %ddrops %dms | cpu %d%% %dth | %dMB %dwar",
			avg, drop, Int(Double(drop) * duration * 1000), cpu, threadCnt,
			Int((mem_usage() - firstMem) / (1024 * 1024)),
			memWarning
		)
	}
}
