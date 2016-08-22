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

	@IBAction func onSerialQueue() {
		gcdCustomSerialQueue()
	}

	@IBAction func onConcurrentQueue() {
		gcdCustomConcurrentQueue()
	}

	@IBAction func onBlockOperationQueue() {
		blockOperationQueue()
	}

	@IBAction func onBlockOperation() {
		blockOperation()
	}

	@IBAction func onMainThread() {
		mainThread()
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

	// MARK: 添加一个block到主队列,异步执行,不会阻塞当前线程
	func gcdMainQueueAsync() {
		dispatch_async(dispatch_get_main_queue()) {
			print("main_async")
			self.getThreadInfo()
		}
	}

	// MARK: 自定义一个同步队列
	func gcdCustomSerialQueue() {
		let queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_SERIAL)
		// 同步调用,当前线程执行
//		dispatch_sync(queue) {
//			print("custom_queue")
//			self.getThreadInfo()
//		}
		// 异步调用,子线程执行
		dispatch_async(queue) {
			print("custom_queue")
			self.getThreadInfo()
		}
	}

	// MARK: 自定义一个异步队列
	func gcdCustomConcurrentQueue() {
		let queue = dispatch_queue_create("serial_queue", DISPATCH_QUEUE_CONCURRENT)
//		dispatch_sync(queue) {
//			print("custom_queue")
//			self.getThreadInfo()
//		}
		dispatch_async(queue) {
			print("custom_queue")
			self.getThreadInfo()
		}
	}

	// MARK: ns block 会在当前线程执行,并且是一个 并行队列
	func blockOperation() {
		// 并行队列,多任务会同时进行
//		NSBlockOperation {
//			print("blockOperation")
//			self.getThreadInfo()
//		}.start()

		let block = NSBlockOperation {
			print("blockOperation1")
			self.getThreadInfo()
		}
		block.addExecutionBlock {
			print("blockOperation2")
			self.getThreadInfo()
		}
		block.addExecutionBlock {
			print("blockOperation3")
			self.getThreadInfo()
		}
		block.start() // 并行执行1,2,3个任务, 执行顺序不保证
	}

	// MARK: 添加到队列的block会立即执行,
	func blockOperationQueue() {
		let queue = NSOperationQueue()
//		queue.addOperationWithBlock {
//			print("blockOperationQueue")
//			self.getThreadInfo()
//		}

		let operation1 = NSBlockOperation {
			print("operation1")
			self.getThreadInfo()
		}
		let operation2 = NSBlockOperation {
			print("operation2")
			self.getThreadInfo()
		}
		let operation3 = NSBlockOperation {
			print("operation3")
			self.getThreadInfo()
		}
		operation2.addDependency(operation1) // 2会等待1执行完后,再执行
		operation3.addDependency(operation2) // 3会等待2执行完后,再执行
		queue.addOperations([operation1, operation2, operation3], waitUntilFinished: true) //
	}

	// MARK: 一定在主线程回调
	func mainThread() {
		// 1->在主线程的队列执行
		dispatch_async(dispatch_get_main_queue()) {
			print("dispatch_async")
			self.getThreadInfo()
		}

		// 2->在主线程执行
		NSOperationQueue.mainQueue().addOperationWithBlock {
			print("mainQueue")
			self.getThreadInfo()
		}
	}

	func onThreadRun() {
		print("onThreadRun")
		getThreadInfo()
	}
}

