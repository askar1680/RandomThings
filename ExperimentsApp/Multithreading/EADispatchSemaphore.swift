import Foundation

final class EADispatchSemaphore {
    
    static let semaphore = DispatchSemaphore(value: 2)
    
    static func test() {
        DispatchQueue.concurrentPerform(iterations: 10) { i in
            semaphore.wait()
            print(i)
            sleep(1)
            semaphore.signal()
        }
        
        DispatchQueue.global().async {
            semaphore.wait()
            print("The end")
            semaphore.signal()
        }
    }
    
    private let maxCount: Int
    private var counter: Int = 0
    private let condition = NSCondition()
    
    init(value: Int) {
        self.maxCount = value
    }
    
    func signal() {
        condition.lock()
        counter -= 1
        condition.unlock()
    }
    
    func wait() {
        condition.lock()
        counter += 1
        while counter > maxCount {
            condition.wait()
        }
        condition.unlock()
    }
}
