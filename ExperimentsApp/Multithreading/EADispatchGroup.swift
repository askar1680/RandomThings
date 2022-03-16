import Foundation

final class EADispatchGroup {
    
    static let group = EADispatchGroup()
    
    static func test() {
        
        var first = 0
        var second = 0
        DispatchQueue.global().async {
            group.enter()
            sleep(3)
            print("first")
            first = 3
            group.leave()
        }
        
        DispatchQueue.global().async {
            group.enter()
            sleep(4)
            print("second")
            second = 5
            group.leave()
        }
        
        DispatchQueue.global().async {
            group.wait()
            let sum = first + second
            print("The end" + sum.description)
        }
    }
    
    var counter = 0
    let condition = NSCondition()
    
    func enter() {
        condition.lock()
        counter += 1
        condition.unlock()
    }
    
    func leave() {
        condition.lock()
        counter -= 1
        condition.signal()
        condition.unlock()
    }
    
    func wait() {
        condition.lock()
        while counter != 0 {
            print("wait")
            condition.wait()
        }
        condition.unlock()
    }
}
