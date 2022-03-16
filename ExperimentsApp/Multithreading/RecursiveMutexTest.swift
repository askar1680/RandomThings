import Foundation

class SafeRecursiveThread: Thread {
    
    let recursiveLock = NSRecursiveLock()
    
    override func main() {
        recursiveLock.lock()
        print("main")
        SafeRecursiveThread.sleep(forTimeInterval: 2)
        someMethod()
        recursiveLock.unlock()
    }
    
    private func someMethod() {
        recursiveLock.lock()
        print("method")
        recursiveLock.unlock()
    }
}
