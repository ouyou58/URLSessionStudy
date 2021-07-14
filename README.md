# URLSessionStudy
记录了关于通信的基础学习
・只有url的通信



延迟执行的几种方法
// 1.perform(必须在主线程中执行)
self.perform(#selector(delayExecution), with: nil, afterDelay: 3)
// 取消
NSObject.cancelPreviousPerformRequests(withTarget: self)

// 2.timer(必须在主线程中执行)
Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(delayExecution), userInfo: nil, repeats: false)

// 3.Thread (在主线程会卡主界面)
Thread.sleep(forTimeInterval: 3)
self.delayExecution()

// 4.GCD 主线程/子线程
DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
    self.delayExecution()
}

DispatchQueue.global().asyncAfter(deadline: .now() + 3) {
    self.delayExecution()
}

