//
//  ViewController.swift
//  ThreadDemo
//
//  Created by angcyo on 16/8/21.
//  Copyright © 2016年 angcyo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

	@IBOutlet weak var infoLabel: UILabel!

	override func viewDidLoad() {
		super.viewDidLoad()
		// Do any additional setup after loading the view, typically from a nib.
	}

	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func showOnUI(info: String) {
		// 在当前线程执行...
//		NSBlockOperation {
//			self.infoLabel.text = info
//		}.start()

		// 1->在主线程的队列执行
//		dispatch_async(dispatch_get_main_queue()) {
//			self.infoLabel.text = info
//		}

		// 2->在主线程执行
		NSOperationQueue.mainQueue().addOperationWithBlock {
			self.infoLabel.text = info
		}
	}

	@IBOutlet var onTest: [UIButton]!

	@IBAction func onGetThreadInfo(sender: AnyObject) {
		getThreadInfo()
	}

	@IBAction func onSingleThread(sender: AnyObject) {
		createSingleThread()
	}

	@IBAction func onCreateAndRun(sender: AnyObject) {
		createAndStartThread()
	}

	@IBAction func onMainSync() {
		gcdMainQueueSync()
	}

	@IBAction func onMainAsync() {
		gcdMainQueueAsync()
	}
}

extension ViewController {
	func getThreadInfo() {
		let thread = NSThread.currentThread()
		let threadInfo = "线程名:\(thread.name)\n堆栈大小:\(thread.stackSize)\n优先级:\(thread.threadPriority)\n是否是主线程:\(thread.isMainThread)\n地址:\(NSThread.callStackReturnAddresses().first)-\(NSThread.callStackReturnAddresses().last!)"
		print(threadInfo)
		showOnUI(threadInfo)
	}

	// MARK: 手动创建线程, 并且手动开始线程
	func createSingleThread() {
		NSThread(target: self, selector: #selector(onThreadRun), object: nil).start()
	}

	// MARK: 创建线程并自动开始线程
	func createAndStartThread() {
		NSThread.detachNewThreadSelector(#selector(onThreadRun), toTarget: self, withObject: nil)
	}

	// MARK:添加一个block到主线程队列,注意会阻塞当前线程,等待当前队列任务执行完,才会执行block
	func gcdMainQueueSync() {
		dispatch_sync(dispatch_get_main_queue()) {
			print("main_sync")
			self.getThreadInfo()
		}
	}

    //MARK: 添加一个block到主队列,异步执行,不会阻塞当前线程
	func gcdMainQueueAsync() {
		dispatch_async(dispatch_get_main_queue()) {
			print("main_async")
			self.getThreadInfo()
		}
	}

	func onThreadRun() {
		print("onThreadRun")
		getThreadInfo()
	}
}

