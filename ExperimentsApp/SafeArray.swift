import Foundation

class SafeArray<T> {
    
    private var array: [T]
    private let queue = DispatchQueue(label: "safearray", attributes: .concurrent)
    private let lock = NSRecursiveLock()
    
    init() {
        array = []
    }
    
    func append(_ newElement: T) {
        queue.async(flags: .barrier) {
            self.array.append(newElement)
        }
    }
    
    func append(contentsOf newElements: [T]) {
        queue.async(flags: .barrier) {
            self.array.append(contentsOf: newElements)
        }
    }
    
    func getArray() -> [T] {
        var result: [T] = []
        queue.sync {
            result = array
        }
        return result
    }
    
    func remove(condition: @escaping (T) -> Bool) {
        queue.async(flags: .barrier) {
            self.array.removeAll(where: condition)
        }
    }
    
    func removeAll() {
        queue.async(flags: .barrier) {
            self.array.removeAll()
        }
    }
}

class SafeDictionary<Key: Hashable, Value> {
    private var dictionary: [Key: Value]
    private let queue = DispatchQueue(label: "safearray", attributes: .concurrent)
    
    init() {
        dictionary = [:]
    }
    
    func put(key: Key, value: Value) {
        queue.async(flags: .barrier) {
            self.dictionary[key] = value
        }
    }
    
    func getValue(key: Key) -> Value? {
        queue.sync {
            return dictionary[key]
        }
    }
    
    func remove(key: Key) {
        queue.async(flags: .barrier) {
            self.dictionary.removeValue(forKey: key)
        }
    }
}
