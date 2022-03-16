import Foundation

final class EADispatchSemaphore {
    
    static let semaphore = EADispatchSemaphore(value: 3)
    
    static func test() {
        DispatchQueue.concurrentPerform(iterations: 10) { i in
            semaphore.wait()
            print(i)
            sleep(1)
            semaphore.signal()
        }
    }
    
    private let maxCount: Int
    private var counter: Int = 0
    private var signalCount: Int = 0
    private let condition = NSCondition()
    
    init(value: Int) {
        self.maxCount = value
    }
    
    func signal() {
        condition.lock()
        counter -= 1
        signalCount += 1
        condition.unlock()
        condition.signal()
    }
    
    func wait() {
        condition.lock()
        counter += 1
        while counter > maxCount {
            if signalCount > 0 {
                signalCount -= 1
                break
            }
            condition.wait()
        }
        condition.unlock()
    }
}
