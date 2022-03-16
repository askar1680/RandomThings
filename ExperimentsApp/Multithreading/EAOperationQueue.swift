import UIKit

final class TestOperations {
    
    let operationQueue = EAOperationQueue()
    
    var counter = 0
    
    func test() {
        print("start")
        operationQueue.maxConcurrentOperationCount = 2
        DispatchQueue.concurrentPerform(iterations: 30) { i in
            print(i)
            sleep(1)
        }
        print("the end")
    }
}

final class EAOperationQueue: NSObject {
    var maxConcurrentOperationCount: Int = 2 {
        didSet {
            queue.sync(flags: .barrier) {
                semaphore = DispatchSemaphore(value: maxConcurrentOperationCount)
            }
        }
    }
    
    var operations: [Operation] {
        return allOperations.getArray()
    }
    
    private var allOperations = SafeArray<Operation>()
    private var dependenciesMap = SafeDictionary<String, [Operation]>()
    
    private var semaphore = DispatchSemaphore(value: 2)
    private let queue = DispatchQueue(label: "EAOperationQueue", qos: .default, attributes: .concurrent)
    
    override func observeValue(
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey : Any]?,
        context: UnsafeMutableRawPointer?
    ) {
        guard let operation = object as? Operation,
                let keyPath = keyPath,
                let state = OperationState(rawValue: keyPath)
        else {
            return
        }
        switch state {
        case .isReady:
            break
        case .isExecuting:
            break
        case .isCancelled:
            self.semaphore.signal()
            self.allOperations.remove(condition: { $0.name == operation.name })
        case .isFinished:
            self.semaphore.signal()
            guard let name = operation.name else {
                return
            }
            
            self.allOperations.remove(condition: { $0.name == name })
            guard let dependencies = self.dependenciesMap.getValue(key: name) else {
                return
            }
            for dependency in dependencies {
                dependency.start()
            }
        }
    }
    
    func addOperation(_ operation: Operation) {
        appendOperation(operation)
    }
    
    func addOperation(_ block: @escaping () -> Void) {
        appendOperation(BlockOperation(block: block))
    }
    
    private func appendOperation(_ operation: Operation) {
        queue.sync {
            let id = UUID().uuidString
            self.dependenciesMap.put(key: id, value: operation.dependencies)
            
            operation.name = id
            operation.addObserver(self, forKeyPath: OperationState.isReady.rawValue, options: .new, context: nil)
            operation.addObserver(self, forKeyPath: OperationState.isExecuting.rawValue, options: .new, context: nil)
            operation.addObserver(self, forKeyPath: OperationState.isCancelled.rawValue, options: .new, context: nil)
            operation.addObserver(self, forKeyPath: OperationState.isFinished.rawValue, options: .new, context: nil)
            
            self.allOperations.append(operation)
            
            self.semaphore.wait()
            operation.start()
        }
    }
    
    func cancelAllOperations() {
        for operation in allOperations.getArray() {
            operation.cancel()
        }
        allOperations.removeAll()
        
        queue.async(flags: .barrier) {
            self.semaphore = DispatchSemaphore(value: self.maxConcurrentOperationCount)
        }
    }
    
    let condition = NSCondition()
    
    func waitUntilAllOperationsAreFinished() {
        while !allOperations.getArray().isEmpty {
            usleep(100000)
        }
    }
    
    private enum OperationState: String {
        case isReady
        case isExecuting
        case isCancelled
        case isFinished
    }
}


// Not finished
class EAOperation: NSObject {
    
    var isReady: Bool {
        return true
    }
    
    var isExecuting: Bool {
        return false
    }
    
    var isCancelled: Bool {
        return false
    }
    
    var isFinished: Bool {
        return false
    }
    
    var dependencies: [EAOperation] {
        return []
    }
    
    var name: String?
    
    func start() {
        
    }
    
    func main() {
        
    }
    
    func cancel() {
        
    }
}

// Not finished
class EABlockOperation: EAOperation {
    
    var block: () -> Void
    
    override var isReady: Bool {
        return _isReady
    }
    
    override var isExecuting: Bool {
        return _isExecuting
    }
    
    override var isCancelled: Bool {
        return _isCancelled
    }
    
    override var isFinished: Bool {
        return _isFinished
    }
    
    override var dependencies: [EAOperation] {
        return _dependencies
    }
    
    private var _isReady: Bool = true
    private var _isExecuting: Bool = false
    private var _isCancelled: Bool = false
    private var _isFinished: Bool = false
    private var _dependencies: [EAOperation] = []
    
    init(block: @escaping () -> Void) {
        self.block = block
    }
    
    override func start() {
        _isExecuting = true
        main()
    }
    
    override func main() {
        if isCancelled {
            _isExecuting = false
            return
        }
        block()
        _isFinished = true
    }
    
    override func cancel() {
        _isCancelled = true
    }
}
